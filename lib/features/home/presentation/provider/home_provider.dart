import 'package:flutter/foundation.dart';
import '../../data/repository/post_repository.dart';
import '../../domain/post.dart';
import '../../../../core/utils/app_exceptions.dart';

/// Provider that manages the home screen state and business logic.
///
/// Why this exists:
/// - Manages post list state: loading, data, error.
/// - Contains NO API calls — delegates to PostRepository.
/// - In a backend project, this is like a controller for the posts resource.
///
/// State management pattern:
/// - Uses an enum-like approach with isLoading, error, posts.
/// - The UI watches these properties and renders accordingly.
class HomeProvider extends ChangeNotifier {
  final PostRepository _postRepository;

  HomeProvider({required PostRepository postRepository})
      : _postRepository = postRepository;

  // ── State ───────────────────────────────────────────────────

  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Actions ─────────────────────────────────────────────────

  /// Loads all posts from the API.
  ///
  /// Flow:
  /// 1. Set loading state → UI shows spinner.
  /// 2. Call PostRepository.getPosts() → delegates to datasource.
  /// 3. On success: store posts, clear error, notify UI.
  /// 4. On failure: store error, notify UI.
  Future<void> loadPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _posts = await _postRepository.getPosts();
      _isLoading = false;
      notifyListeners();
    } on AppException catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred.';
      notifyListeners();
    }
  }

  /// Clears the current error (e.g., after dismissing an error dialog).
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
