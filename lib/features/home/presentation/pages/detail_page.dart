import 'package:flutter/material.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/post.dart';

/// Detail page that displays a single post's full content.
///
/// Why this exists:
/// - Shows the complete post when a user taps a PostCard.
/// - Uses a simple pattern: fetch data directly via ApiClient in initState.
/// - In a backend project, this is like a GET /posts/:id endpoint response.
///
/// Note:
/// - This page uses ApiClient directly instead of a separate Provider/Repository.
/// - This is intentional for simple cases where a full blown repository is overkill.
/// - The pattern is: for complex features, use the full stack (Provider → Repository → Datasource).
/// - For simple features, you can use ApiClient directly in the page.
class DetailPage extends StatefulWidget {
  final int postId;

  const DetailPage({super.key, required this.postId});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _apiClient = ApiClient();

  Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPost();
  }

  Future<void> _loadPost() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiClient.get(ApiConstants.postById(widget.postId));
      final json = response.data as Map<String, dynamic>;
      _post = Post(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String,
        body: json['body'] as String,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Detail'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingWidget(message: 'Loading post...');
    }

    if (_error != null) {
      return AppErrorWidget(
        message: _error!,
        onRetry: _loadPost,
      );
    }

    final post = _post!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Post #${post.id} • User #${post.userId}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const Divider(height: 32),
          Text(
            post.body,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
