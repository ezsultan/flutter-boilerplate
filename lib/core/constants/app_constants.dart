/// Application-wide constants.
///
/// Why this exists:
/// - Centralizes all hardcoded values so they are easy to find and change.
/// - Prevents magic strings and numbers scattered across the codebase.
/// - In a backend project, this is similar to a config file or environment variables.
class AppConstants {
  AppConstants._(); // Private constructor prevents instantiation.

  /// App metadata
  static const String appName = 'Flutter Boilerplate';
  static const String appVersion = '1.0.0';

  /// Storage keys
  static const String hiveBoxName = 'flutter_boilerplate_box';
  static const String hiveUserKey = 'current_user';
  static const String hiveThemeKey = 'theme_mode';

  /// Secure storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  /// Connection timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 15);
}
