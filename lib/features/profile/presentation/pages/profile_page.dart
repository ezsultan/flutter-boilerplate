import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../provider/profile_provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

/// Profile page that displays user information.
///
/// Why this exists:
/// - Shows user profile data loaded from the API.
/// - Provides logout functionality.
/// - In a backend project, this is like a profile endpoint.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.currentUser != null) {
        context.read<ProfileProvider>().loadProfile(
              authProvider.currentUser!.id,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _buildBody(profileProvider, user),
    );
  }

  Widget _buildBody(ProfileProvider provider, dynamic user) {
    if (provider.isLoading) {
      return const LoadingWidget(message: 'Loading profile...');
    }

    if (provider.error != null) {
      return AppErrorWidget(
        message: provider.error!,
        onRetry: () {
          if (user != null) provider.loadProfile(user.id);
        },
      );
    }

    final profile = provider.profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info from local storage
          if (user != null) ...[
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
          const Divider(height: 32),
          // Extended profile data from API
          if (profile != null) ...[
            _buildInfoRow('Username', profile['username'] ?? ''),
            _buildInfoRow('Phone', profile['phone'] ?? ''),
            _buildInfoRow('Website', profile['website'] ?? ''),
            const SizedBox(height: 16),
            Text(
              'Address',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (profile['address'] != null) ...[
              _buildInfoRow('Street', profile['address']['street'] ?? ''),
              _buildInfoRow('City', profile['address']['city'] ?? ''),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
