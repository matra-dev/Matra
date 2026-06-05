import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette - Soft healthcare blues
  static const Color primary = Color(0xFF4A90D9);
  static const Color primaryLight = Color(0xFFE8F4FD);
  static const Color primaryDark = Color(0xFF2E6BA8);

  // Secondary - Soft greens
  static const Color secondary = Color(0xFF5CB85C);
  static const Color secondaryLight = Color(0xFFE8F5E9);

  // Accent - Warm amber
  static const Color accent = Color(0xFFF0AD4E);
  static const Color accentLight = Color(0xFFFFF3E0);

  // Semantic
  static const Color success = Color(0xFF5CB85C);
  static const Color warning = Color(0xFFF0AD4E);
  static const Color danger = Color(0xFFD9534F);
  static const Color info = Color(0xFF5BC0DE);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F8);

  // Text
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6C7A89);
  static const Color textMuted = Color(0xFF95A5A6);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Dividers
  static const Color border = Color(0xFFE1E8ED);
  static const Color divider = Color(0xFFECF0F1);

  // Liquid Glass effect colors
  static const Color glassBackground = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);
  static const Color glassShadow = Color(0x1A000000);

  // Time slot colors
  static const Color morning = Color(0xFFFFB74D);
  static const Color afternoon = Color(0xFF4FC3F7);
  static const Color evening = Color(0xFF9575CD);

  // Gradient pairs for liquid glass
  static const List<Color> greenGradient = [
    Color(0xFF81C784),
    Color(0xFF4CAF50),
    Color(0xFF2E7D32),
  ];

  static const List<Color> blueGradient = [
    Color(0xFF90CAF9),
    Color(0xFF42A5F5),
    Color(0xFF1565C0),
  ];

  static const List<Color> warmGradient = [
    Color(0xFFFFCC80),
    Color(0xFFFFA726),
    Color(0xFFEF6C00),
  ];
}
