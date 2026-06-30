import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
/// 2. AuthNotifier._tryAutoLogin() runs automatically (called in build()).
/// 3. When auto-login completes, the notifier updates auth state.
/// 4. GoRouter's redirect guard (watching authProvider) picks up the change
///    and redirects: authenticated → /home, unauthenticated → /login.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to auth state changes via Riverpod.
    final authState = ref.watch(authProvider);

    // When auto-login finishes, navigate accordingly.
    if (!authState.isLoading) {
      if (authState.isAuthenticated) {
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
