import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final surveyApiProvider = Provider<SurveyApi>((ref) {
  return SurveyApi(ref.watch(dioProvider));
});

class SurveyApiException implements Exception {
  final String message;

  /// Field-level detail from the API, so the UI can point at what to fix.
  final List<dynamic> details;

  SurveyApiException(this.message, {this.details = const []});

  @override
  String toString() => message;
}

/// The submitted fix was outside the site's geofence and the API needs a stated
/// reason before it will accept the survey.
class OutOfFenceRequiredException extends SurveyApiException {
  OutOfFenceRequiredException(super.message);
}

class SurveyApi {
  final Dio _dio;

  SurveyApi(this._dio);

  /// Submits the survey form. Photos are attached separately, once the survey
  /// has an id to hang them on.
  Future<Map<String, dynamic>> createSurvey(
      Map<String, dynamic> surveyData) async {
    try {
      final response = await _dio.post('/surveys', data: surveyData);
      final data = response.data['data'];
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on DioException catch (e) {
      throw _describe(e, 'submit the survey');
    }
  }

  Future<Map<String, dynamic>> getUploadSignature(
      Map<String, dynamic> params) async {
    try {
      final response = await _dio.post('/uploads/signature', data: params);
      final data = response.data['data'];
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } on DioException catch (e) {
      throw _describe(e, 'prepare the upload');
    }
  }

  /// Attaches stored photo records — Cloudinary id and URL plus dimensions — to
  /// an existing survey, so the form and its evidence live in one document.
  Future<void> attachPhotos(
      String surveyId, List<Map<String, dynamic>> photos) async {
    try {
      await _dio.post('/surveys/$surveyId/photos', data: {'photos': photos});
    } on DioException catch (e) {
      throw _describe(e, 'attach the photos');
    }
  }

  SurveyApiException _describe(DioException e, String what) {
    final data = e.response?.data;
    String? message;
    List<dynamic> details = const [];

    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        if (error['message'] is String) message = error['message'] as String;
        if (error['details'] is List) details = error['details'] as List;
      }
    }

    // The API refuses a survey taken outside the 800m fence unless a reason is
    // given. That is a prompt for the engineer, not a failure.
    final needsReason = details.any((d) =>
        d is Map &&
        (d['issue'] == 'MISSING_REASON' ||
            d['field'] == 'geo.outOfFenceReason'));
    if (needsReason) {
      return OutOfFenceRequiredException(
          message ?? 'This survey is outside the site geofence.');
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      return SurveyApiException('Your session has expired. Please sign in again.');
    }
    if (status == 403) {
      return SurveyApiException(
          'You are not assigned to this site, so you cannot $what.');
    }
    if (status == 409) {
      return SurveyApiException(
        message ?? 'A survey already exists for this site and revision.',
        details: details,
      );
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return SurveyApiException(
        'Could not reach the server to $what. Your work is kept on the '
        'device — retry when you have signal.',
      );
    }

    return SurveyApiException(
      message ?? 'Could not $what (${status ?? 'network error'}).',
      details: details,
    );
  }
}
