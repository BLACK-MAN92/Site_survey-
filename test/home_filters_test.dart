import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:site_survey/presentation/screens/home_screen.dart';

/// A verbatim GET /sites response for an engineer with two assigned sites.
/// Captured from the running API so the filters are checked against the real
/// field names rather than an assumed shape.
const realResponse = '''
{"data":[
  {"siteId":"IHS_ABI_1032A","name":"Umuomainta Village","coordinates":{"type":"Point","coordinates":[7.3861,5.5486]},
   "assignedEngineerId":"6a885d0f5df910c27168f3e8","mtnId":"ENUABI1032A","state":"Abia","smc":"Aba",
   "lga":"Isiala-Ngwa North","surveyPlanText":null,"surveyPlanDate":null,"implementationPlanText":null,
   "implementationPlanDate":null,"contractorName":null,"contractorPhone":null,"cycleState":"pre_due","preSurveyState":null,"postSurveyEligible":false,
   "createdAt":"2026-08-21T16:20:07.000Z","updatedAt":"2026-08-21T16:55:11.000Z","id":"6a887c77c835fcbdb3270b88"},
  {"siteId":"MEC_012","name":"Manual Entry Site","coordinates":{"type":"Point","coordinates":[3.37,6.52]},
   "assignedEngineerId":"6a885d0f5df910c27168f3e8","mtnId":null,"state":null,"smc":null,"lga":null,
   "surveyPlanText":null,"surveyPlanDate":null,"implementationPlanText":null,"implementationPlanDate":null,
   "contractorName":null,"contractorPhone":null,"cycleState":"pre_due","preSurveyState":null,"postSurveyEligible":false,
   "createdAt":"2026-08-21T16:40:00.000Z","updatedAt":"2026-08-21T16:40:00.000Z","id":"6a888078961fa05e67cf386c"}
]}
''';

void main() {
  final sites = (jsonDecode(realResponse)['data'] as List);

  group('home screen site filters', () {
    test('both assigned sites land in the pre-survey section', () {
      final prePending = sites.where(isPreDue).toList();

      expect(prePending, hasLength(2));
      expect(
        prePending.map((s) => s['siteId']),
        containsAll(['IHS_ABI_1032A', 'MEC_012']),
      );
    });

    test('post-survey and completed sections are empty for pre_due sites', () {
      expect(sites.where(isPostDue), isEmpty);
      expect(sites.where(isClosed), isEmpty);
    });

    test('the old status field does not exist, which is why filtering on it failed', () {
      // Regression guard: every site lacks `status`, so the previous
      // `s['status'] == 'assigned'` filter could never match.
      for (final site in sites) {
        expect(site['status'], isNull);
        expect(site['cycleState'], isNotNull);
      }
    });

    test('subtitle falls back sensibly when state and lga are absent', () {
      expect(siteSubtitle(sites[0]), 'Abia • Isiala-Ngwa North');
      expect(siteSubtitle(sites[1]), 'Manual Entry Site');
    });

    test('cards route by database id, not the I.H.S site code', () {
      // GET /sites/:id takes the Mongo id; siteId would 404.
      expect(sites[0]['id'], '6a887c77c835fcbdb3270b88');
      expect(sites[0]['id'], isNot(equals(sites[0]['siteId'])));
    });
  });

  group('post-survey gating', () {
    test('a site with no approved pre-survey is not eligible', () {
      for (final site in sites) {
        expect(isPostSurveyEligible(site), isFalse);
      }
    });

    test('explains why post-survey is locked', () {
      expect(postSurveyBlockedReason(sites[0]),
          'Pre-survey has not been submitted yet.');
      expect(
        postSurveyBlockedReason({'preSurveyState': 'submitted'}),
        'Pre-survey is awaiting approval.',
      );
      expect(
        postSurveyBlockedReason({'preSurveyState': 'rejected_backoffice'}),
        'Pre-survey was rejected by back-office and needs rework.',
      );
    });

    test('becomes eligible only once the API says so', () {
      final approved = {
        ...sites[0] as Map<String, dynamic>,
        'preSurveyState': 'approved_internal',
        'postSurveyEligible': true,
      };
      expect(isPostSurveyEligible(approved), isTrue);
    });
  });
}
