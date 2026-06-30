import 'package:flutter/material.dart';

/// Helper function to show a snackbar with an error message.
///
/// Why this exists:
/// - Provides a consistent way to show error messages across the app.
/// - Extracts the user-friendly message from AppException.
/// - In a backend project, this is like a standardized error response formatter.
///
/// Usage:
/// - Call from any page when an operation fails.
/// - Pass the caught exception to display the appropriate message.
void showErrorSnackBar(BuildContext context, dynamic error) {
  // Extract the message from AppException or use a generic fallback.
  final message = error is Exception ? error.toString() : 'An unexpected error occurred.';

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
