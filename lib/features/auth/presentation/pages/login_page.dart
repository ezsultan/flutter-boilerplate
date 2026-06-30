import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../widgets/login_form.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Login page where users enter their credentials.
///
/// Why this exists:
/// - This is the "Controller" in the backend analogy.
/// - It renders the UI and delegates user actions to the Provider.
/// - It contains NO business logic — only UI logic (showing snackbar, navigation).
/// - In a backend project, this is like a controller that renders a view
///   and calls a service for business logic.
///
/// Flow:
/// 1. User fills form and taps "Login".
/// 2. LoginForm calls onSubmit callback.
/// 3. LoginPage calls AuthProvider.login().
/// 4. AuthProvider sets loading state → UI shows spinner.
/// 5. On success: AuthProvider updates currentUser → GoRouter redirects to /home.
/// 6. On failure: AuthProvider sets error → UI shows snackbar.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show error snackbar when login fails.
    if (authProvider.error != null) {
      // Use post-frame callback to avoid showing snackbar during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorSnackBar(context, authProvider.error!);
        authProvider.clearError();
      });
    }

    // Redirect to home when login succeeds.
    if (authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: LoginForm(
              isLoading: authProvider.isLoading,
              onSubmit: (email, password) {
                authProvider.login(email: email, password: password);
              },
            ),
          ),
        ),
      ),
    );
  }
}
