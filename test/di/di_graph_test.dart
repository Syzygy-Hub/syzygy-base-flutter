import 'package:flutter_test/flutter_test.dart';
import 'package:syzygy_base/di/app_module.dart';
import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';
// StorageProvider is a Foundation contract not re-exported by the higher layers.
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show StorageProvider;
import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';

void main() {
  tearDown(() async {
    await resetDI();
  });

  group('DI Graph', () {
    setUp(() async {
      await initDI();
    });

    test('resolves Logger without throwing', () {
      expect(() => appContainer.resolve<Logger>(), returnsNormally);
    });

    test('resolves DefaultScheduler without throwing', () {
      expect(() => appContainer.resolve<DefaultScheduler>(), returnsNormally);
    });

    test('resolves ConfigRegistry without throwing', () {
      expect(() => appContainer.resolve<ConfigRegistry>(), returnsNormally);
    });

    test('resolves HttpNetworkClient without throwing', () {
      expect(() => appContainer.resolve<HttpNetworkClient>(), returnsNormally);
    });

    test('resolves StorageProvider without throwing', () {
      expect(() => appContainer.resolve<StorageProvider>(), returnsNormally);
    });

    test('resolves TokenAuthProvider without throwing', () {
      expect(() => appContainer.resolve<TokenAuthProvider>(), returnsNormally);
    });

    test('resolves EventBus without throwing', () {
      expect(() => appContainer.resolve<EventBus>(), returnsNormally);
    });

    test('resolves InMemoryFeatureFlagProvider without throwing', () {
      expect(
        () => appContainer.resolve<InMemoryFeatureFlagProvider>(),
        returnsNormally,
      );
    });

    test('resolves AppLifecycleTracker without throwing', () {
      expect(
        () => appContainer.resolve<AppLifecycleTracker>(),
        returnsNormally,
      );
    });

    test('resolves Router without throwing', () {
      expect(() => appContainer.resolve<Router>(), returnsNormally);
    });
  });
}
