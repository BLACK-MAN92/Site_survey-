import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ErrorReportingService {
  static Future<void> initialize() async {
    // Note: requires valid google-services.json to compile successfully on Android
    // await Firebase.initializeApp();
    
    // Pass all uncaught "fatal" errors from the framework to Crashlytics
    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    /*
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };
    */
    
    /*
    await SentryFlutter.init(
      (options) {
        options.dsn = 'YOUR_SENTRY_DSN_HERE';
        options.tracesSampleRate = 1.0;
      },
    );
    */
  }

  static void logBreadcrumb(String message, {Map<String, dynamic>? data}) {
    // Add to Firebase Crashlytics
    // FirebaseCrashlytics.instance.log(message);
    
    // Add to Sentry
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      data: data,
    ));
    
    debugPrint('BREADCRUMB: $message');
  }

  static void reportHandledError(dynamic exception, StackTrace stackTrace, {String? reason}) {
    // FirebaseCrashlytics.instance.recordError(exception, stackTrace, reason: reason);
    Sentry.captureException(exception, stackTrace: stackTrace);
    debugPrint('HANDLED ERROR: $reason -> $exception');
  }
}
