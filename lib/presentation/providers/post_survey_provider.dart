import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/image_service.dart';
import '../../core/services/location_service.dart';
import '../../data/api/photo_api.dart';
import '../../data/api/survey_api.dart';
import 'captured_photo.dart';
import 'geo_fix.dart';
import 'pre_survey_provider.dart'
    show
        OutOfFenceReasonRequired,
        kMinimumPhotos,
        kMaximumPhotos,
        kWorkItemLabels;

/// A work item as the post-survey reports it: what was planned at pre-survey,
/// and what actually happened.
class PostWorkItem {
  final String key;
  final bool isRequired;
  final String? progress; // 'WIP' or 'Closed'
  final bool isUnplanned;
  final int? qtyReplaced;

  const PostWorkItem({
    required this.key,
    required this.isRequired,
    this.progress,
    this.isUnplanned = false,
    this.qtyReplaced,
  });

  /// True when this item has to be reported on — either it was scoped at
  /// pre-survey, or the engineer added it as unplanned work.
  bool get isInScope => isRequired || isUnplanned;

  PostWorkItem copyWith({
    String? progress,
    bool? isUnplanned,
    int? qtyReplaced,
  }) {
    return PostWorkItem(
      key: key,
      isRequired: isRequired,
      progress: progress ?? this.progress,
      isUnplanned: isUnplanned ?? this.isUnplanned,
      qtyReplaced: qtyReplaced ?? this.qtyReplaced,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        // Unplanned work still has to be flagged required, otherwise the API
        // rejects the progress that goes with it.
        'required': isRequired || isUnplanned,
        if (progress != null) 'progress': progress,
        if (qtyReplaced != null) 'qtyReplaced': qtyReplaced,
      };
}

class PostSurveyState {
  final String siteId;
  final String clientUuid;
  final List<PostWorkItem> items;
  final List<CapturedPhoto> photos;
  final DateTime? actualCleanupDate;
  final GeoFix? openFix;
  final String? outOfFenceReason;
  final bool submitting;
  final String? error;

  PostSurveyState({
    required this.siteId,
    required this.clientUuid,
    this.items = const [],
    this.photos = const [],
    this.actualCleanupDate,
    this.openFix,
    this.outOfFenceReason,
    this.submitting = false,
    this.error,
  });

  int get uploadedCount => photos.where((p) => p.isUploaded).length;
  bool get hasFailedUploads =>
      photos.any((p) => p.status == PhotoUploadStatus.failed);

  /// Rule R-2: the survey is Closed only when every in-scope item is Closed.
  /// Reported optimistically here and re-derived by the API, which is the
  /// authority — this exists so the engineer is not surprised at submission.
  String get overallStatus {
    final inScope = items.where((i) => i.isInScope);
    if (inScope.isEmpty) return 'WIP';
    return inScope.every((i) => i.progress == 'Closed') ? 'Closed' : 'WIP';
  }

  PostSurveyState copyWith({
    List<PostWorkItem>? items,
    List<CapturedPhoto>? photos,
    DateTime? actualCleanupDate,
    GeoFix? openFix,
    String? outOfFenceReason,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) {
    return PostSurveyState(
      siteId: siteId,
      clientUuid: clientUuid,
      items: items ?? this.items,
      photos: photos ?? this.photos,
      actualCleanupDate: actualCleanupDate ?? this.actualCleanupDate,
      openFix: openFix ?? this.openFix,
      outOfFenceReason: outOfFenceReason ?? this.outOfFenceReason,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PostSurveyNotifier extends Notifier<PostSurveyState> {
  final _imageService = ImageService();
  final _locationService = LocationService();

  @override
  PostSurveyState build() =>
      PostSurveyState(siteId: '', clientUuid: const Uuid().v4());

  void initialize(String siteId, Map<String, bool> preSurveyScope) {
    state = PostSurveyState(
      siteId: siteId,
      clientUuid: const Uuid().v4(),
      items: [
        for (final entry in preSurveyScope.entries)
          PostWorkItem(key: entry.key, isRequired: entry.value),
      ],
    );
    _captureOpenFix();
  }

  Future<void> _captureOpenFix() async {
    final fix = await _locationService.currentFix();
    if (fix != null) state = state.copyWith(openFix: fix);
  }

  void setProgress(String key, String progress) {
    state = state.copyWith(items: [
      for (final i in state.items)
        if (i.key == key) i.copyWith(progress: progress) else i,
    ]);
  }

  void setQtyReplaced(String key, int qty) {
    state = state.copyWith(items: [
      for (final i in state.items)
        if (i.key == key) i.copyWith(qtyReplaced: qty) else i,
    ]);
  }

  void addUnplanned(String key) {
    state = state.copyWith(items: [
      for (final i in state.items)
        if (i.key == key) i.copyWith(isUnplanned: true, progress: 'WIP') else i,
    ]);
  }

  void setActualCleanupDate(DateTime date) {
    state = state.copyWith(actualCleanupDate: date);
  }

  void setOutOfFenceReason(String reason) {
    state = state.copyWith(outOfFenceReason: reason);
  }

  Future<void> addPhoto(String localPath, {String? workItemKey}) async {
    if (state.photos.length >= kMaximumPhotos) return;
    state = state.copyWith(photos: [
      ...state.photos,
      CapturedPhoto(
        localPath: localPath,
        category: 'after',
        workItemKey: workItemKey,
      ),
    ]);
    await _upload(localPath);
  }

  Future<void> retryUpload(String localPath) => _upload(localPath);

  void removePhoto(String localPath) {
    state = state.copyWith(
      photos: state.photos.where((p) => p.localPath != localPath).toList(),
    );
  }

  void _patch(String localPath, CapturedPhoto Function(CapturedPhoto) update) {
    state = state.copyWith(photos: [
      for (final p in state.photos)
        if (p.localPath == localPath) update(p) else p,
    ]);
  }

  Future<void> _upload(String localPath) async {
    final existing =
        state.photos.where((p) => p.localPath == localPath).firstOrNull;
    if (existing == null || existing.status == PhotoUploadStatus.uploading) {
      return;
    }

    _patch(localPath,
        (p) => p.copyWith(status: PhotoUploadStatus.uploading, clearError: true));

    try {
      final fix = state.openFix;
      final prepared = await _imageService.prepareForUpload(
        imagePath: localPath,
        siteId: state.siteId,
        lat: fix?.lat,
        lng: fix?.lng,
      );

      final uploaded = await ref.read(photoApiProvider).uploadPhoto(
            file: prepared.file,
            siteId: state.siteId,
            surveyUuid: state.clientUuid,
            category: 'after',
            workItemKey: existing.workItemKey,
          );

      if (await prepared.file.exists()) await prepared.file.delete();

      _patch(
        localPath,
        (p) => p.copyWith(
          status: PhotoUploadStatus.uploaded,
          uploaded: uploaded,
          clearError: true,
        ),
      );
    } catch (e) {
      _patch(localPath,
          (p) => p.copyWith(status: PhotoUploadStatus.failed, error: e.toString()));
    }
  }

  Future<void> uploadOutstanding() async {
    for (final path in state.photos
        .where((p) => !p.isUploaded)
        .map((p) => p.localPath)
        .toList()) {
      await _upload(path);
    }
  }

  Map<String, dynamic> buildPayload(GeoFix submitFix) {
    return {
      'siteId': state.siteId,
      'clientUuid': state.clientUuid,
      'surveyType': 'post',
      'revision': 1,
      'geo': {
        'openFix': (state.openFix ?? submitFix).toJson(),
        'submitFix': submitFix.toJson(),
        if (state.outOfFenceReason != null)
          'outOfFenceReason': state.outOfFenceReason,
      },
      // Only in-scope items are reported: the API rejects progress on an item
      // that was not required, so sending the untouched ones would fail.
      'workItems': [
        for (final i in state.items.where((i) => i.isInScope)) i.toJson(),
      ],
      if (state.actualCleanupDate != null)
        'actualCleanupDate': state.actualCleanupDate!.toUtc().toIso8601String(),
      'overallStatus': state.overallStatus,
    };
  }

  /// Validates locally what the API would otherwise reject, so an engineer on
  /// site learns about it before the round trip.
  String? validationError() {
    final inScope = state.items.where((i) => i.isInScope).toList();
    if (inScope.isEmpty) {
      return 'No work items are in scope for this post-survey.';
    }

    for (final item in inScope) {
      if (item.progress == null) {
        return 'Set progress for ${kWorkItemLabels[item.key] ?? item.key}.';
      }
      // BR-3: a closed security light must say how many units were replaced.
      if (item.key == 'security_light' &&
          item.progress == 'Closed' &&
          (item.qtyReplaced == null || item.qtyReplaced! <= 0)) {
        return 'Enter the number of security lights replaced.';
      }
    }

    if (state.uploadedCount < kMinimumPhotos) {
      return 'At least $kMinimumPhotos uploaded after-photos are required.';
    }
    return null;
  }

  Future<String> submit() async {
    state = state.copyWith(submitting: true, clearError: true);

    try {
      await uploadOutstanding();

      final problem = validationError();
      if (problem != null) throw Exception(problem);

      if (state.photos.any((p) => !p.isUploaded)) {
        throw Exception(
          'Some photos could not be uploaded. Retry them before submitting.',
        );
      }

      final submitFix = await _locationService.currentFix();
      if (submitFix == null) {
        throw Exception(
          'A GPS fix is required to submit. Enable location and try again.',
        );
      }

      final surveyApi = ref.read(surveyApiProvider);
      final survey = await surveyApi.createSurvey(buildPayload(submitFix));

      final surveyId = (survey['id'] ?? survey['_id'])?.toString();
      if (surveyId == null) {
        throw Exception('The server accepted the survey but returned no id.');
      }

      await surveyApi.attachPhotos(
        surveyId,
        state.photos.map((p) => p.uploaded!.toAttachmentJson()).toList(),
      );

      state = state.copyWith(submitting: false);
      return surveyId;
    } on OutOfFenceRequiredException catch (e) {
      state = state.copyWith(submitting: false);
      throw OutOfFenceReasonRequired(e.message);
    } catch (e) {
      state = state.copyWith(submitting: false, error: e.toString());
      rethrow;
    }
  }
}

final postSurveyProvider =
    NotifierProvider<PostSurveyNotifier, PostSurveyState>(
        PostSurveyNotifier.new);

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
