import '../../../../core/storage/hive_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

/// Local datasource for authentication.
///
/// Why this exists:
/// - Handles all local storage operations related to auth (tokens, user data).
/// - Uses HiveService for user data and SecureStorageService for tokens.
/// - No business logic — just read/write operations.
/// - In a backend project, this is like a Redis cache or local database access layer.
///
/// Communication:
/// - Called by AuthRepository
/// - Uses HiveService and SecureStorageService
class AuthLocalDatasource {
  final HiveService _hiveService;
  final SecureStorageService _secureStorageService;

  AuthLocalDatasource({required HiveService hiveService})
      : _hiveService = hiveService,
        _secureStorageService = SecureStorageService();

  // ── Token Operations ────────────────────────────────────────

  /// Saves tokens to secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorageService.saveAccessToken(accessToken);
    await _secureStorageService.saveRefreshToken(refreshToken);
  }

  /// Retrieves the access token.
  Future<String?> getAccessToken() async {
    return await _secureStorageService.getAccessToken();
  }

  /// Retrieves the refresh token.
  Future<String?> getRefreshToken() async {
    return await _secureStorageService.getRefreshToken();
  }

  /// Deletes all stored tokens.
  Future<void> clearTokens() async {
    await _secureStorageService.clearTokens();
  }

  // ── User Data Operations ────────────────────────────────────

  /// Saves user data to Hive.
  Future<void> saveUser(UserModel user) async {
    await _hiveService.put(AppConstants.hiveUserKey, user.toJsonString());
  }

  /// Retrieves user data from Hive.
  UserModel? getUser() {
    final jsonString = _hiveService.get<String>(AppConstants.hiveUserKey);
    if (jsonString == null) return null;
    return UserModel.fromJsonString(jsonString);
  }

  /// Deletes user data from Hive.
  Future<void> clearUser() async {
    await _hiveService.delete(AppConstants.hiveUserKey);
  }

  /// Stores whether the user is logged in (sync flag for router guard).
  void setLoggedIn(bool value) {
    _hiveService.put('is_logged_in', value);
  }

  /// Sync check for router guard. True if login flag exists in Hive.
  bool isLoggedIn() {
    return _hiveService.get<bool>('is_logged_in') ?? false;
  }
}
