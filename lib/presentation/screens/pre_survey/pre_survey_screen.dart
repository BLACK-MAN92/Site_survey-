import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/pre_survey_provider.dart';

class PreSurveyScreen extends ConsumerStatefulWidget {
  final String siteId;

  const PreSurveyScreen({super.key, required this.siteId});

  @override
  ConsumerState<PreSurveyScreen> createState() => _PreSurveyScreenState();
}

class _PreSurveyScreenState extends ConsumerState<PreSurveyScreen> {
  int _currentStep = 0;
  final _commentController = TextEditingController();

  final List<String> _workItemsOrder = [
    'janitorial', 'granite', 'concrete_resurfacing', 'palisade_gate',
    'razor_coil', 'awl', 'security_light', 'tank_painting',
    'sg_house_repair', 'fire_extinguisher', 'shelter_repair',
    'cable_management', 'waste_disposal'
  ];

  final Map<String, String> _workItemsLabels = {
    'janitorial': 'Janitorial',
    'granite': 'Granite',
    'concrete_resurfacing': 'Concrete Resurfacing',
    'palisade_gate': 'Palisade & Gate',
    'razor_coil': 'Razor Coil',
    'awl': 'AWL (Aviation Warning Light)',
    'security_light': 'Security Light',
    'tank_painting': 'Tank Painting',
    'sg_house_repair': 'SG House Repair',
    'fire_extinguisher': 'Fire Extinguisher',
    'shelter_repair': 'Shelter Repair',
    'cable_management': 'Cable Management',
    'waste_disposal': 'Waste Disposal',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(preSurveyProvider.notifier).initialize(widget.siteId, 'uuid-${DateTime.now().millisecondsSinceEpoch}');
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(preSurveyProvider);
    final notifier = ref.read(preSurveyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pre-Survey'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _submitForm(state);
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          _buildHeaderStep(state, notifier),
          _buildWorkItemsStep(state, notifier),
          _buildPhotosStep(state),
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
          Text('Site ID: ${state.siteId}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            title: Text(state.plannedDate == null ? 'Select Planned Date' : 'Planned Date: ${state.plannedDate.toString().split(' ')[0]}'),
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
            maxLength: 1000,
            decoration: const InputDecoration(
              labelText: 'Comments',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => notifier.updateHeader(state.plannedDate, val),
          )
        ],
      ),
    );
  }

  Step _buildWorkItemsStep(PreSurveyState state, PreSurveyNotifier notifier) {
    return Step(
      title: const Text('Work Items'),
      isActive: _currentStep >= 1,
      content: Column(
        children: _workItemsOrder.map((key) {
          final isRequired = state.requiredWorkItems[key] ?? false;
          return SwitchListTile(
            title: Text(_workItemsLabels[key]!),
            subtitle: Text(isRequired ? 'Required' : 'Not Required'),
            value: isRequired,
            onChanged: (val) {
              notifier.setWorkItemRequired(key, val);
            },
          );
        }).toList(),
      ),
    );
  }

  Step _buildPhotosStep(PreSurveyState state) {
    return Step(
      title: const Text('Photos (Min 5)'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          Text('Captured: ${state.photoPaths.length} / 20'),
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: 'Open camera to capture site photos. Minimum of 5 required.',
            child: ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Open Camera'),
              onPressed: () {
                // Navigate to custom camera UI
              },
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: state.photoPaths.map((p) => const Icon(Icons.image, size: 50)).toList(),
          )
        ],
      ),
    );
  }

  Step _buildReviewStep(PreSurveyState state) {
    return Step(
      title: const Text('Review & Submit'),
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Please review your data before submitting.', style: TextStyle(fontWeight: FontWeight.bold)),
          if (state.photoPaths.length < 5)
            const Text('ERROR: Minimum 5 photos required.', style: TextStyle(color: Colors.red)),
          // ... render summary table here ...
        ],
      ),
    );
  }

  void _submitForm(PreSurveyState state) {
    if (state.photoPaths.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please capture at least 5 photos.')));
      return;
    }
    // Final check for Geofence and Write to Outbox
    print('Submitting survey to outbox...');
    Navigator.of(context).pop();
  }
}
