import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boilerplate/di/app_module.dart';
import 'package:boilerplate/main.dart';

void main() {
  const secureStorageChannel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final secureStorageBackingStore = <String, String>{};

  setUp(() async {
    secureStorageBackingStore.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, (call) async {
          final key = (call.arguments as Map?)?['key'] as String?;
          switch (call.method) {
            case 'read':
              return key == null ? null : secureStorageBackingStore[key];
            case 'write':
              final value = (call.arguments as Map)['value'] as String?;
              if (key != null && value != null) {
                secureStorageBackingStore[key] = value;
              }
              return null;
            case 'delete':
              secureStorageBackingStore.remove(key);
              return null;
            case 'deleteAll':
              secureStorageBackingStore.clear();
              return null;
            default:
              return <String, String>{};
          }
        });
    await AppModule.instance.init(apiBaseUrl: 'https://api.example.com');
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(secureStorageChannel, null);
    await AppModule.instance.reset();
  });

  testWidgets('App renders the login screen on first launch', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Password'), findsOneWidget);
  });

  testWidgets('Signing in navigates to the home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'jane@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'password123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome!'), findsOneWidget);
    expect(find.text('Boilerplate'), findsWidgets);
  });
}
