import '../datasource/auth_local_datasource.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/user_model.dart';
import '../../domain/user.dart';

/// Repository for authentication operations.
///
/// Why this exists:
/// - This is the "orchestrator" that combines remote and local datasources.
/// - It decides whether to fetch from API or local storage.
/// - It converts data models (UserModel) to domain models (User).  
/// - The Provider layer knows NOTHING about ApiClient, Hive, or Dio.
/// - In a backend project, this is like a NestJS service or a repository pattern
///   that sits between controllers and data access.
///
/// Communication:
/// - Called by AuthProvider (and AppRouter for auth guard).
/// - Calls AuthRemoteDatasource for network operations.
/// - Calls AuthLocalDatasource for cached/stored data.
/// - Returns domain-level objects (User) to the Provider.
///
/// Why isLoggedIn() is a synchronous getter:
/// - The GoRouter redirect guard needs a synchronous check.
/// - isLoggedIn() only checks if tokens exist locally (no network call).
/// - Actual session validation happens during auto-login in AuthProvider.
class AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;

  AuthRepository({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  /// Attempts to log in with email and password.
  ///
  /// Returns a [User] object on success.
  /// Throws [AppException] on failure.
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDatasource.login(
      email: email,
      password: password,
    );

    final userModel = result['user'] as UserModel;
    final accessToken = result['accessToken'] as String;
    final refreshToken = result['refreshToken'] as String;

    // Persist tokens and user data locally.
    await _localDatasource.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _localDatasource.saveUser(userModel);
    _localDatasource.setLoggedIn(true);

    return userModel.toDomain();
  }

  /// Attempts to refresh the access token.
  Future<String> refreshToken() async {
    final currentRefreshToken = await _localDatasource.getRefreshToken();
    if (currentRefreshToken == null) {
      throw Exception('No refresh token available.');
    }

    final result = await _remoteDatasource.refreshToken(currentRefreshToken);
    final newAccessToken = result['accessToken'] as String;
    final newRefreshToken = result['refreshToken'] as String;

    await _localDatasource.saveTokens(
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    return newAccessToken;
  }

  /// Logs out the current user by clearing all stored data.
  Future<void> logout() async {
    await _localDatasource.clearTokens();
    await _localDatasource.clearUser();
    _localDatasource.setLoggedIn(false);
  }

  /// Checks if the user has stored tokens (synchronous for router guard).
  bool isLoggedIn() {
    return _localDatasource.isLoggedIn();
  }

  /// Retrieves the cached user data.
  User? getCachedUser() {
    final userModel = _localDatasource.getUser();
    return userModel?.toDomain();
  }

  /// Tries to auto-login by checking for existing tokens.
  ///
  /// Returns the cached [User] if tokens exist, null otherwise.
  Future<User?> tryAutoLogin() async {
    if (!isLoggedIn()) return null;
    return getCachedUser();
  }
}
