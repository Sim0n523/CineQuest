import 'package:flutter/material.dart';

/// Centralized color palette for CineQuest.
///
/// Every color in the app should come from here — never a hardcoded
/// hex value in a screen or widget. That's what makes the whole app's
/// dark, cinematic look retunable from a single file.
///
/// Values match the blueprint's palette (section 10) exactly.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B132B); // Deep Navy
  static const Color surface = Color(0xFF1C2541); // Dark Slate
  static const Color card = Color(0xFF243B55); // Steel Blue

  static const Color primaryAccent = Color(0xFFF4C542); // Rich Gold
  static const Color xp = Color(0xFF4DA3FF); // Bright Blue
  static const Color success = Color(0xFF22C55E); // Emerald
  static const Color warning = Color(0xFFFFB703); // Amber
  static const Color error = Color(0xFFEF4444); // Soft Red

  static const Color textPrimary = Color(0xFFF8FAFC); // Off White
  static const Color textSecondary = Color(0xFFB8C1CC); // Gray Blue
}
