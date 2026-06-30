import '../datasource/profile_remote_datasource.dart';

/// Repository for profile operations.
///
/// Why this exists:
/// - Wraps ProfileRemoteDatasource and provides clean data to the Provider.
/// - The Provider knows nothing about Dio or API details.
class ProfileRepository {
  final ProfileRemoteDatasource _remoteDatasource;

  ProfileRepository({required ProfileRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  /// Fetches the user's profile data.
  Future<Map<String, dynamic>> getProfile(int userId) async {
    return await _remoteDatasource.getUserProfile(userId);
  }
}
