import 'package:syzygy_core_flutter/syzygy_core_flutter.dart';
// StorageProvider is a Foundation contract type. Neither syzygy_core_flutter
// nor syzygy_services_flutter re-export it, so we import Foundation directly.
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show StorageProvider;
import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';

/// App-wide dependency injection container using Core's [Container].
///
/// Registers all Syzygy layer services as singletons. Call [initDI] once
/// during `main()`, before `runApp`.
///
/// Usage:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await initDI();
///   runApp(const App());
/// }
/// ```
///
/// Note: [appContainer] is a getter backed by a replaceable field so that
/// [resetDI] (used between tests) can swap in a fresh [Container] without
/// hitting the "cannot register on a disposed Container" guard.
Container _appContainer = Container();

/// The app-wide DI container. Always refers to the current live container.
Container get appContainer => _appContainer;

bool _isInitialized = false;

/// Registers all app-wide dependencies into [appContainer].
///
/// Safe to call multiple times — subsequent calls are no-ops.
Future<void> initDI() async {
  if (_isInitialized) return;

  // ── Logger ────────────────────────────────────────────────────────────────
  appContainer.register<Logger>(Lifetime.singleton, (_) {
    final logger = Logger();
    logger.addDestination(ConsoleLogDestination());
    return logger;
  });

  // ── Storage ───────────────────────────────────────────────────────────────
  // InMemoryStorageProvider from syzygy_services_flutter.
  // TODO: replace with a platform-secure StorageProvider (e.g. SecureStorageProvider)
  // once Foundation adds native keychain/keystore support.
  appContainer.register<StorageProvider>(
    Lifetime.singleton,
    (_) => InMemoryStorageProvider(),
  );

  // ── Network ───────────────────────────────────────────────────────────────
  appContainer.register<HttpNetworkClient>(
    Lifetime.singleton,
    (c) => HttpNetworkClient(
      logger: c.resolve<Logger>(),
    ),
  );

  // ── Auth ──────────────────────────────────────────────────────────────────
  appContainer.register<TokenAuthProvider>(
    Lifetime.singleton,
    (c) => TokenAuthProvider(
      c.resolve<StorageProvider>(),
      networkClient: c.resolve<HttpNetworkClient>(),
      // refreshEndpoint: 'https://api.example.com/auth/refresh',
    ),
  );

  // ── EventBus ──────────────────────────────────────────────────────────────
  appContainer.register<EventBus>(
    Lifetime.singleton,
    (_) => EventBus(),
  );

  // ── Feature Flags ─────────────────────────────────────────────────────────
  appContainer.register<InMemoryFeatureFlagProvider>(
    Lifetime.singleton,
    (_) => InMemoryFeatureFlagProvider(),
  );

  // ── Config Registry ───────────────────────────────────────────────────────
  appContainer.register<ConfigRegistry>(
    Lifetime.singleton,
    (_) => ConfigRegistry(),
  );

  // ── Scheduler ─────────────────────────────────────────────────────────────
  appContainer.register<DefaultScheduler>(
    Lifetime.singleton,
    (_) => DefaultScheduler(),
  );

  // ── App Lifecycle Tracker ─────────────────────────────────────────────────
  appContainer.register<AppLifecycleTracker>(
    Lifetime.singleton,
    (_) => AppLifecycleTracker(),
  );

  // ── Router ────────────────────────────────────────────────────────────────
  // Core's Router manages an in-process navigation stack with guards.
  // go_router handles the Flutter widget-tree routing; this Router is used
  // for guard-based programmatic navigation within domain/service layers.
  appContainer.register<Router>(
    Lifetime.singleton,
    (_) => Router(),
  );

  // ── StateStore (register once you define AppState and AppAction) ─────────────
  // StateStore<S, A> is generic — define your state and action types first.
  //
  // Example:
  //   class AppState { final bool isLoggedIn; final User? user;
  //     const AppState({this.isLoggedIn = false, this.user}); }
  //   abstract class AppAction {}
  //   class LoginAction extends AppAction { final User user; LoginAction(this.user); }
  //   class LogoutAction extends AppAction {}
  //
  //   AppState appReducer(AppState state, AppAction action) {
  //     if (action is LoginAction) return AppState(isLoggedIn: true, user: action.user);
  //     if (action is LogoutAction) return const AppState();
  //     return state;
  //   }
  //
  //   appContainer.register<StateStore<AppState, AppAction>>(Lifetime.singleton,
  //     (_) => StateStore(initial: const AppState(), reducer: appReducer));
  //
  // See syzygy_core_flutter lib/src/state/state_store.dart for the full API.

  // ── AI Layer registrations (add after syzygy_ai_flutter is published to pub.dev) ──
  // import 'package:syzygy_ai_flutter/syzygy_ai_flutter.dart';
  //
  // appContainer.register<LLMProvider>(Lifetime.singleton, (_) => DefaultLLMProvider());
  // appContainer.register<DefaultAgent>(Lifetime.singleton, (c) =>
  //     DefaultAgent(llm: c.resolve<LLMProvider>()));
  // appContainer.register<EmbeddingProvider>(Lifetime.singleton, (_) => DefaultEmbeddingProvider());
  // appContainer.register<RAGProvider>(Lifetime.singleton, (c) =>
  //     DefaultRAGProvider(embeddings: c.resolve<EmbeddingProvider>()));
  // appContainer.register<MemoryManager>(Lifetime.singleton, (_) => DefaultMemoryManager());
  // appContainer.register<NamespacedMemoryManager>(Lifetime.singleton, (c) =>
  //     NamespacedMemoryManager(base: c.resolve<MemoryManager>()));

  _isInitialized = true;
}

/// Resets the DI container. Intended for use between tests.
///
/// Disposes the current container and replaces it with a fresh instance so
/// that the next [initDI] call starts clean.
Future<void> resetDI() async {
  _appContainer.dispose();
  _appContainer = Container();
  _isInitialized = false;
}
