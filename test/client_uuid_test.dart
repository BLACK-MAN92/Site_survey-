import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:site_survey/presentation/providers/pre_survey_provider.dart';

/// The API validates clientUuid with `z.string().uuid()`. The app previously
/// sent `uuid-<millis>` (and defaulted to the literal `new-uuid`), so every
/// pre-survey submission was rejected with 400 before it reached any business
/// rule. This pins the format.
final _uuidV4 = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
  caseSensitive: false,
);

void main() {
  test('a fresh survey gets a real v4 UUID, not a placeholder', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final uuid = container.read(preSurveyProvider).clientUuid;

    expect(uuid, matches(_uuidV4));
    expect(uuid, isNot('new-uuid'));
    expect(uuid.startsWith('uuid-'), isFalse);
  });

  test('initialize without an id mints a valid one', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(preSurveyProvider.notifier).initialize('site-123');
    final state = container.read(preSurveyProvider);

    expect(state.siteId, 'site-123');
    expect(state.clientUuid, matches(_uuidV4));
  });

  test('initialize preserves an explicit id so a resumed draft keeps identity', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const existing = '123e4567-e89b-42d3-a456-426614174000';
    container.read(preSurveyProvider.notifier).initialize('site-123', existing);

    expect(container.read(preSurveyProvider).clientUuid, existing);
  });
}
