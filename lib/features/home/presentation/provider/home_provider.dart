import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/post.dart';
import '../../../../core/utils/app_exceptions.dart';
import '../../../../core/providers/providers.dart';

/// ── Home State ──────────────────────────────────────────────

/// Immutable state representation for the home screen.
///
/// Why this exists:
/// - Replaces the mutable ChangeNotifier pattern with immutable state.
/// - Encapsulates all UI state for the posts list: loading, data, error.
/// - The UI watches this state and renders accordingly.
class HomeState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? Function()? error,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

/// ── Home Notifier ───────────────────────────────────────────

/// Riverpod Notifier that manages the home screen state and business logic.
///
/// Why this exists:
/// - Manages post list state: loading, data, error.
/// - Contains NO API calls — delegates to PostRepository.
/// - In a backend project, this is like a controller for the posts resource.
///
/// State management pattern:
/// - Uses an immutable HomeState with copyWith for state transitions.
/// - The UI watches `homeProvider` and renders based on state properties.
class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState();
  }

  /// Loads all posts from the API.
  ///
  /// Flow:
  /// 1. Set loading state → UI shows spinner.
  /// 2. Call PostRepository.getPosts() → delegates to datasource.
  /// 3. On success: store posts, clear error.
  /// 4. On failure: store error.
  Future<void> loadPosts() async {
    state = state.copyWith(isLoading: true, error: () => null);

    try {
      final postRepository = ref.read(postRepositoryProvider);
      final posts = await postRepository.getPosts();
      state = HomeState(posts: posts);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: () => 'An unexpected error occurred.',
      );
    }
  }

  /// Clears the current error (e.g., after dismissing an error dialog).
  void clearError() {
    state = state.copyWith(error: () => null);
  }
}

/// ── Home Provider ───────────────────────────────────────────

/// The global Riverpod provider for home screen state.
///
/// UI pages watch this provider to reactively rebuild when home state changes.
/// UI pages call actions via `ref.read(homeProvider.notifier).loadPosts()`.
final homeProvider = NotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
