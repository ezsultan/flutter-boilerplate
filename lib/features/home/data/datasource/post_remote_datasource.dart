import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../models/post_model.dart';

/// Remote datasource for fetching posts.
///
/// Why this exists:
/// - Handles all network calls related to posts.
/// - Uses ApiClient (Dio) to make HTTP requests.
/// - Returns raw PostModel data — no business logic.
/// - In a backend project, this is like a DAO for the posts collection.
class PostRemoteDatasource {
  final ApiClient _apiClient;

  PostRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches all posts from JSONPlaceholder.
  Future<List<PostModel>> getPosts() async {
    try {
      final response = await _apiClient.get(ApiConstants.posts);
      final data = response.data as List<dynamic>;
      return data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw const UnknownException(message: 'Failed to fetch posts.');
    }
  }

  /// Fetches a single post by ID.
  Future<PostModel> getPostById(int id) async {
    try {
      final response = await _apiClient.get(ApiConstants.postById(id));
      return PostModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is AppException) rethrow;
      throw const UnknownException(message: 'Failed to fetch post details.');
    }
  }
}
