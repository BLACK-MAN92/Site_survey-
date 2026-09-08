import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/site_provider.dart';
import 'home_screen.dart'
    show
        isPostSurveyEligible,
        postSurveyBlockedReason,
        needsRework,
        reworkReasonLabel,
        reworkSurveyType;

class SiteDetailScreen extends ConsumerWidget {
  final String siteId;
  const SiteDetailScreen({super.key, required this.siteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final siteAsyncValue = ref.watch(siteDetailsProvider(siteId));

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA), // Soft background color
      body: siteAsyncValue.when(
        data: (site) {
          if (site.isEmpty) {
            return const Center(child: Text('Site not found'));
          }
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Site: $siteId',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, textBaseline: TextBaseline.alphabetic, shadows: [Shadow(color: Colors.black45, blurRadius: 4)]),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff0D47A1), Color(0xff1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.cell_tower, size: 80, color: Colors.white24),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModernInfoCard(site),
                      if (needsRework(site)) ...[
                        const SizedBox(height: 16),
                        _buildReworkBanner(site),
                      ],
                      const SizedBox(height: 32),
                      const Text(
                        'Actions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xff2C3E50)),
                      ),
                      const SizedBox(height: 16),
                      // Post-survey stays disabled until the site's pre-survey
                      // has been approved. This screen has its own buttons, so
                      // it must apply the same rule as the dashboard list —
                      // otherwise it is a way around the gate.
                      Builder(
                        builder: (context) {
                          final postReady = isPostSurveyEligible(site);
                          final pre = _buildActionButton(
                            context, 'Start Pre-Survey', Icons.assignment,
                            '/site/$siteId/pre-survey', const Color(0xff0D47A1),
                            // Forward the IHS code so the watermark stamp shows
                            // e.g. NG-LAG-001 rather than a MongoDB hex id.
                            extra: {'ihsSiteId': site['siteId'] ?? siteId},
                          );
                          final post = _buildActionButton(
                            context, 'Start Post-Survey', Icons.check_circle,
                            '/site/$siteId/post-survey', const Color(0xff388E3C),
                            extra: {'ihsSiteId': site['siteId'] ?? siteId},
                            enabled: postReady,
                          );

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxWidth > 600) {
                                return Row(
                                  children: [
                                    Expanded(child: pre),
                                    const SizedBox(width: 16),
                                    Expanded(child: post),
                                  ],
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [pre, const SizedBox(height: 16), post],
                              );
                            },
                          );
                        },
                      ),
                      if (!isPostSurveyEligible(site))
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.lock_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Post-survey locked. ${postSurveyBlockedReason(site)}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  /// The reviewer's verdict, stated before the action buttons.
  ///
  /// Reopening the survey form is the correct response to a rejection, so the
  /// buttons stay live — this says which one to press and what to fix.
  Widget _buildReworkBanner(Map<String, dynamic> site) {
    final isPost = reworkSurveyType(site) == 'post';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.replay, color: Colors.orange.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${isPost ? 'Post' : 'Pre'}-survey sent back for rework',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reworkReasonLabel(site),
                  style: TextStyle(color: Colors.orange.shade900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start the ${isPost ? 'post' : 'pre'}-survey again below. '
                  'Your new submission goes back to the back office for review.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade900.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(Map<String, dynamic> site) {
    final bool isOnAir = site['operationalStatus']?.toString().toLowerCase() == 'on air';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOnAir ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isOnAir ? Icons.check_circle : Icons.warning,
                    color: isOnAir ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Operational Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      site['operationalStatus'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xff2C3E50)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildMetric('Zone', site['zone'], Icons.map),
                _buildMetric('State', site['state'], Icons.location_on),
                _buildMetric('SMC', site['smc'], Icons.business),
                _buildMetric('Phase', site['projectPhase'], Icons.layers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, dynamic value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            Text(value?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff2C3E50))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    Color color, {
    bool enabled = true,
    Map<String, dynamic>? extra,
  }) {
    return ElevatedButton.icon(
      icon: Icon(enabled ? icon : Icons.lock_outline, size: 24),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade300,
        disabledForegroundColor: Colors.grey.shade600,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // A null callback is what actually disables the button; greying it out
      // alone would still let the route be pushed.
      onPressed: enabled ? () => context.push(route, extra: extra) : null,
    );
  }
}
