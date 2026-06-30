import 'package:flutter/material.dart';

/// A centered loading indicator widget.
///
/// Why this exists:
/// - Provides a consistent loading UI across all pages.
/// - Prevents code duplication for the common "loading" state.
/// - In a backend project, this is like a shared partial template.
///
/// Usage:
/// - Use in pages when data is being fetched.
/// - Providers set a loading state, and pages show this widget.
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
