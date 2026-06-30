import 'package:flutter/material.dart';

/// Application theme configuration.
///
/// Why this exists:
/// - Centralizes all theme settings in one place.
/// - Ensures visual consistency across the app.
/// - Easy to switch between light/dark themes or customize branding.
///
/// In a backend project, this is like your CSS framework or UI kit config.
class AppTheme {
  AppTheme._();

  /// Light theme used throughout the app.
  ///
  /// Uses default Material theme with minimal customizations.
  /// The goal is functional UI, not visual beauty.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.blue,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}
