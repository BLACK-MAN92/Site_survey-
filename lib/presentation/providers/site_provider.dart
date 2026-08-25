import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api/site_api.dart';

final assignedSitesProvider = FutureProvider<List<dynamic>>((ref) async {
  final siteApi = ref.watch(siteApiProvider);
  return siteApi.getAssignedSites();
});

final siteDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, siteId) async {
  final siteApi = ref.watch(siteApiProvider);
  return siteApi.getSiteDetails(siteId);
});

/// Work items the approved pre-survey scoped for a site, keyed by item with
/// whether it was marked required.
///
/// The post-survey reports against this scope. Reading it from the server
/// rather than from local state matters because a post-survey is often done by
/// a different engineer, on a different device, from the one that did the
/// pre-survey.
final preSurveyScopeProvider =
    FutureProvider.family<Map<String, bool>, String>((ref, siteId) async {
  final consolidated = await ref.watch(siteApiProvider).getConsolidated(siteId);

  final items = consolidated['preSurvey']?['items'];
  if (items is! Map) return {};

  return {
    for (final entry in items.entries)
      entry.key as String: (entry.value is Map &&
          entry.value['required'] == true),
  };
});
