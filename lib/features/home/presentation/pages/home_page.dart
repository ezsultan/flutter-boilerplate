import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/home_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../widgets/post_card.dart';
import '../../domain/post.dart';

/// Home page that displays a list of posts.
///
/// Why this exists:
/// - This is the "Controller" for the home screen.
/// - It watches HomeState via Riverpod and renders the appropriate UI.
/// - Contains NO business logic — only UI rendering and navigation.
/// - In a backend project, this is like a controller that renders a list view.
///
/// States handled:
/// - Loading: shows CircularProgressIndicator.
/// - Error: shows error message with retry button.
/// - Empty: shows "no posts" message.
/// - Data: shows scrollable list of post cards.
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load posts when the page first appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeProvider.notifier).loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(homeProvider.notifier).loadPosts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(homeState),
    );
  }

  Widget _buildBody(HomeState state) {
    // Loading state
    if (state.isLoading) {
      return const LoadingWidget(message: 'Loading posts...');
    }

    // Error state
    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(homeProvider.notifier).loadPosts(),
      );
    }

    // Empty state
    if (state.posts.isEmpty) {
      return const EmptyWidget(message: 'No posts found.');
    }

    // Data state
    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).loadPosts(),
      child: ListView.builder(
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return PostCard(
            post: post,
            onTap: () => _navigateToDetail(post),
          );
        },
      ),
    );
  }

  void _navigateToDetail(Post post) {
    context.push('/detail/${post.id}');
  }
}
