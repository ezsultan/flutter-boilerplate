import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_exceptions.dart';

/// Remote datasource for profile operations.
///
/// Why this exists:
/// - Handles network calls for user profile data.
/// - In a backend project, this is like a DAO for the user profile.
class ProfileRemoteDatasource {
  final ApiClient _apiClient;

  ProfileRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches user profile data by ID.
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await _apiClient.get(ApiConstants.userById(userId));
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw const UnknownException(message: 'Failed to load profile.');
    }
  }
}
