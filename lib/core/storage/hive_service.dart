import 'package:hive_flutter/hive_flutter.dart';
import '../constants/app_constants.dart';

/// Wrapper around Hive for local storage.
///
/// Why this exists:
/// - Hive is a fast NoSQL database for Flutter.
/// - This wrapper ensures Hive is never accessed directly from UI or business logic.
/// - It provides a clean API for storing/retrieving data.
/// - In a backend project, this is like your database service layer.
///
/// Singleton pattern:
/// - HiveService is initialized once at app startup.
/// - The same instance is shared across the app via constructor injection.
///
/// Usage:
/// - AuthLocalDatasource uses this to store/retrieve user data.
/// - Only Datasources should use this service, never Providers or Pages.
class HiveService {
  late Box _box;

  HiveService._(); // Private constructor for singleton.

  static HiveService? _instance;

  /// Returns the singleton instance.
  static HiveService get instance {
    if (_instance == null) {
      throw StateError(
        'HiveService not initialized. Call HiveService.init() first.',
      );
    }
    return _instance!;
  }

  /// Initializes Hive and opens the default box.
  ///
  /// Call this once in main() before runApp().
  static Future<HiveService> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(AppConstants.hiveBoxName);
    final instance = HiveService._();
    instance._box = box;
    _instance = instance;
    return instance;
  }

  // ── Generic CRUD operations ─────────────────────────────────

  /// Writes a value to storage.
  Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  /// Reads a value from storage.
  T? get<T>(String key) {
    return _box.get(key);
  }

  /// Deletes a value from storage.
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Clears all stored data.
  Future<void> clear() async {
    await _box.clear();
  }

  /// Checks if a key exists.
  bool containsKey(String key) {
    return _box.containsKey(key);
  }
}
