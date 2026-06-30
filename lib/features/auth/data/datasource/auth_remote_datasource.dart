import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../models/user_model.dart';

/// Remote datasource for authentication.
///
/// Why this exists:
/// - Handles all network calls related to authentication.
/// - Uses ApiClient (Dio) to make HTTP requests.
/// - Returns raw data (UserModel, tokens) — no business logic here.
/// - In a backend project, this is like a DAO (Data Access Object) or a service
///   that makes API calls to an auth microservice.
///
/// Communication:
/// - Called by AuthRepository
/// - Calls ApiClient for HTTP requests
/// - Returns UserModel and token strings
class AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Simulates a login API call.
  ///
  /// Since JSONPlaceholder doesn't have auth, we simulate the response.
  /// In production, this would call your actual auth endpoint.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Mock: Fetch user data from JSONPlaceholder to simulate login.
      final response = await _apiClient.get('/users/1');

      final userData = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(userData);

      // Simulate token generation.
      final accessToken = 'mock_access_token_${DateTime.now().millisecondsSinceEpoch}';
      final refreshToken = 'mock_refresh_token_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'user': user,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
    } on DioException catch (e) {
      // Re-throw the already-mapped AppException from ApiClient.
      if (e.error is AppException) {
        rethrow;
      }
      throw const UnknownException(message: 'Login failed. Please try again.');
    }
  }

  /// Simulates a token refresh API call.
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      // Mock: In production, this would call your auth refresh endpoint.
      // For demo, we just return a new access token.
      final newAccessToken = 'refreshed_${DateTime.now().millisecondsSinceEpoch}';

      return {
        'accessToken': newAccessToken,
        // Keep the same refresh token for simplicity.
        'refreshToken': refreshToken,
      };
    } on DioException catch (e) {
      if (e.error is AppException) {
        rethrow;
      }
      throw const UnknownException(message: 'Token refresh failed.');
    }
  }
}
