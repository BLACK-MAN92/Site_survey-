import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Represents the state for a single work item
class WorkItemState {
  final String key;
  final bool isRequired;
  final String? progress; // 'WIP' or 'Closed'
  final bool isUnplanned;
  final int? qtyReplaced;

  WorkItemState({
    required this.key,
    required this.isRequired,
    this.progress,
    this.isUnplanned = false,
    this.qtyReplaced,
  });

  WorkItemState copyWith({
    String? progress,
    bool? isUnplanned,
    int? qtyReplaced,
  }) {
    return WorkItemState(
      key: key,
      isRequired: isRequired,
      progress: progress ?? this.progress,
      isUnplanned: isUnplanned ?? this.isUnplanned,
      qtyReplaced: qtyReplaced ?? this.qtyReplaced,
    );
  }
}

class PostSurveyScreen extends ConsumerStatefulWidget {
  final String siteId;
  final Map<String, bool> preSurveyScope;

  const PostSurveyScreen({
    super.key,
    required this.siteId,
    required this.preSurveyScope,
  });

  @override
  ConsumerState<PostSurveyScreen> createState() => _PostSurveyScreenState();
}

class _PostSurveyScreenState extends ConsumerState<PostSurveyScreen> {
  int _currentStep = 0;
  final List<WorkItemState> _items = [];

  final Map<String, String> _labels = {
    'janitorial': 'Janitorial',
    'granite': 'Granite',
    'concrete_resurfacing': 'Concrete Resurfacing',
    'palisade_gate': 'Palisade & Gate',
    'razor_coil': 'Razor Coil',
    'awl': 'AWL',
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
    // Initialize items based on pre-survey scope
    widget.preSurveyScope.forEach((key, isRequired) {
      _items.add(WorkItemState(key: key, isRequired: isRequired));
    });
  }

  void _updateProgress(String key, String status) {
    setState(() {
      final idx = _items.indexWhere((i) => i.key == key);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(progress: status);
      }
    });
  }

  void _addUnplannedItem(String key) {
    setState(() {
      final idx = _items.indexWhere((i) => i.key == key);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(isUnplanned: true, progress: 'WIP');
      }
    });
  }

  // Enforces Rule R-2: Overall status is Closed ONLY if all required items are Closed
  String _calculateOverallStatus() {
    bool allClosed = true;
    for (final item in _items) {
      if ((item.isRequired || item.isUnplanned) && item.progress != 'Closed') {
        allClosed = false;
        break;
      }
    }
    return allClosed ? 'Closed' : 'WIP';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post-Survey')),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) setState(() => _currentStep++);
        },
        onStepCancel: () {
          if (_currentStep > 0) setState(() => _currentStep--);
        },
        steps: [_buildWorkItemsStep(), _buildPhotosStep(), _buildReviewStep()],
      ),
    );
  }

  Step _buildWorkItemsStep() {
    return Step(
      title: const Text('Work Progress'),
      isActive: _currentStep >= 0,
      content: Column(
        children: _items.map((item) {
          if (!item.isRequired && !item.isUnplanned) {
            // Render collapsed read-only UI for not-required items
            return ExpansionTile(
              title: Text(_labels[item.key]!),
              subtitle: const Text('Not Required at Pre-Survey'),
              children: [
                TextButton(
                  onPressed: () => _addUnplannedItem(item.key),
                  child: const Text('Add as Unplanned Work'),
                ),
              ],
            );
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _labels[item.key]!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (item.isUnplanned)
                    const Text(
                      'VARIATION (Unplanned)',
                      style: TextStyle(color: Colors.orange),
                    ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'WIP', label: Text('WIP')),
                      ButtonSegment(value: 'Closed', label: Text('Closed')),
                    ],
                    selected: {item.progress ?? 'WIP'},
                    onSelectionChanged: (set) =>
                        _updateProgress(item.key, set.first),
                  ),
                  if (item.key == 'security_light' && item.progress == 'Closed')
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Qty Replaced (Required)',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final qty = int.tryParse(val);
                        final idx = _items.indexWhere((i) => i.key == item.key);
                        _items[idx] = _items[idx].copyWith(qtyReplaced: qty);
                      },
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Step _buildPhotosStep() {
    return Step(
      title: const Text('After Photos'),
      isActive: _currentStep >= 1,
      content: Semantics(
        button: true,
        label:
            'Open camera with before-photo overlay to capture matching angle. Minimum of 5 required.',
        child: ElevatedButton(
          onPressed: () {
            // Navigate to camera with ghost overlay feature
          },
          child: const Text('Open Camera with Before-Overlay'),
        ),
      ),
    );
  }

  Step _buildReviewStep() {
    final overallStatus = _calculateOverallStatus();
    return Step(
      title: const Text('Review'),
      isActive: _currentStep >= 2,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Derived Overall Status: $overallStatus',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (overallStatus == 'WIP')
            const Text(
              'Note: Status coerced to WIP because not all required items are Closed.',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
