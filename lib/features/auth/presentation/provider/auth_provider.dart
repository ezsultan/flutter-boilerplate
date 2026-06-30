import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/user.dart';
import '../../../../core/providers/providers.dart';

/// ── Auth State ──────────────────────────────────────────────

/// Immutable state representation for authentication.
///
/// Why this exists:
/// - Replaces the mutable ChangeNotifier pattern with immutable state.
/// - Each state change creates a new AuthState instance (copyWith).
/// - The UI watches this state and rebuilds when it changes.
/// - In a backend project, this is like a read-only view model.
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? Function()? currentUser,
    bool? isLoading,
    String? Function()? error,
  }) {
    return AuthState(
      currentUser: currentUser != null ? currentUser() : this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }

  /// Whether the user is authenticated.
  bool get isAuthenticated => currentUser != null;
}

/// ── Auth Notifier ───────────────────────────────────────────

/// Riverpod Notifier that manages authentication state and business logic.
///
/// Why this exists:
/// - This is the business logic layer for authentication.
/// - It extends Notifier<AuthState> so the UI can listen to state changes reactively.
/// - It contains NO API calls directly — it delegates to AuthRepository.
/// - It manages: loading state, error state, user session.
///
/// Communication:
/// - UI pages watch `authProvider` to rebuild on state changes.
/// - UI pages call methods via `ref.read(authProvider.notifier)`.
/// - Delegates data operations to AuthRepository.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Kick off auto-login on provider initialization.
    // The build() method returns the initial state immediately,
    // then _tryAutoLogin() updates the state asynchronously.
    _tryAutoLogin();
    return const AuthState(isLoading: true);
  }

  /// Attempts to log in with email and password.
  ///
  /// Flow:
  /// 1. Set loading state → UI shows loading indicator.
  /// 2. Call AuthRepository.login() → delegates to datasources.
  /// 3. On success: store user, clear error.
  /// 4. On failure: store error, clear loading.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.login(
        email: email,
        password: password,
      );
      state = AuthState(currentUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  /// Logs out the current user.
  ///
  /// Flow:
  /// 1. Call AuthRepository.logout() → clears tokens and user data.
  /// 2. Reset state to unauthenticated.
  /// 3. GoRouter redirect guard picks up the change and redirects to /login.
  Future<void> logout() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.logout();
    state = const AuthState();
  }

  /// Attempts to auto-login on app startup.
  ///
  /// Flow:
  /// 1. Check if tokens exist locally.
  /// 2. If yes, restore the cached user without a network call.
  /// 3. If tokens are expired, the ApiClient handles refresh automatically.
  Future<void> _tryAutoLogin() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.tryAutoLogin();
      state = AuthState(currentUser: user);
    } catch (_) {
      // If auto-login fails, just stay logged out.
      state = const AuthState();
    }
  }

  /// Clears the current error (e.g., after showing a snackbar).
  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

/// ── Auth Provider ───────────────────────────────────────────

/// The global Riverpod provider for authentication state.
///
/// UI pages watch this provider to reactively rebuild when auth state changes.
/// UI pages call actions via `ref.read(authProvider.notifier).method()`.
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
