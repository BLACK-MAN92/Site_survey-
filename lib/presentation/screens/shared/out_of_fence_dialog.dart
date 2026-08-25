import 'package:flutter/material.dart';

/// Reasons the API accepts for a survey taken outside the site geofence.
/// Keys match the server's OUT_OF_FENCE_REASONS list.
const Map<String, String> kOutOfFenceReasons = {
  'site_coordinate_incorrect': 'The site coordinate on record is wrong',
  'access_blocked_surveyed_from_gate': 'Access blocked — surveyed from the gate',
  'gps_unavailable_indoors': 'GPS unavailable (indoors or heavy cover)',
  'other': 'Other',
};

/// Asks why the survey is being submitted from outside the geofence.
///
/// Returns the chosen reason key, or null if the engineer backed out.
Future<String?> showOutOfFenceDialog(BuildContext context, String message) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String? selected;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Outside the site geofence'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),
                const Text(
                  'Select a reason to submit anyway. It is recorded on the '
                  'survey for the back office to review.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                RadioGroup<String>(
                  groupValue: selected,
                  onChanged: (v) => setState(() => selected = v),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: kOutOfFenceReasons.entries
                        .map(
                          (e) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(e.value,
                                style: const TextStyle(fontSize: 13)),
                            value: e.key,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selected == null
                    ? null
                    : () => Navigator.of(context).pop(selected),
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    },
  );
}
