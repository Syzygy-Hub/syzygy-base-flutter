import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../di/app_module.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/home/presentation/home_screen.dart';

/// Route path constants, kept in one place so string literals never leak
/// into feature code.
abstract final class AppRoutes {
  static const login = '/login';
  static const home = '/';
}

/// App-wide [GoRouter] configuration.
///
/// Auth gating is done via [redirect], which checks for a persisted access
/// token through [AppModule.secureStorage]. Feature screens should not need
/// to know about auth state to decide whether to render.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder:
            (context, state) => LoginScreen(
              onLoginSuccess: () {
                final ctx = rootNavigatorKey.currentContext;
                if (ctx != null) GoRouter.of(ctx).go(AppRoutes.home);
              },
            ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Route not found: ${state.uri}')),
        ),
  );

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final token = await AppModule.instance.secureStorage.readAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
    if (isLoggedIn && isLoggingIn) return AppRoutes.home;
    return null;
  }
}
