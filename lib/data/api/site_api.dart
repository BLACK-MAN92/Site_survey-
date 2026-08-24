import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

final siteApiProvider = Provider<SiteApi>((ref) {
  return SiteApi(ref.watch(dioProvider));
});

/// Raised when the API cannot be reached or refuses the request, so the UI can
/// tell the user what went wrong instead of showing an empty or fabricated list.
class SiteApiException implements Exception {
  final String message;
  SiteApiException(this.message);

  @override
  String toString() => message;
}

/// Turns a Dio failure into something a field engineer can act on.
SiteApiException _describe(Object error, String what) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status == 401) {
      return SiteApiException('Your session has expired. Please sign in again.');
    }
    if (status == 403) {
      return SiteApiException('Your account is not permitted to view $what.');
    }
    if (status == 404) {
      return SiteApiException('$what could not be found.');
    }
    if (status != null) {
      final message = error.response?.data is Map
          ? (error.response?.data['error']?['message'] as String?)
          : null;
      return SiteApiException(message ?? 'The server returned an error ($status).');
    }
    return SiteApiException(
      'Could not reach the server at ${error.requestOptions.baseUrl}. '
      'Check that you are on the same network and the API is running.',
    );
  }
  return SiteApiException('Unexpected error loading $what.');
}

class SiteApi {
  final Dio _dio;

  SiteApi(this._dio);

  /// Sites assigned to the signed-in engineer. An empty list means nothing has
  /// been assigned yet — it is never padded with placeholder data, because a
  /// silent fallback previously made connection and auth failures look like
  /// real work queues.
  Future<List<dynamic>> getAssignedSites() async {
    try {
      final response = await _dio.get('/sites');
      return response.data['data'] ?? [];
    } catch (e) {
      throw _describe(e, 'sites');
    }
  }

  /// [id] is the site's database id (the `id` field), not the I.H.S Site ID.
  Future<Map<String, dynamic>> getSiteDetails(String id) async {
    try {
      final response = await _dio.get('/sites/$id');
      return response.data['data'] ?? {};
    } catch (e) {
      throw _describe(e, 'this site');
    }
  }
}
