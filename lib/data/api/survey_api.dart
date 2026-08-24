import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final surveyApiProvider = Provider<SurveyApi>((ref) {
  return SurveyApi(ref.watch(dioProvider));
});

class SurveyApi {
  final Dio _dio;

  SurveyApi(this._dio);

  Future<Map<String, dynamic>> createSurvey(Map<String, dynamic> surveyData) async {
    try {
      final response = await _dio.post(
        '/surveys',
        data: surveyData,
      );
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to submit survey');
      }
      throw Exception('Network error submitting survey');
    }
  }

  Future<Map<String, dynamic>> getUploadSignature(Map<String, dynamic> params) async {
    try {
      final response = await _dio.post(
        '/uploads/signature',
        data: params,
      );
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get upload signature');
      }
      throw Exception('Network error getting upload signature');
    }
  }

  Future<void> attachPhotos(String surveyId, List<Map<String, dynamic>> photos) async {
    try {
      await _dio.post(
        '/surveys/$surveyId/photos',
        data: {'photos': photos},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to attach photos');
      }
      throw Exception('Network error attaching photos');
    }
  }
}
