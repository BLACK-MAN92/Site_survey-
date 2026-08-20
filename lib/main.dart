import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/services/error_reporting.dart';
import 'core/services/background_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error reporting
  await ErrorReportingService.initialize();

  // Initialize background sync
  final bgSync = BackgroundSyncService();
  await bgSync.initialize();
  bgSync.registerPeriodicSync();

  runApp(const ProviderScope(child: SiteSurveyApp()));
}

class SiteSurveyApp extends ConsumerWidget {
  const SiteSurveyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Site Survey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        // High contrast for outdoor use
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xff0D47A1),
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router,
    );
  }
}
