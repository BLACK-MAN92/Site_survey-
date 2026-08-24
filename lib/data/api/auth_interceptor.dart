import 'package:dio/dio.dart';
import 'auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorage _authStorage;
  final Dio _dio;

  /// In-flight refresh, shared by every request that hits a 401 at once.
  ///
  /// The API rotates refresh tokens and treats a second use of one as a breach,
  /// invalidating the whole family. Without this guard, two parallel requests
  /// expiring together would each POST the same refresh token and the second
  /// would trigger TOKEN_REUSE_DETECTED, signing the engineer out mid-survey.
  Future<String?>? _refreshInFlight;

  AuthInterceptor(this._authStorage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  /// Returns the new access token, or null if the session is unrecoverable.
  Future<String?> _refreshOnce() {
    // Cleared on completion so a later expiry can refresh again.
    _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
    return _refreshInFlight!;
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _authStorage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;
      if (newAccessToken == null || newRefreshToken == null) return null;

      await _authStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      return newAccessToken;
    } on DioException catch (err) {
      // A rejected refresh token — reused, expired or revoked — cannot be
      // recovered from, so drop the session rather than retrying with it.
      String? code;
      final data = err.response?.data;
      if (data is Map) {
        final error = data['error'];
        if (error is Map) code = error['code'] as String?;
      }

      if (err.response?.statusCode == 401 || code == 'TOKEN_REUSE_DETECTED') {
        await _authStorage.clearTokens();
      }
      return null;
    }
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    // A 401 from the refresh endpoint itself must never start another refresh.
    if (err.requestOptions.path.contains('/auth/refresh')) {
      await _authStorage.clearTokens();
      return super.onError(err, handler);
    }

    final newAccessToken = await _refreshOnce();
    if (newAccessToken == null) {
      return super.onError(err, handler);
    }

    try {
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newAccessToken';
      final response = await _dio.fetch(opts);
      return handler.resolve(response);
    } on DioException catch (retryErr) {
      // The retry failed on its own merits; report that, not the original 401.
      return super.onError(retryErr, handler);
    }
  }
}
