import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity status.
///
/// Why this exists:
/// - Provides a reactive way to check if the device has internet access.
/// - The API client uses this to avoid making requests when offline.
/// - Providers can listen to connectivity changes to update UI.
///
/// In a backend project, this is like a health check service.
///
/// Usage:
/// - ApiClient checks this before making HTTP requests.
/// - ErrorInterceptor uses this to distinguish network errors from server errors.
class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService() : _connectivity = Connectivity();

  /// Returns true if the device has an active internet connection.
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Stream that emits connectivity changes in real-time.
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
