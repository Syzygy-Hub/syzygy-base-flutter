import 'package:flutter/material.dart';
// import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';
// import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';
import '../../di/app_module.dart';

// TODO: Implement SettingsScreen
// Resolve from DI container:
//   final authProvider = appContainer.resolve<TokenAuthProvider>();
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(child: Text('Settings — coming soon')),
    );
  }
}
