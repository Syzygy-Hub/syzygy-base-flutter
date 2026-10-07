import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Authenticated is a Foundation auth-state type; services does not re-export it.
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show Authenticated;
import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';

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
/// Auth gating is done via [redirect], which checks for an active session
/// through [TokenAuthProvider]. Feature screens should not need to know
/// about auth state to decide whether to render.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: kDebugMode,
    redirect: _redirect,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () {
            final ctx = rootNavigatorKey.currentContext;
            if (ctx != null) GoRouter.of(ctx).go(AppRoutes.home);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => HomeScreen(
          onLogout: () {
            final authProvider = appContainer.resolve<TokenAuthProvider>();
            authProvider.signOut();
            final ctx = rootNavigatorKey.currentContext;
            if (ctx != null) GoRouter.of(ctx).go(AppRoutes.login);
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route not found: ${state.uri}')),
    ),
  );

  static Future<String?> _redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final authProvider = appContainer.resolve<TokenAuthProvider>();
    final isLoggedIn = authProvider.state is Authenticated;
    final isLoggingIn = state.matchedLocation == AppRoutes.login;

    if (!isLoggedIn && !isLoggingIn) return AppRoutes.login;
    if (isLoggedIn && isLoggingIn) return AppRoutes.home;
    return null;
  }
}
