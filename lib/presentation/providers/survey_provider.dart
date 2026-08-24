import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/survey_api.dart';

// Provides a way to submit a survey
final surveyNotifierProvider = StateNotifierProvider<SurveyNotifier, AsyncValue<void>>((ref) {
  return SurveyNotifier(ref.watch(surveyApiProvider));
});

class SurveyNotifier extends StateNotifier<AsyncValue<void>> {
  final SurveyApi _surveyApi;

  SurveyNotifier(this._surveyApi) : super(const AsyncValue.data(null));

  Future<void> submitSurvey(Map<String, dynamic> surveyData, List<Map<String, dynamic>> photos) async {
    state = const AsyncValue.loading();
    try {
      // 1. Submit survey data
      final result = await _surveyApi.createSurvey(surveyData);
      final surveyId = result['_id'];

      // 2. Attach photos (Normally we'd get signature, upload to Cloudinary, then attach)
      // For this step, we assume photos already uploaded or simple attachment
      if (surveyId != null && photos.isNotEmpty) {
        await _surveyApi.attachPhotos(surveyId, photos);
      }

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
