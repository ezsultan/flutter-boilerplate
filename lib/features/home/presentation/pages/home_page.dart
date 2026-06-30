import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
/// - It watches HomeProvider and renders the appropriate UI based on state.
/// - Contains NO business logic — only UI rendering and navigation.
/// - In a backend project, this is like a controller that renders a list view.
///
/// States handled:
/// - Loading: shows CircularProgressIndicator.
/// - Error: shows error message with retry button.
/// - Empty: shows "no posts" message.
/// - Data: shows scrollable list of post cards.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Load posts when the page first appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => homeProvider.loadPosts(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(homeProvider),
    );
  }

  Widget _buildBody(HomeProvider provider) {
    // Loading state
    if (provider.isLoading) {
      return const LoadingWidget(message: 'Loading posts...');
    }

    // Error state
    if (provider.error != null) {
      return AppErrorWidget(
        message: provider.error!,
        onRetry: () => provider.loadPosts(),
      );
    }

    // Empty state
    if (provider.posts.isEmpty) {
      return const EmptyWidget(message: 'No posts found.');
    }

    // Data state
    return RefreshIndicator(
      onRefresh: () => provider.loadPosts(),
      child: ListView.builder(
        itemCount: provider.posts.length,
        itemBuilder: (context, index) {
          final post = provider.posts[index];
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
