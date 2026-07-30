import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'design_system/app_colors.dart';
import 'design_system/app_typography.dart';
import 'di/app_module.dart';
import 'navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppModule.instance.init(
    apiBaseUrl: const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://api.example.com',
    ),
    enableNetworkLogging: !const bool.fromEnvironment('dart.vm.product'),
  );

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.lightScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.lightBackground,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: AppColors.darkScheme,
        textTheme: AppTypography.textTheme,
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),
      routerConfig: AppRouter.router,
    );
  }
}
