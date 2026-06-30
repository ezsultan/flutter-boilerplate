import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

/// Splash screen shown on app startup.
///
/// Why this exists:
/// - Provides a brief loading screen while the app checks auth state.
/// - After auto-login completes, GoRouter's redirect guard takes over.
/// - In a backend project, this is like a startup health check.
///
/// Flow:
/// 1. User opens app → SplashPage shows.
/// 2. AuthProvider.tryAutoLogin() runs (called in main.dart).
/// 3. When auto-login completes, GoRouter redirects based on auth state.
/// 4. Authenticated → /home. Unauthenticated → /login.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes.
    final authProvider = context.watch<AuthProvider>();

    // When auto-login finishes, navigate accordingly.
    if (!authProvider.isLoading) {
      if (authProvider.isAuthenticated) {
        // Use a post-frame callback to avoid navigation during build.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
      }
    }

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}
