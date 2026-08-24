import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_interceptor.dart';
import 'auth_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  // Defaults to the deployed API so a fresh install works with no setup.
  //
  // Point at a local backend with:
  //   flutter run --dart-define=API_URL=http://<your-lan-ip>:3000/api/v1
  // A phone or emulator cannot reach the host's localhost, so a LAN address is
  // required there; on web, http://localhost:3000/api/v1 works.
  const baseUrlEnv = String.fromEnvironment('API_URL', defaultValue: '');
  const remoteUrl = 'https://site-survey-api.vercel.app/api/v1';

  // Trailing slashes would produce '//sites' once Dio appends a path.
  final resolved = (baseUrlEnv.isNotEmpty ? baseUrlEnv : remoteUrl)
      .replaceAll(RegExp(r'/+$'), '');

  final dio = Dio(BaseOptions(
    baseUrl: resolved,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Add the auth interceptor to attach JWT tokens to requests
  final authStorage = ref.watch(authStorageProvider);
  dio.interceptors.add(AuthInterceptor(authStorage, dio));

  // Add logging in debug mode
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ));

  return dio;
});
