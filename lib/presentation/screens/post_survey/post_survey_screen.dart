import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/post_survey_provider.dart';
import '../../providers/pre_survey_provider.dart'
    show
        OutOfFenceReasonRequired,
        kMinimumPhotos,
        kMaximumPhotos,
        kWorkItemLabels,
        preSurveyProvider;
import '../camera/camera_overlay_screen.dart';
import '../shared/out_of_fence_dialog.dart';
import '../../providers/site_provider.dart';
import '../shared/photo_grid.dart';

class PostSurveyScreen extends ConsumerStatefulWidget {
  /// MongoDB _id — used for API calls (route param).
  final String siteId;
  final Map<String, bool> preSurveyScope;

  /// IHS business code, e.g. NG-LAG-001 — shown on the stamp.
  final String ihsSiteId;

  const PostSurveyScreen({
    super.key,
    required this.siteId,
    required this.ihsSiteId,
    required this.preSurveyScope,
  });

  @override
  ConsumerState<PostSurveyScreen> createState() => _PostSurveyScreenState();
}

class _PostSurveyScreenState extends ConsumerState<PostSurveyScreen> {
  int _currentStep = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSurveyScope.isNotEmpty) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(postSurveyProvider.notifier)
            .initialize(widget.siteId, widget.ihsSiteId, widget.preSurveyScope);
      });
    }
  }

  /// Opens the camera with the matching before-photo ghosted over the preview,
  /// so the after-shot is framed from the same angle.
  Future<void> _openCamera() async {
    final state = ref.read(postSurveyProvider);
    if (state.photos.length >= kMaximumPhotos) {
      _toast('Maximum of $kMaximumPhotos photos reached.');
      return;
    }

    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CameraOverlayScreen(
          beforePhotoPath: _beforePhotoFor(state.photos.length),
          title: 'After photo ${state.photos.length + 1} '
              'of at least $kMinimumPhotos',
        ),
      ),
    );

    if (path == null || !mounted) return;
    ref.read(postSurveyProvider.notifier).addPhoto(path);
  }

  /// The before-photo to ghost, matched by position.
  ///
  /// Returns null when the pre-survey photos are not on this device — a
  /// post-survey can legitimately be done by a different engineer, and the
  /// overlay is an aid, not a requirement.
  String? _beforePhotoFor(int index) {
    final pre = ref.read(preSurveyProvider);
    if (pre.siteId != widget.siteId || index >= pre.photos.length) return null;
    return pre.photos[index].localPath;
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The scope is normally handed in by the caller. When it is not — the site
    // detail screen pushes straight to this route — it is fetched from the
    // site's consolidated view, because a post-survey with no work items to
    // report on is unusable.
    if (!_initialized) {
      return _buildScopeLoader();
    }

    final state = ref.watch(postSurveyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Post-Survey')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _submit();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: state.submitting ? null : details.onStepContinue,
                  child: state.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLast ? 'Submit Survey' : 'Continue'),
                ),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: state.submitting ? null : details.onStepCancel,
                    child: const Text('Back'),
                  ),
              ],
            ),
          );
        },
        steps: [
          _buildWorkItemsStep(state),
          _buildPhotosStep(state),
          _buildReviewStep(state),
        ],
      ),
    );
  }

  Step _buildWorkItemsStep(PostSurveyState state) {
    final notifier = ref.read(postSurveyProvider.notifier);

    return Step(
      title: const Text('Work Progress'),
      isActive: _currentStep >= 0,
      content: Column(
        children: state.items.map((item) {
          final label = kWorkItemLabels[item.key] ?? item.key;

          if (!item.isInScope) {
            return ExpansionTile(
              title: Text(label),
              subtitle: const Text('Not Required at Pre-Survey'),
              children: [
                TextButton(
                  onPressed: () => notifier.addUnplanned(item.key),
                  child: const Text('Add as Unplanned Work'),
                ),
              ],
            );
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(label,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ),
                      if (item.isUnplanned)
                        const Chip(
                          label: Text('Unplanned',
                              style: TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'WIP', label: Text('WIP')),
                      ButtonSegment(value: 'Closed', label: Text('Closed')),
                    ],
                    selected: item.progress == null ? {} : {item.progress!},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (s) {
                      if (s.isNotEmpty) {
                        notifier.setProgress(item.key, s.first);
                      }
                    },
                  ),
                  // BR-3: the API refuses a closed security light without a
                  // replacement count, so it is asked for inline.
                  if (item.key == 'security_light' &&
                      item.progress == 'Closed')
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextFormField(
                        initialValue: item.qtyReplaced?.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Units replaced',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final qty = int.tryParse(v);
                          if (qty != null) {
                            notifier.setQtyReplaced(item.key, qty);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Step _buildPhotosStep(PostSurveyState state) {
    final notifier = ref.read(postSurveyProvider.notifier);

    return Step(
      title: const Text('After Photos'),
      isActive: _currentStep >= 1,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Captured: ${state.photos.length} / $kMaximumPhotos   •   '
            'Uploaded: ${state.uploadedCount}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Open camera with before-photo overlay to capture matching '
                'angle. Minimum of $kMinimumPhotos required.',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera with Before-Overlay'),
              onPressed: _openCamera,
            ),
          ),
          const SizedBox(height: 16),
          PhotoGrid(
            photos: state.photos,
            onRetry: notifier.retryUpload,
            onRemove: notifier.removePhoto,
          ),
        ],
      ),
    );
  }

  Step _buildReviewStep(PostSurveyState state) {
    final problem = ref.read(postSurveyProvider.notifier).validationError();

    return Step(
      title: const Text('Review'),
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Derived Overall Status: ${state.overallStatus}',
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (state.overallStatus == 'WIP')
            const Text(
              'Note: Status is WIP because not all in-scope items are Closed.',
              style: TextStyle(color: Colors.red),
            ),
          const SizedBox(height: 8),
          Text('Photos: ${state.uploadedCount} uploaded of '
              '${state.photos.length} taken'),
          if (problem != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(problem,
                        style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(state.error!,
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }

  Widget _buildScopeLoader() {
    final scope = ref.watch(preSurveyScopeProvider(widget.siteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Post-Survey')),
      body: scope.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading the pre-survey scope…'),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text('$error', textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(preSurveyScopeProvider(widget.siteId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No approved pre-survey was found for this site, so there '
                  'is nothing to report a post-survey against.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Adopting the fetched scope is a state change, so it is deferred out
          // of the build pass rather than done inline.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _initialized) return;
            ref
                .read(postSurveyProvider.notifier)
                .initialize(widget.siteId, widget.ihsSiteId, items);
            setState(() => _initialized = true);
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> _submit() async {
    final notifier = ref.read(postSurveyProvider.notifier);

    try {
      final id = await notifier.submit();
      if (!mounted) return;
      _toast('Post-survey submitted. Reference $id');
      Navigator.of(context).pop();
    } on OutOfFenceReasonRequired catch (e) {
      if (!mounted) return;
      final reason = await showOutOfFenceDialog(context, e.message);
      if (reason == null || !mounted) return;
      notifier.setOutOfFenceReason(reason);
      await _submit();
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString(), error: true);
    }
  }
}
