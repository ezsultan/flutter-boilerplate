import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/routes/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/providers.dart';

/// Entry point of the application.
///
/// Why this exists:
/// - Initializes all services (Hive) before running the app.
/// - Wraps the app in ProviderScope (Riverpod's root widget) for state management.
/// - Injects the initialized HiveService via ProviderScope overrides.
void main() async {
  // Ensure Flutter bindings are initialized before using any plugins.
  // This is REQUIRED when calling async code before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage.
  // This must be done before any Hive-dependent code runs.
  final hiveService = await HiveService.init();

  runApp(
    // ProviderScope is Riverpod's root widget — it must wrap the entire app.
    // All Riverpod providers are scoped under this widget tree.
    ProviderScope(
      overrides: [
        // Inject the initialized HiveService singleton into the provider tree.
        // This way, all downstream providers can access it via ref.watch().
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const FlutterBoilerplateApp(),
    ),
  );
}

/// Root widget of the Flutter Boilerplate application.
///
/// Why this exists:
/// - It wraps the app with the GoRouter for declarative navigation.
/// - It sets the Material theme for consistent UI.
/// - It extends [ConsumerWidget] (Riverpod) instead of [StatelessWidget] so it
///   can watch providers directly via ref.
class FlutterBoilerplateApp extends ConsumerWidget {
  const FlutterBoilerplateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the router provider — it rebuilds whenever auth state changes,
    // which ensures the redirect guard is always up to date.
    final router = ref.watch(AppRouter.provider);

    return MaterialApp.router(
      title: 'Flutter Boilerplate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
