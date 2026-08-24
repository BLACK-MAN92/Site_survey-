import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/site_provider.dart';
import '../providers/auth_provider.dart';

/// The API exposes a site's stage as `cycleState`, drawn from CYCLE_STATES.
/// There is no `status` field — filtering on one silently matched nothing.
bool isPreDue(dynamic site) => site['cycleState'] == 'pre_due';
bool isPostDue(dynamic site) => site['cycleState'] == 'post_due';
bool isClosed(dynamic site) => site['cycleState'] == 'closed';

/// A post-survey may only begin once the site's pre-survey has been approved.
/// The API is the authority and rejects submissions that break this rule; the
/// flag it returns lets the UI deactivate the option up front rather than
/// letting an engineer do the work and fail at submission.
bool isPostSurveyEligible(dynamic site) => site['postSurveyEligible'] == true;

/// Human-readable reason a site is not yet open for post-survey.
String postSurveyBlockedReason(dynamic site) {
  final state = site['preSurveyState'];
  if (state == null) return 'Pre-survey has not been submitted yet.';
  switch (state) {
    case 'draft':
      return 'Pre-survey is still a draft.';
    case 'submitted':
      return 'Pre-survey is awaiting approval.';
    case 'rejected_backoffice':
      return 'Pre-survey was rejected by back-office and needs rework.';
    case 'rejected_ihs':
      return 'Pre-survey was rejected by IHS and needs rework.';
    default:
      return 'Pre-survey is not approved yet.';
  }
}

String siteSubtitle(dynamic site) {
  final parts = [site['state'], site['lga']].where((p) => p != null && p != '').toList();
  return parts.isEmpty ? (site['name'] ?? '') : parts.join(' • ');
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showSurveyModal(BuildContext context, List<dynamic> sites) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return _SurveySelectionSheet(sites: sites);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sitesAsyncValue = ref.watch(assignedSitesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => ref.invalidate(assignedSitesProvider),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authStateProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: sitesAsyncValue.when(
        data: (sites) {
          final prePending = sites.where(isPreDue).toList();
          final postPending = sites.where((s) => isPostDue(s) && isPostSurveyEligible(s)).toList();
          final awaitingApproval = sites.where((s) => !isPostSurveyEligible(s) && !isClosed(s)).toList();
          final completed = sites.where(isClosed).toList();

          if (sites.isEmpty) {
            return _buildNoAssignments(ref);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignedSitesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCards(prePending.length, postPending.length, completed.length),
                const SizedBox(height: 24),
                _buildSectionHeader('Ready for Pre-Survey', Icons.assignment_outlined),
                ...prePending.map((s) => _SiteCard(site: s)).toList(),
                if (prePending.isEmpty) _buildEmptyState('No sites pending pre-survey.'),
                
                const SizedBox(height: 24),
                _buildSectionHeader('Ready for Post-Survey', Icons.check_circle_outline),
                ...postPending.map((s) => _SiteCard(site: s)).toList(),
                if (postPending.isEmpty)
                  _buildEmptyState(
                    awaitingApproval.isEmpty
                        ? 'No sites pending post-survey.'
                        : 'No sites are open for post-survey yet. '
                            '${awaitingApproval.length} site(s) are waiting on pre-survey approval.',
                  ),
                const SizedBox(height: 80), // Padding for FAB
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load your sites',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  // Show what actually failed. The previous generic message hid
                  // connection and authentication problems behind one string.
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(assignedSitesProvider),
                    child: const Text('Retry'),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: sitesAsyncValue.hasValue
          ? FloatingActionButton.extended(
              onPressed: () => _showSurveyModal(context, sitesAsyncValue.value ?? []),
              icon: const Icon(Icons.add_task),
              label: const Text('Start Survey'),
              backgroundColor: const Color(0xff0D47A1),
            )
          : null,
    );
  }

  Widget _buildSummaryCards(int pre, int post, int completed) {
    return Row(
      children: [
        Expanded(child: _SummaryCard(title: 'Pre-Survey', count: pre, color: Colors.blue)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(title: 'Post-Survey', count: post, color: Colors.orange)),
        const SizedBox(width: 12),
        Expanded(child: _SummaryCard(title: 'Completed', count: completed, color: Colors.green)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// Distinguishes "no sites assigned to you yet" from a load failure, so an
  /// engineer waiting on an assignment is not left staring at empty sections.
  Widget _buildNoAssignments(WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(assignedSitesProvider),
      child: ListView(
        children: [
          const SizedBox(height: 120),
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'No sites assigned yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'Once an administrator assigns sites to your account they will '
              'appear here. Pull down to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(message, style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic)),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final MaterialColor color;

  const _SummaryCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color.shade700),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SiteCard extends StatelessWidget {
  final dynamic site;
  const _SiteCard({required this.site});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xff0D47A1).withOpacity(0.1),
          child: const Icon(Icons.cell_tower, color: Color(0xff0D47A1)),
        ),
        title: Text(site['siteId'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(siteSubtitle(site)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          // Routes use the database id; siteId is the I.H.S business code and
          // is not what GET /sites/:id accepts.
          context.push('/site/${site['id']}');
        },
      ),
    );
  }
}

class _SurveySelectionSheet extends StatefulWidget {
  final List<dynamic> sites;
  const _SurveySelectionSheet({required this.sites});

  @override
  State<_SurveySelectionSheet> createState() => _SurveySelectionSheetState();
}

class _SurveySelectionSheetState extends State<_SurveySelectionSheet> {
  String _surveyType = 'pre';
  String? _selectedSiteId;

  @override
  Widget build(BuildContext context) {
    final anyPostSurveyReady =
        widget.sites.any((s) => isPostDue(s) && isPostSurveyEligible(s));

    // Falling back protects against the segment being selected before a
    // refresh removed the last eligible site.
    if (_surveyType == 'post' && !anyPostSurveyReady) {
      _surveyType = 'pre';
    }

    final blockedSites =
        widget.sites.where((s) => !isPostSurveyEligible(s) && !isClosed(s)).toList();

    // Filter sites based on selected survey type
    final availableSites = widget.sites.where((s) {
      if (_surveyType == 'pre') return isPreDue(s);
      if (_surveyType == 'post') return isPostDue(s) && isPostSurveyEligible(s);
      return false;
    }).toList();

    // Reset selected site if it's no longer in the available list
    if (_selectedSiteId != null && !availableSites.any((s) => s['id'] == _selectedSiteId)) {
      _selectedSiteId = null;
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start a Survey',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text('Survey Type', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: [
              const ButtonSegment(value: 'pre', label: Text('Pre-Survey')),
              // Deactivated outright when no site has an approved pre-survey,
              // so the option cannot be chosen only to reveal an empty list.
              ButtonSegment(
                value: 'post',
                label: const Text('Post-Survey'),
                enabled: anyPostSurveyReady,
              ),
            ],
            selected: {_surveyType},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                _surveyType = newSelection.first;
              });
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.white,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: const Color(0xff0D47A1),
            ),
          ),
          if (!anyPostSurveyReady) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    blockedSites.isEmpty
                        ? 'Post-survey opens once a pre-survey has been approved.'
                        : 'Post-survey is locked. ${postSurveyBlockedReason(blockedSites.first)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Text('Select Site', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            hint: const Text('Choose a site ID'),
            value: _selectedSiteId,
            items: availableSites.map((site) {
              return DropdownMenuItem<String>(
                value: site['id'],
                child: Text('${site['siteId']} - ${site['state'] ?? 'Unknown state'}'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSiteId = value;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff0D47A1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _selectedSiteId == null
                  ? null
                  : () {
                      Navigator.pop(context); // Close bottom sheet
                      if (_surveyType == 'pre') {
                        context.push('/site/$_selectedSiteId/pre-survey');
                      } else {
                        context.push('/site/$_selectedSiteId/post-survey');
                      }
                    },
              child: const Text('Proceed to Survey', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
