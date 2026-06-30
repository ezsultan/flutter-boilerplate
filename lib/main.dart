import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasource/auth_local_datasource.dart';
import 'features/auth/data/datasource/auth_remote_datasource.dart';
import 'features/auth/data/repository/auth_repository.dart';
import 'features/auth/presentation/provider/auth_provider.dart';
import 'features/home/data/datasource/post_remote_datasource.dart';
import 'features/home/data/repository/post_repository.dart';
import 'features/home/presentation/provider/home_provider.dart';
import 'features/profile/data/datasource/profile_remote_datasource.dart';
import 'features/profile/data/repository/profile_repository.dart';
import 'features/profile/presentation/provider/profile_provider.dart';
import 'core/network/api_client.dart';

/// Entry point of the application.
///
/// Why this exists:
/// - Initializes all services (Hive, Dio, Providers) before running the app.
/// - This is the "composition root" — everything is wired together here.
/// - No dependency injection framework is used; we do manual constructor injection.
void main() async {
  // Ensure Flutter bindings are initialized before using any plugins.
  // This is REQUIRED when calling async code before runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive storage.
  // This must be done before any Hive-dependent code runs.
  final hiveService = await HiveService.init();

  // Create the DIO HTTP client.
  // It handles token injection, refreshing, and error mapping automatically.
  final apiClient = ApiClient();

  // ── Datasources ──────────────────────────────────────────────
  // Datasources are the lowest layer — they talk to external systems.
  // They know nothing about Providers or Pages.
  final authRemoteDatasource = AuthRemoteDatasource(apiClient: apiClient);
  final authLocalDatasource = AuthLocalDatasource(hiveService: hiveService);
  final postRemoteDatasource = PostRemoteDatasource(apiClient: apiClient);
  final profileRemoteDatasource = ProfileRemoteDatasource(apiClient: apiClient);

  // ── Repositories ─────────────────────────────────────────────
  // Repositories combine multiple datasources (remote + local) and
  // expose clean domain-level data to Providers.
  final authRepository = AuthRepository(
    remoteDatasource: authRemoteDatasource,
    localDatasource: authLocalDatasource,
  );
  final postRepository = PostRepository(
    remoteDatasource: postRemoteDatasource,
  );
  final profileRepository = ProfileRepository(
    remoteDatasource: profileRemoteDatasource,
  );

  runApp(
    MultiProvider(
      providers: [
        // ── AuthProvider ───────────────────────────────────────
        // Handles login, logout, token refresh, and auto-login.
        // This MUST be above other providers since they depend on auth state.
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            authRepository: authRepository,
          )..tryAutoLogin(),
        ),

        // ── HomeProvider ───────────────────────────────────────
        // Loads and manages the list of posts on the home screen.
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => HomeProvider(
            postRepository: postRepository,
          ),
        ),

        // ── ProfileProvider ────────────────────────────────────
        // Loads and manages the current user's profile data.
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            profileRepository: profileRepository,
          ),
        ),
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
class FlutterBoilerplateApp extends StatelessWidget {
  const FlutterBoilerplateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider for routing decisions.
    // When auth state changes, GoRouter will rebuild and redirect accordingly.
    final authProvider = context.watch<AuthProvider>();
    final router = AppRouter.createRouter(authProvider.authRepository);

    return MaterialApp.router(
      title: 'Flutter Boilerplate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
