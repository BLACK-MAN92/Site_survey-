import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/image_service.dart';
import '../../core/services/location_service.dart';
import '../../data/api/photo_api.dart';
import '../../data/api/survey_api.dart';
import 'captured_photo.dart';
import 'geo_fix.dart';

/// Every work item a pre-survey has to account for. The API rejects a
/// pre-survey that does not carry all thirteen, so the list is the contract.
const List<String> kWorkItems = [
  'janitorial', 'granite', 'concrete_resurfacing', 'palisade_gate',
  'razor_coil', 'awl', 'security_light', 'tank_painting',
  'sg_house_repair', 'fire_extinguisher', 'shelter_repair',
  'cable_management', 'waste_disposal',
];

const Map<String, String> kWorkItemLabels = {
  'janitorial': 'Janitorial',
  'granite': 'Granite',
  'concrete_resurfacing': 'Concrete Resurfacing',
  'palisade_gate': 'Palisade & Gate',
  'razor_coil': 'Razor Coil',
  'awl': 'AWL (Aviation Warning Light)',
  'security_light': 'Security Light',
  'tank_painting': 'Tank Painting',
  'sg_house_repair': 'SG House Repair',
  'fire_extinguisher': 'Fire Extinguisher',
  'shelter_repair': 'Shelter Repair',
  'cable_management': 'Cable Management',
  'waste_disposal': 'Waste Disposal',
};

/// Minimum photographic evidence per survey.
const int kMinimumPhotos = 5;
const int kMaximumPhotos = 20;

/// Raised when the API needs a reason for surveying outside the site geofence.
/// The engineer picks one and the submission is retried.
class OutOfFenceReasonRequired implements Exception {
  final String message;
  OutOfFenceReasonRequired(this.message);
}

class PreSurveyState {
  final String siteId;
  final String clientUuid;
  final DateTime? plannedDate;
  final String comment;
  final Map<String, bool> requiredWorkItems;
  final List<CapturedPhoto> photos;

  /// GPS fix taken when the survey was opened. Paired with a fix taken at
  /// submission, it is how the back office sees the engineer was on site for
  /// the duration rather than driving past.
  final GeoFix? openFix;
  final String? outOfFenceReason;

  final bool submitting;
  final String? error;

  PreSurveyState({
    required this.siteId,
    required this.clientUuid,
    this.plannedDate,
    this.comment = '',
    this.requiredWorkItems = const {},
    this.photos = const [],
    this.openFix,
    this.outOfFenceReason,
    this.submitting = false,
    this.error,
  });

  int get uploadedCount => photos.where((p) => p.isUploaded).length;
  bool get hasFailedUploads =>
      photos.any((p) => p.status == PhotoUploadStatus.failed);
  bool get isUploading =>
      photos.any((p) => p.status == PhotoUploadStatus.uploading);

  /// A survey may only be submitted once every photo is safely in Cloudinary —
  /// the survey document stores links, so an un-uploaded photo would be
  /// evidence that exists only on one engineer's phone.
  bool get canSubmit =>
      uploadedCount >= kMinimumPhotos &&
      uploadedCount == photos.length &&
      !submitting;

  PreSurveyState copyWith({
    String? siteId,
    String? clientUuid,
    DateTime? plannedDate,
    String? comment,
    Map<String, bool>? requiredWorkItems,
    List<CapturedPhoto>? photos,
    GeoFix? openFix,
    String? outOfFenceReason,
    bool? submitting,
    String? error,
    bool clearError = false,
  }) {
    return PreSurveyState(
      siteId: siteId ?? this.siteId,
      clientUuid: clientUuid ?? this.clientUuid,
      plannedDate: plannedDate ?? this.plannedDate,
      comment: comment ?? this.comment,
      requiredWorkItems: requiredWorkItems ?? this.requiredWorkItems,
      photos: photos ?? this.photos,
      openFix: openFix ?? this.openFix,
      outOfFenceReason: outOfFenceReason ?? this.outOfFenceReason,
      submitting: submitting ?? this.submitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PreSurveyNotifier extends Notifier<PreSurveyState> {
  final _imageService = ImageService();
  final _locationService = LocationService();

  @override
  PreSurveyState build() {
    // The API validates clientUuid with z.string().uuid(), so a placeholder
    // string is rejected outright. Idempotent replay also depends on this being
    // a stable, genuinely unique value per submission.
    return PreSurveyState(siteId: '', clientUuid: const Uuid().v4());
  }

  /// [clientUuid] is optional: omit it to mint a fresh one for a new survey.
  void initialize(String siteId, [String? clientUuid]) {
    state = PreSurveyState(
      siteId: siteId,
      clientUuid: clientUuid ?? const Uuid().v4(),
    );
    _captureOpenFix();
  }

  Future<void> _captureOpenFix() async {
    final fix = await _locationService.currentFix();
    if (fix != null) state = state.copyWith(openFix: fix);
  }

  void updateHeader(DateTime? date, String comment) {
    state = state.copyWith(plannedDate: date, comment: comment);
  }

  void setWorkItemRequired(String itemKey, bool isRequired) {
    final updated = Map<String, bool>.from(state.requiredWorkItems);
    updated[itemKey] = isRequired;
    state = state.copyWith(requiredWorkItems: updated);
  }

  void setOutOfFenceReason(String reason) {
    state = state.copyWith(outOfFenceReason: reason);
  }

  /// Records a freshly captured photo and starts compressing and uploading it.
  ///
  /// Uploading as the engineer works, rather than in a burst at submission,
  /// means a five-photo survey is not five sequential uploads on a bad
  /// connection at the moment they are trying to leave the site.
  Future<void> addPhoto(String localPath, {String? workItemKey}) async {
    if (state.photos.length >= kMaximumPhotos) return;

    final photo = CapturedPhoto(
      localPath: localPath,
      category: 'before',
      workItemKey: workItemKey,
    );
    state = state.copyWith(photos: [...state.photos, photo]);
    await _upload(localPath);
  }

  /// Retries a photo whose upload failed. The file is still on the device.
  Future<void> retryUpload(String localPath) => _upload(localPath);

  void removePhoto(String localPath) {
    state = state.copyWith(
      photos: state.photos.where((p) => p.localPath != localPath).toList(),
    );
  }

  void _patch(String localPath, CapturedPhoto Function(CapturedPhoto) update) {
    state = state.copyWith(
      photos: [
        for (final p in state.photos)
          if (p.localPath == localPath) update(p) else p,
      ],
    );
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
            category: existing.category,
            workItemKey: existing.workItemKey,
          );

      // The compressed copy has served its purpose; the original stays for the
      // post-survey ghost overlay.
      if (await prepared.file.exists()) {
        await prepared.file.delete();
      }

      _patch(
        localPath,
        (p) => p.copyWith(
          status: PhotoUploadStatus.uploaded,
          uploaded: uploaded,
          clearError: true,
        ),
      );
    } catch (e) {
      _patch(
        localPath,
        (p) => p.copyWith(
          status: PhotoUploadStatus.failed,
          error: e.toString(),
        ),
      );
    }
  }

  /// Uploads everything still outstanding, so a submission is not blocked by a
  /// photo that failed earlier on a weak signal.
  Future<void> uploadOutstanding() async {
    final pending = state.photos
        .where((p) => p.status != PhotoUploadStatus.uploaded)
        .map((p) => p.localPath)
        .toList();

    for (final path in pending) {
      await _upload(path);
    }
  }

  /// The survey body, with the form fields and nothing else. Photos are
  /// attached in a second call once the survey has an id.
  Map<String, dynamic> buildPayload(GeoFix submitFix) {
    return {
      'siteId': state.siteId,
      'clientUuid': state.clientUuid,
      'surveyType': 'pre',
      'revision': 1,
      'geo': {
        // Falling back to the submit fix keeps a survey submittable when the
        // opening fix could not be taken; both are still real readings.
        'openFix': (state.openFix ?? submitFix).toJson(),
        'submitFix': submitFix.toJson(),
        if (state.outOfFenceReason != null)
          'outOfFenceReason': state.outOfFenceReason,
      },
      'workItems': [
        for (final key in kWorkItems)
          {
            'key': key,
            'required': state.requiredWorkItems[key] ?? false,
            // Progress is deliberately omitted: the API rejects progress on an
            // item that is not required, and no work has happened yet at
            // pre-survey time.
          }
      ],
      if (state.comment.trim().isNotEmpty) 'comment': state.comment.trim(),
      if (state.plannedDate != null)
        'plannedCleanupDate': state.plannedDate!.toUtc().toIso8601String(),
      'overallStatus': 'Pending',
    };
  }

  /// Submits the form and attaches the stored photo links to it, so the survey
  /// lands as one document holding both.
  ///
  /// Returns the survey id.
  Future<String> submit() async {
    state = state.copyWith(submitting: true, clearError: true);

    try {
      await uploadOutstanding();

      final outstanding =
          state.photos.where((p) => !p.isUploaded).length;
      if (outstanding > 0) {
        throw Exception(
          '$outstanding photo(s) could not be uploaded. Retry them before '
          'submitting — the survey has to carry every photo.',
        );
      }
      if (state.uploadedCount < kMinimumPhotos) {
        throw Exception('At least $kMinimumPhotos photos are required.');
      }

      final submitFix = await _locationService.currentFix();
      if (submitFix == null) {
        throw Exception(
          'A GPS fix is required to submit. Enable location, move somewhere '
          'with a clear view of the sky, and try again.',
        );
      }

      final surveyApi = ref.read(surveyApiProvider);
      final survey = await surveyApi.createSurvey(buildPayload(submitFix));

      // The API strips _id and returns id; reading the wrong one left the id
      // null and silently skipped photo attachment entirely.
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

final preSurveyProvider =
    NotifierProvider<PreSurveyNotifier, PreSurveyState>(PreSurveyNotifier.new);

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
