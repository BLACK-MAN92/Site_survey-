import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'sync_engine.dart';
import 'reachability_probe.dart';

@pragma(
  'vm:entry-point',
) // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("Background Task running: $task");

    try {
      final probe = ReachabilityProbe();
      final dio = Dio();
      final syncEngine = SyncEngine(probe, dio);

      await syncEngine.runSync();
      return Future.value(true);
    } catch (err) {
      print("Background Task failed: $err");
      return Future.value(
        false,
      ); // Indicates failure, might be retried depending on config
    }
  });
}

class BackgroundSyncService {
  static const String _syncTaskName = "com.site_survey.syncTask";

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode:
          false, // Set to true to see notifications when background task fires
    );
  }

  void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      "1", // unique name
      _syncTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType:
            NetworkType.connected, // Only run when connected to a network
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}
