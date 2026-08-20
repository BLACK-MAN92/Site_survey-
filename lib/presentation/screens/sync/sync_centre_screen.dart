import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock model for UI
class OutboxItem {
  final String clientUuid;
  final String entityType;
  final String status; // Queued, Uploading, Failed, Conflict
  final String? lastError;
  final int attemptCount;

  OutboxItem(
    this.clientUuid,
    this.entityType,
    this.status,
    this.lastError,
    this.attemptCount,
  );
}

class SyncCentreScreen extends ConsumerWidget {
  const SyncCentreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In a real implementation this would watch a StreamProvider from Drift
    final List<OutboxItem> mockQueue = [
      OutboxItem('uuid-1', 'Survey', 'Queued', null, 0),
      OutboxItem('uuid-2', 'Photo', 'Uploading (3/5)', null, 1),
      OutboxItem(
        'uuid-3',
        'Survey',
        'Failed',
        'Timeout connecting to server',
        5,
      ),
      OutboxItem('uuid-4', 'Survey', 'Conflict', 'DUPLICATE_SURVEY', 1),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Centre'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Trigger sync engine manually
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Manual sync started...')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockQueue.length,
        itemBuilder: (context, index) {
          final item = mockQueue[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: _getIconForStatus(item.status),
              title: Text('${item.entityType} Sync'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${item.status}'),
                  if (item.lastError != null)
                    Text(
                      'Error: ${item.lastError}',
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
              trailing: item.status == 'Failed' || item.status == 'Conflict'
                  ? IconButton(
                      icon: const Icon(Icons.warning, color: Colors.orange),
                      onPressed: () => _showErrorDialog(context, item),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Icon _getIconForStatus(String status) {
    if (status == 'Queued')
      return const Icon(Icons.schedule, color: Colors.blue);
    if (status.contains('Uploading'))
      return const Icon(Icons.cloud_upload, color: Colors.blue);
    if (status == 'Failed') return const Icon(Icons.error, color: Colors.red);
    if (status == 'Conflict')
      return const Icon(Icons.rule, color: Colors.orange);
    return const Icon(Icons.check, color: Colors.green);
  }

  void _showErrorDialog(BuildContext context, OutboxItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Action Required'),
        content: Text(
          item.status == 'Conflict'
              ? 'This survey was already submitted by another device. Discard?'
              : 'Failed to sync after ${item.attemptCount} attempts. Error: ${item.lastError}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Action: Discard or Retry
            },
            child: Text(item.status == 'Conflict' ? 'Discard' : 'Retry Now'),
          ),
        ],
      ),
    );
  }
}
