import 'package:flutter/foundation.dart';
import '../../data/repository/auth_repository.dart';
import '../../domain/user.dart';

/// Provider that manages authentication state and business logic.
///
/// Why this exists:
/// - This is the business logic layer for authentication.
/// - It extends ChangeNotifier so the UI can listen to state changes.
/// - It contains NO API calls directly — it delegates to AuthRepository.
/// - It manages: loading state, error state, user session.
/// - In a backend project, this is like a NestJS service or controller
///   that orchestrates authentication flows.
///
/// Communication:
/// - Called by UI pages (LoginPage, SplashPage).
/// - Calls AuthRepository for login/logout/refresh operations.
/// - Notifies listeners when state changes (UI rebuilds automatically).
///
/// Why ChangeNotifier:
/// - Provider listens to ChangeNotifier for reactive UI updates.
/// - When notifyListeners() is called, all widgets using context.watch()
///   will rebuild.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthProvider({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ── State ───────────────────────────────────────────────────

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  /// The currently logged-in user, or null if not authenticated.
  User? get currentUser => _currentUser;

  /// Whether an auth operation is in progress.
  bool get isLoading => _isLoading;

  /// The last error message, or null if no error.
  String? get error => _error;

  /// Whether the user is authenticated.
  bool get isAuthenticated => _currentUser != null;

  /// Exposes the auth repository for the router guard.
  AuthRepository get authRepository => _authRepository;

  // ── Actions ─────────────────────────────────────────────────

  /// Attempts to log in with email and password.
  ///
  /// Flow:
  /// 1. Set loading state → UI shows loading indicator.
  /// 2. Call AuthRepository.login() → delegates to datasources.
  /// 3. On success: store user, clear error, notify UI.
  /// 4. On failure: store error, clear loading, notify UI.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Logs out the current user.
  ///
  /// Flow:
  /// 1. Call AuthRepository.logout() → clears tokens and user data.
  /// 2. Clear current user from provider state.
  /// 3. Notify UI → GoRouter redirect guard will redirect to /login.
  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  /// Attempts to auto-login on app startup.
  ///
  /// Flow:
  /// 1. Check if tokens exist locally.
  /// 2. If yes, restore the cached user without a network call.
  /// 3. If tokens are expired, the ApiClient will handle refresh automatically
  ///    when the first API call is made.
  Future<void> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authRepository.tryAutoLogin();
    } catch (_) {
      // If auto-login fails, just stay logged out.
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears the current error (e.g., after showing a snackbar).
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
