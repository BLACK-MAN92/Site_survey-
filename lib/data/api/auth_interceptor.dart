import 'package:dio/dio.dart';
import 'auth_storage.dart';

class AuthInterceptor extends Interceptor {
  final AuthStorage _authStorage;
  final Dio _dio;

  AuthInterceptor(this._authStorage, this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _authStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await _authStorage.getRefreshToken();
      if (refreshToken != null) {
        try {
          // Attempt to refresh
          final refreshResponse = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final newAccessToken = refreshResponse.data['accessToken'];
          final newRefreshToken = refreshResponse.data['refreshToken'];

          await _authStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          // Retry the original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final response = await _dio.fetch(opts);
          return handler.resolve(response);
        } on DioException catch (refreshErr) {
          if (refreshErr.response?.data?['error']?['code'] == 'TOKEN_REUSE_DETECTED') {
            await _authStorage.clearTokens();
            // In a real app we'd dispatch a logout event here
          }
        }
      }
    }
    return super.onError(err, handler);
  }
}
