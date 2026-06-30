import '../datasource/post_remote_datasource.dart';
import '../../domain/post.dart';

/// Repository for post-related operations.
///
/// Why this exists:
/// - Wraps PostRemoteDatasource and provides domain-level data.
/// - The Provider knows nothing about PostModel or ApiClient.
/// - In a backend project, this is like a service that abstracts the data layer.
class PostRepository {
  final PostRemoteDatasource _remoteDatasource;

  PostRepository({required PostRemoteDatasource remoteDatasource})
      : _remoteDatasource = remoteDatasource;

  /// Fetches all posts.
  Future<List<Post>> getPosts() async {
    final models = await _remoteDatasource.getPosts();
    return models.map((model) => model.toDomain()).toList();
  }

  /// Fetches a single post by ID.
  Future<Post> getPostById(int id) async {
    final model = await _remoteDatasource.getPostById(id);
    return model.toDomain();
  }
}
