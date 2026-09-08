import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/login_screen.dart';
import '../presentation/screens/register_screen.dart';
import '../presentation/screens/splash_screen.dart';
import '../presentation/screens/site_detail_screen.dart';
import '../presentation/screens/pre_survey/pre_survey_screen.dart';
import '../presentation/screens/post_survey/post_survey_screen.dart';
import '../presentation/screens/camera/camera_overlay_screen.dart';
import '../presentation/screens/sync/sync_centre_screen.dart';
import '../presentation/providers/auth_provider.dart';

final routerNotifierProvider = Provider<ValueNotifier<bool>>((ref) {
  final notifier = ValueNotifier<bool>(false);
  ref.listen<AuthState>(
    authStateProvider,
    (_, __) {
      notifier.value = !notifier.value;
    },
  );
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStateProvider).isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isSplash = state.matchedLocation == '/splash';

      if (!isLoggedIn && !isLoggingIn && !isRegistering && !isSplash) {
        return '/login';
      }
      if (isLoggedIn && (isLoggingIn || isRegistering || isSplash)) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'site/:id',
            builder: (context, state) {
              final siteId = state.pathParameters['id']!;
              return SiteDetailScreen(siteId: siteId);
            },
            routes: [
              GoRoute(
                path: 'pre-survey',
                builder: (context, state) {
                  final mongoId = state.pathParameters['id']!;
                  // The IHS business code is forwarded via extras by
                  // SiteDetailScreen. Fall back to the mongo id so the
                  // stamp always has something meaningful.
                  final extras = state.extra as Map<String, dynamic>? ?? {};
                  final ihsSiteId = extras['ihsSiteId'] as String? ?? mongoId;
                  return PreSurveyScreen(siteId: mongoId, ihsSiteId: ihsSiteId);
                },
              ),
              GoRoute(
                path: 'post-survey',
                builder: (context, state) {
                  final mongoId = state.pathParameters['id']!;
                  final extras = state.extra as Map<String, dynamic>? ?? {};
                  final ihsSiteId = extras['ihsSiteId'] as String? ?? mongoId;
                  final preSurveyScope =
                      extras['preSurveyScope'] as Map<String, bool>? ?? {};
                  return PostSurveyScreen(
                    siteId: mongoId,
                    ihsSiteId: ihsSiteId,
                    preSurveyScope: preSurveyScope,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'sync',
            builder: (context, state) => const SyncCentreScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraOverlayScreen(),
      ),
    ],
  );
});

// Legacy router for compatibility (will be removed after migration)
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
