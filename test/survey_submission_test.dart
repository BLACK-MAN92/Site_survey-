import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_survey/data/api/photo_api.dart';
import 'package:site_survey/presentation/providers/captured_photo.dart';
import 'package:site_survey/presentation/providers/geo_fix.dart';
import 'package:site_survey/presentation/providers/post_survey_provider.dart';
import 'package:site_survey/presentation/providers/pre_survey_provider.dart';

GeoFix fix({double lat = 6.5244, double lng = 3.3792}) => GeoFix(
      lat: lat,
      lng: lng,
      accuracyM: 8,
      altitude: 12,
      provider: 'gps',
      capturedAt: DateTime.utc(2026, 8, 24, 10, 30),
    );

UploadedPhoto stored(String id) => UploadedPhoto(
      publicId: 'site-surveys/abc/$id',
      url: 'https://res.cloudinary.com/demo/image/upload/$id.jpg',
      category: 'before',
      width: 2560,
      height: 1920,
      bytes: 640000,
      originalBytes: 4200000,
      format: 'jpg',
    );

void main() {
  group('pre-survey payload', () {
    late ProviderContainer container;
    late PreSurveyNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(preSurveyProvider.notifier);
      notifier.initialize('site-db-id-1');
    });

    tearDown(() => container.dispose());

    test('carries every work item, because the API rejects a partial list', () {
      notifier.setWorkItemRequired('janitorial', true);

      final payload = notifier.buildPayload(fix());
      final items = payload['workItems'] as List;

      expect(items.length, kWorkItems.length);
      expect(
        items.firstWhere((i) => i['key'] == 'janitorial')['required'],
        isTrue,
      );
      expect(
        items.firstWhere((i) => i['key'] == 'granite')['required'],
        isFalse,
      );
    });

    test('never sets progress, which the API refuses on a pre-survey item', () {
      notifier.setWorkItemRequired('granite', true);

      final items = notifier.buildPayload(fix())['workItems'] as List;

      expect(items.every((i) => !i.containsKey('progress')), isTrue);
    });

    test('sends both geo fixes as ISO-8601 instants', () {
      final payload = notifier.buildPayload(fix());
      final geo = payload['geo'] as Map;

      expect(geo['openFix'], isNotNull);
      expect(geo['submitFix'], isNotNull);
      expect(
        (geo['submitFix'] as Map)['capturedAt'],
        '2026-08-24T10:30:00.000Z',
      );
    });

    test('falls back to the submit fix when no opening fix was taken', () {
      final payload = notifier.buildPayload(fix(lat: 9.05, lng: 7.49));
      final geo = payload['geo'] as Map;

      expect((geo['openFix'] as Map)['lat'], 9.05);
    });

    test('omits outOfFenceReason until one is chosen', () {
      expect((notifier.buildPayload(fix())['geo'] as Map)
          .containsKey('outOfFenceReason'), isFalse);

      notifier.setOutOfFenceReason('site_coordinate_incorrect');

      expect((notifier.buildPayload(fix())['geo'] as Map)['outOfFenceReason'],
          'site_coordinate_incorrect');
    });

    test('a clientUuid is a real uuid so idempotent replay works', () {
      final payload = notifier.buildPayload(fix());

      expect(
        payload['clientUuid'],
        matches(RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
      );
    });
  });

  group('pre-survey submission gate', () {
    late ProviderContainer container;
    late PreSurveyNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(preSurveyProvider.notifier);
      notifier.initialize('site-db-id-1');
    });

    tearDown(() => container.dispose());

    /// The survey document stores Cloudinary links, so a photo that only
    /// exists on the phone is not evidence — submission has to wait for it.
    test('blocks submission while a photo is not yet uploaded', () {
      final photos = [
        for (var i = 0; i < kMinimumPhotos; i++)
          CapturedPhoto(
            localPath: '/tmp/$i.jpg',
            category: 'before',
            status: PhotoUploadStatus.uploaded,
            uploaded: stored('$i'),
          ),
        const CapturedPhoto(localPath: '/tmp/pending.jpg', category: 'before'),
      ];

      final state = PreSurveyState(
        siteId: 's',
        clientUuid: 'u',
        photos: photos,
      );

      expect(state.uploadedCount, kMinimumPhotos);
      expect(state.canSubmit, isFalse);
    });

    test('blocks submission below the photo minimum', () {
      final state = PreSurveyState(
        siteId: 's',
        clientUuid: 'u',
        photos: [
          for (var i = 0; i < kMinimumPhotos - 1; i++)
            CapturedPhoto(
              localPath: '/tmp/$i.jpg',
              category: 'before',
              status: PhotoUploadStatus.uploaded,
              uploaded: stored('$i'),
            ),
        ],
      );

      expect(state.canSubmit, isFalse);
    });

    test('allows submission once every photo is stored', () {
      final state = PreSurveyState(
        siteId: 's',
        clientUuid: 'u',
        photos: [
          for (var i = 0; i < kMinimumPhotos; i++)
            CapturedPhoto(
              localPath: '/tmp/$i.jpg',
              category: 'before',
              status: PhotoUploadStatus.uploaded,
              uploaded: stored('$i'),
            ),
        ],
      );

      expect(state.canSubmit, isTrue);
    });

    test('a failed upload is surfaced rather than silently skipped', () {
      final state = PreSurveyState(
        siteId: 's',
        clientUuid: 'u',
        photos: const [
          CapturedPhoto(
            localPath: '/tmp/0.jpg',
            category: 'before',
            status: PhotoUploadStatus.failed,
            error: 'The upload timed out.',
          ),
        ],
      );

      expect(state.hasFailedUploads, isTrue);
      expect(state.canSubmit, isFalse);
    });
  });

  group('attachment payload', () {
    test('carries the Cloudinary id and url the survey document requires', () {
      final json = stored('abc').toAttachmentJson();

      expect(json['public_id'], 'site-surveys/abc/abc');
      expect(json['url'], startsWith('https://res.cloudinary.com/'));
      expect(json['category'], 'before');
      expect(json['width'], 2560);
      expect(json['originalBytes'], 4200000);
    });

    test('omits a work item key when the photo is not tied to one', () {
      expect(stored('abc').toAttachmentJson().containsKey('workItemKey'),
          isFalse);
    });

    test('reads the API response shape verbatim', () {
      final photo = UploadedPhoto.fromJson({
        'public_id': 'site-surveys/s/u/after/xyz',
        'url': 'https://res.cloudinary.com/demo/image/upload/xyz.jpg',
        'category': 'after',
        'workItemKey': 'janitorial',
        'width': 1920,
        'height': 1080,
        'bytes': 400000,
        'originalBytes': 3000000,
        'format': 'jpg',
      });

      expect(photo.publicId, 'site-surveys/s/u/after/xyz');
      expect(photo.workItemKey, 'janitorial');
      expect(photo.toAttachmentJson()['workItemKey'], 'janitorial');
    });
  });

  group('post-survey', () {
    late ProviderContainer container;
    late PostSurveyNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(postSurveyProvider.notifier);
      notifier.initialize('site-db-id-1', {
        'janitorial': true,
        'granite': false,
        'security_light': true,
      });
    });

    tearDown(() => container.dispose());

    test('reports only items that are in scope', () {
      notifier.setProgress('janitorial', 'Closed');
      notifier.setProgress('security_light', 'WIP');

      final items = notifier.buildPayload(fix())['workItems'] as List;

      expect(items.map((i) => i['key']), ['janitorial', 'security_light']);
    });

    test('unplanned work is sent as required, or the API rejects its progress',
        () {
      notifier.addUnplanned('granite');

      final items = notifier.buildPayload(fix())['workItems'] as List;
      final granite = items.firstWhere((i) => i['key'] == 'granite');

      expect(granite['required'], isTrue);
      expect(granite['progress'], 'WIP');
    });

    test('overall status is Closed only when every in-scope item is Closed', () {
      notifier.setProgress('janitorial', 'Closed');
      expect(container.read(postSurveyProvider).overallStatus, 'WIP');

      notifier.setProgress('security_light', 'Closed');
      expect(container.read(postSurveyProvider).overallStatus, 'Closed');
    });

    test('a closed security light must state how many units were replaced', () {
      notifier.setProgress('janitorial', 'Closed');
      notifier.setProgress('security_light', 'Closed');

      expect(notifier.validationError(), contains('security lights replaced'));

      notifier.setQtyReplaced('security_light', 3);

      // The photo minimum is the next thing standing in the way, which proves
      // the security-light rule stopped objecting.
      expect(notifier.validationError(), contains('after-photos'));
    });

    test('progress must be set on every in-scope item', () {
      expect(notifier.validationError(), contains('Set progress'));
    });

    test('after-photos are categorised as after', () {
      final state = container.read(postSurveyProvider);
      expect(state.items.where((i) => i.isInScope).length, 2);
    });
  });
}
