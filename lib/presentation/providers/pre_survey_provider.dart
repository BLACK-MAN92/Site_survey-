import 'package:flutter_riverpod/flutter_riverpod.dart';

// State model for the Pre-Survey
class PreSurveyState {
  final String siteId;
  final String clientUuid;
  final DateTime? plannedDate;
  final String comment;
  final Map<String, bool> requiredWorkItems;
  final List<String> photoPaths;
  
  PreSurveyState({
    required this.siteId,
    required this.clientUuid,
    this.plannedDate,
    this.comment = '',
    this.requiredWorkItems = const {},
    this.photoPaths = const [],
  });

  PreSurveyState copyWith({
    String? siteId,
    String? clientUuid,
    DateTime? plannedDate,
    String? comment,
    Map<String, bool>? requiredWorkItems,
    List<String>? photoPaths,
  }) {
    return PreSurveyState(
      siteId: siteId ?? this.siteId,
      clientUuid: clientUuid ?? this.clientUuid,
      plannedDate: plannedDate ?? this.plannedDate,
      comment: comment ?? this.comment,
      requiredWorkItems: requiredWorkItems ?? this.requiredWorkItems,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }
}

class PreSurveyNotifier extends Notifier<PreSurveyState> {
  @override
  PreSurveyState build() {
    return PreSurveyState(siteId: '', clientUuid: 'new-uuid'); // Normally generate UUID
  }

  void initialize(String siteId, String clientUuid) {
    state = state.copyWith(siteId: siteId, clientUuid: clientUuid);
  }

  void updateHeader(DateTime? date, String comment) {
    state = state.copyWith(plannedDate: date, comment: comment);
    _autosave();
  }

  void setWorkItemRequired(String itemKey, bool isRequired) {
    final updatedItems = Map<String, bool>.from(state.requiredWorkItems);
    updatedItems[itemKey] = isRequired;
    state = state.copyWith(requiredWorkItems: updatedItems);
    _autosave();
  }

  void addPhoto(String path) {
    state = state.copyWith(photoPaths: [...state.photoPaths, path]);
    _autosave();
  }

  void _autosave() {
    // In a fully working app, this calls the Drift DB to insert/update the draft record
    // e.g., ref.read(databaseProvider).surveysDao.saveDraft(state);
    print('Autosaving draft to local DB for site: ${state.siteId}');
  }
}

final preSurveyProvider = NotifierProvider<PreSurveyNotifier, PreSurveyState>(() {
  return PreSurveyNotifier();
});
