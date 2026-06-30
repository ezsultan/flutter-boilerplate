import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Wrapper around flutter_secure_storage for sensitive data.
///
/// Why this exists:
/// - JWT tokens must be stored securely (not in plain text or SharedPreferences).
/// - flutter_secure_storage uses platform-specific secure storage (Keychain on iOS,
///   EncryptedSharedPreferences on Android).
/// - This wrapper provides a clean API and ensures secure storage is never
///   accessed directly from business logic.
///
/// In a backend project, this is like your secrets manager or vault service.
///
/// Usage:
/// - AuthLocalDatasource uses this to store/retrieve access and refresh tokens.
/// - Only Datasources should use this service.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  /// Stores the access token.
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: AppConstants.accessTokenKey, value: token);
  }

  /// Retrieves the access token.
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  /// Stores the refresh token.
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: AppConstants.refreshTokenKey, value: token);
  }

  /// Retrieves the refresh token.
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  /// Deletes all stored tokens (used during logout).
  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }
}
