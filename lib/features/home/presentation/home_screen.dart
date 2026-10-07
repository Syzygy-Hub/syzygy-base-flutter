import 'package:flutter/material.dart';
import 'package:syzygy_ui_flutter/syzygy_ui_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';

/// Landing screen shown once the user is signed in.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onLogout});

  /// Called when the user taps the logout button. The caller (e.g. [AppRouter])
  /// is responsible for signing out and navigating to the login route.
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: onLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Welcome!', style: context.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppConstants.appName,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
