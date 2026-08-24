import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_survey/data/api/api_client.dart';

/// A shared APK is built with no --dart-define, so whatever the default
/// resolves to is what every field device will call. This pins it.
void main() {
  test('defaults to the deployed API when no API_URL is defined', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final dio = container.read(dioProvider);

    expect(dio.options.baseUrl, 'https://site-survey-api.vercel.app/api/v1');
  });

  test('the base URL carries no trailing slash', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // A trailing slash would make every request path '//sites'.
    expect(container.read(dioProvider).options.baseUrl.endsWith('/'), isFalse);
  });

  test('it is https, so Android cleartext blocking never applies', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(dioProvider).options.baseUrl, startsWith('https://'));
  });
}
