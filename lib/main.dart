import 'package:flutter/material.dart';
import 'package:syzygy_ui_flutter/syzygy_ui_flutter.dart';

import 'core/constants/app_constants.dart';
import 'di/app_module.dart';
import 'navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDI();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: AppRouter.router,
      builder: (context, child) => SyzygyThemeProvider(
        theme: SyzygyTheme.defaultTheme,
        builder: (context, setTheme) => child ?? const SizedBox.shrink(),
      ),
    );
  }
}
