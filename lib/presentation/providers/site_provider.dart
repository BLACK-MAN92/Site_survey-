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
