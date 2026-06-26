import 'package:flutter/material.dart';

/// Golden Ratio Design System for Matra
/// φ = 1.618033988749...

class GR {
  GR._();

  /// The golden ratio constant
  static const double phi = 1.618033988749;

  /// Base unit - everything scales from this
  static const double base = 8.0;

  /// Spacing scale using golden ratio
  static double get xs => base * 0.5;        // 4
  static double get sm => base;              // 8
  static double get md => base * phi;        // ~13
  static double get lg => base * phi * phi;  // ~21
  static double get xl => base * phi * phi * phi; // ~34
  static double get xxl => base * phi * phi * phi * phi; // ~55

  /// Common ratios
  static double ratio(double value) => value * phi;
  static double inverse(double value) => value / phi;

  /// Card padding: inner 16, outer 21 (golden)
  static double get cardPadding => 16.0;
  static double get cardGap => 13.0;
  static double get sectionGap => 21.0;

  /// Border radii following φ
  static double get radiusSm => 8.0;
  static double get radiusMd => 13.0;
  static double get radiusLg => 21.0;

  /// Font sizes using golden ratio scale
  static double get textXs => 10.0;
  static double get textSm => 11.0;
  static double get textBase => 13.0;
  static double get textMd => 16.0;  // 13 * 1.23 ≈ 16
  static double get textLg => 21.0;
  static double get textXl => 26.0;  // 21 * 1.24 ≈ 26
  static double get text2xl => 34.0;

  /// Icon sizes
  static double get iconSm => 16.0;
  static double get iconMd => 21.0;
  static double get iconLg => 26.0;

  /// Button heights
  static double get buttonSm => 36.0;
  static double get buttonMd => 46.0;  // 36 * 1.28
  static double get buttonLg => 55.0;
}

/// App Colors — DYNAMIC based on theme brightness.
/// 
/// IMPORTANT: These are now context-aware. For widgets that have access to
/// BuildContext, use `ThemeColors.of(context)` from app_text_styles.dart
/// for the most accurate dark mode colors.
/// 
/// These static getters remain for backward compatibility and will return
/// light mode colors. They are being phased out in favor of ThemeColors.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bg = Color(0xFFFAFAFA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);

  // Borders
  static const Color border = Color(0xFFE8E8E8);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // Accent - Teal
  static const Color accent = Color(0xFF00BFA5);
  static const Color accentLight = Color(0xFFB8E0D2);
  static const Color accentDark = Color(0xFF00897B);
  static const Color accentBg = Color(0xFFE8F5F0);

  // Semantic
  static const Color orange = Color(0xFFFFA726);
  static const Color orangeLight = Color(0xFFFFF3E0);
  static const Color blue = Color(0xFF448AFF);
  static const Color purple = Color(0xFF7E57C2);
  static const Color red = Color(0xFFEF5350);
  static const Color amber = Color(0xFFFFB74D);
}

/// Golden Ratio Box - creates a box with golden ratio dimensions
class GoldenBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? baseSize;
  final bool useWidthAsBase;
  final Widget? child;
  final BoxDecoration? decoration;

  const GoldenBox({
    super.key,
    this.width,
    this.height,
    this.baseSize,
    this.useWidthAsBase = true,
    this.child,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final double base = baseSize ?? (useWidthAsBase ? width : height) ?? 100;
    final double derived = base * GR.phi;

    return Container(
      width: useWidthAsBase ? base : derived,
      height: useWidthAsBase ? derived : base,
      decoration: decoration,
      child: child,
    );
  }
}

/// Golden Ratio Padding - consistent padding widget
class GoldenPadding extends StatelessWidget {
  final Widget child;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? left;
  final double? top;
  final double? right;
  final double? bottom;

  const GoldenPadding({
    super.key,
    required this.child,
    this.all,
    this.horizontal,
    this.vertical,
    this.left,
    this.top,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: left ?? horizontal ?? all ?? 0,
        top: top ?? vertical ?? all ?? 0,
        right: right ?? horizontal ?? all ?? 0,
        bottom: bottom ?? vertical ?? all ?? 0,
      ),
      child: child,
    );
  }
}

/// Golden Ratio Card - consistent card styling
class GoldenCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const GoldenCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? const Color(0xFF1A1A1E) : AppColors.cardBg;
    final defaultBorder = isDark
        ? Border.all(color: const Color(0xFF2E2E32))
        : Border.all(color: AppColors.border);
    final defaultShadow = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ];

    final card = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: borderRadius ?? BorderRadius.circular(GR.radiusLg),
        border: border ?? defaultBorder,
        boxShadow: boxShadow ?? defaultShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: card);
    }
    return card;
  }
}
