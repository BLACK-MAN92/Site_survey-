import 'package:dio/dio.dart';
import 'reachability_probe.dart';
import 'dart:math';

class SyncEngine {
  final ReachabilityProbe _probe;
  final Dio _dio;
  bool _isSyncing = false;

  SyncEngine(this._probe, this._dio);

  Future<void> runSync() async {
    if (_isSyncing) return;
    
    final isOnline = await _probe.hasInternetConnection();
    if (!isOnline) {
      print('Sync skipped: No actual internet reachability.');
      return;
    }

    _isSyncing = true;
    try {
      // 1. Fetch pending items from OutboxDao (mocked here)
      // List<OutboxEntity> items = await dao.getItemsToSync();
      // For each item:
      //   await _processQueueItem(item);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _processQueueItem(dynamic item) async {
    int attempts = 0;
    while (attempts < 5) {
      try {
        attempts++;
        final response = await _dio.post(item.endpoint, data: item.payload);
        
        // 200 with Idempotent-Replay means we already synced it, safe to discard
        if (response.statusCode == 200) {
          // dao.deleteItem(item.clientUuid);
          return;
        }

      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final errorCode = e.response?.data?['error']?['code'];

        if (statusCode == 409 && errorCode == 'DUPLICATE_SURVEY') {
          // dao.updateStatus(item.clientUuid, 'Conflict');
          return; // Stop retrying on genuine conflict
        }

        if (errorCode == 'SITE_REASSIGNED') {
          // Discard draft completely
          // dao.deleteItem(item.clientUuid);
          // notify user via local notification
          return;
        }

        // Apply exponential backoff for network or 5xx errors
        final delaySeconds = pow(2, attempts).toInt();
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
    
    // Max attempts reached, mark as Failed
    // dao.updateStatus(item.clientUuid, 'Failed');
  }
}
