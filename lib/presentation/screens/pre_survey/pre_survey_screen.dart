import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pre_survey_provider.dart';
import '../camera/camera_overlay_screen.dart';
import '../shared/out_of_fence_dialog.dart';
import '../shared/photo_grid.dart';

class PreSurveyScreen extends ConsumerStatefulWidget {
  final String siteId;

  const PreSurveyScreen({super.key, required this.siteId});

  @override
  ConsumerState<PreSurveyScreen> createState() => _PreSurveyScreenState();
}

class _PreSurveyScreenState extends ConsumerState<PreSurveyScreen> {
  int _currentStep = 0;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(preSurveyProvider.notifier).initialize(widget.siteId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _openCamera() async {
    final state = ref.read(preSurveyProvider);
    if (state.photos.length >= kMaximumPhotos) {
      _toast('Maximum of $kMaximumPhotos photos reached.');
      return;
    }

    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CameraOverlayScreen(
          title: 'Before photo ${state.photos.length + 1} '
              'of at least $kMinimumPhotos',
        ),
      ),
    );

    if (path == null || !mounted) return;
    // Compression and upload run in the background; the engineer carries on.
    ref.read(preSurveyProvider.notifier).addPhoto(path);
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
    final state = ref.watch(preSurveyProvider);
    final notifier = ref.read(preSurveyProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Pre-Survey')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _submitForm();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep -= 1);
        },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 3;
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
          _buildHeaderStep(state, notifier),
          _buildWorkItemsStep(state, notifier),
          _buildPhotosStep(state, notifier),
          _buildReviewStep(state),
        ],
      ),
    );
  }

  Step _buildHeaderStep(PreSurveyState state, PreSurveyNotifier notifier) {
    return Step(
      title: const Text('Header Information'),
      isActive: _currentStep >= 0,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Site ID: ${state.siteId}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(state.plannedDate == null
                ? 'Select Planned Date'
                : 'Planned Date: ${state.plannedDate.toString().split(' ')[0]}'),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                notifier.updateHeader(date, _commentController.text);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => notifier.updateHeader(state.plannedDate, v),
          ),
          _GpsBanner(fix: state.openFix),
        ],
      ),
    );
  }

  Step _buildWorkItemsStep(PreSurveyState state, PreSurveyNotifier notifier) {
    return Step(
      title: const Text('Work Items'),
      isActive: _currentStep >= 1,
      content: Column(
        children: kWorkItems.map((key) {
          return SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(kWorkItemLabels[key]!),
            subtitle: const Text('Required at this site?'),
            value: state.requiredWorkItems[key] ?? false,
            onChanged: (v) => notifier.setWorkItemRequired(key, v),
          );
        }).toList(),
      ),
    );
  }

  Step _buildPhotosStep(PreSurveyState state, PreSurveyNotifier notifier) {
    return Step(
      title: const Text('Photos (Min $kMinimumPhotos)'),
      isActive: _currentStep >= 2,
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
            label: 'Open camera to capture site photos. '
                'Minimum of $kMinimumPhotos required.',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera'),
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

  Step _buildReviewStep(PreSurveyState state) {
    final required = state.requiredWorkItems.entries
        .where((e) => e.value)
        .map((e) => kWorkItemLabels[e.key]!)
        .toList();

    return Step(
      title: const Text('Review & Submit'),
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please review your data before submitting.',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _reviewRow('Site', state.siteId),
          _reviewRow(
            'Planned date',
            state.plannedDate?.toString().split(' ')[0] ?? 'Not set',
          ),
          _reviewRow(
            'Required work items',
            required.isEmpty ? 'None' : required.join(', '),
          ),
          _reviewRow(
            'Photos attached',
            '${state.uploadedCount} uploaded of ${state.photos.length} taken',
          ),
          const SizedBox(height: 12),
          if (state.uploadedCount < kMinimumPhotos)
            _warning('Minimum $kMinimumPhotos uploaded photos required.'),
          if (state.hasFailedUploads)
            _warning('Some photos failed to upload. Retry them in the '
                'Photos step — the survey cannot be submitted without them.'),
          if (state.error != null) _warning(state.error!),
        ],
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _warning(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    final notifier = ref.read(preSurveyProvider.notifier);

    try {
      final id = await notifier.submit();
      if (!mounted) return;
      _toast('Survey submitted. Reference $id');
      Navigator.of(context).pop();
    } on OutOfFenceReasonRequired catch (e) {
      if (!mounted) return;

      // Outside the fence is a normal field situation — a wrong site
      // coordinate, or access only from the gate. The API just needs it stated.
      final reason = await showOutOfFenceDialog(context, e.message);
      if (reason == null || !mounted) return;

      notifier.setOutOfFenceReason(reason);
      await _submitForm();
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString(), error: true);
    }
  }
}

class _GpsBanner extends StatelessWidget {
  final dynamic fix;
  const _GpsBanner({required this.fix});

  @override
  Widget build(BuildContext context) {
    final ok = fix != null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(ok ? Icons.gps_fixed : Icons.gps_off,
              size: 16, color: ok ? Colors.green : Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              ok
                  ? 'Location fixed (±${fix.accuracyM.toStringAsFixed(0)}m)'
                  : 'Waiting for a GPS fix — needed to submit.',
              style: TextStyle(
                fontSize: 12,
                color: ok ? Colors.green.shade700 : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}