import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
export 'golden_ratio.dart' show AppColors, GR, GoldenCard, GoldenBox, GoldenPadding;

/// Font Size Scale for Accessibility
/// 
/// WhatsApp uses: Small (0.85), Normal (1.0), Large (1.15), Extra Large (1.3)
/// Instagram uses: Small (0.9), Normal (1.0), Large (1.15), Extra Large (1.3)
/// We follow this proven pattern.

enum FontSizeLevel {
  small('Small', 0.88),
  normal('Normal', 1.0),
  large('Large', 1.15),
  huge('Huge', 1.35);

  final String label;
  final double scale;
  const FontSizeLevel(this.label, this.scale);

  static FontSizeLevel fromScale(double scale) {
    return values.firstWhere(
      (v) => v.scale == scale,
      orElse: () => FontSizeLevel.normal,
    );
  }
}

/// Provider for font size level
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, FontSizeLevel>(
  (ref) => FontSizeNotifier(),
);

class FontSizeNotifier extends StateNotifier<FontSizeLevel> {
  static const _key = 'font_size_level';

  FontSizeNotifier() : super(FontSizeLevel.normal) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) {
      state = FontSizeLevel.fromScale(saved);
    }
  }

  Future<void> setLevel(FontSizeLevel level) async {
    state = level;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, level.scale);
  }
}

// ─── Dark Mode Provider ────────────────────────────────────────────────────

final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>(
  (ref) => DarkModeNotifier(),
);

class DarkModeNotifier extends StateNotifier<bool> {
  static const _key = 'dark_mode';

  DarkModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setDarkMode(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  Future<void> toggle() async {
    final newValue = !state;
    state = newValue;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, newValue);
  }
}

// ─── Dynamic App Colors (theme-aware) ─────────────────────────────────────

/// Use these instead of static AppColors for dark mode support.
/// Access via: `ThemeColors.of(context)` in any widget.
class ThemeColors {
  final bool isDark;

  const ThemeColors._(this.isDark);

  static ThemeColors of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ThemeColors._(isDark);
  }

  // Backgrounds
  Color get bg => isDark ? const Color(0xFF0D0D0F) : const Color(0xFFFAFAFA);
  Color get cardBg => isDark ? const Color(0xFF1A1A1E) : const Color(0xFFFFFFFF);
  Color get surface => isDark ? const Color(0xFF242428) : const Color(0xFFF5F5F5);
  Color get surfaceElevated => isDark ? const Color(0xFF2A2A2E) : const Color(0xFFFFFFFF);

  // Borders
  Color get border => isDark ? const Color(0xFF2E2E32) : const Color(0xFFE8E8E8);
  Color get borderLight => isDark ? const Color(0xFF252528) : const Color(0xFFF0F0F0);
  Color get divider => isDark ? const Color(0xFF2E2E32) : const Color(0xFFE8E8E8);

  // Text
  Color get textPrimary => isDark ? const Color(0xFFF0F0F5) : const Color(0xFF1A1A2E);
  Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
  Color get textMuted => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);

  // Accent - Teal (same in both, slightly adjusted for dark)
  Color get accent => isDark ? const Color(0xFF00E5B8) : const Color(0xFF00BFA5);
  Color get accentLight => isDark ? const Color(0xFF00BFA5).withValues(alpha: 0.25) : const Color(0xFFB8E0D2);
  Color get accentDark => isDark ? const Color(0xFF00E5B8) : const Color(0xFF00897B);
  Color get accentBg => isDark ? const Color(0xFF00BFA5).withValues(alpha: 0.12) : const Color(0xFFE8F5F0);

  // Semantic (adjusted for dark readability)
  Color get orange => isDark ? const Color(0xFFFFB74D) : const Color(0xFFFFA726);
  Color get orangeLight => isDark ? const Color(0xFFFFA726).withValues(alpha: 0.2) : const Color(0xFFFFF3E0);
  Color get blue => isDark ? const Color(0xFF82B1FF) : const Color(0xFF448AFF);
  Color get purple => isDark ? const Color(0xFFB39DDB) : const Color(0xFF7E57C2);
  Color get red => isDark ? const Color(0xFFFF8A80) : const Color(0xFFEF5350);
  Color get amber => isDark ? const Color(0xFFFFD180) : const Color(0xFFFFB74D);

  // Bottom nav
  Color get navBg => isDark ? const Color(0xFF1A1A1E).withValues(alpha: 0.92) : const Color(0xFFFFFFFF).withValues(alpha: 0.92);
  Color get navBorder => isDark ? const Color(0xFF2E2E32) : const Color(0xFFEEEEEE);

  // Shadow
  Color get shadowColor => isDark ? const Color(0xFF000000).withValues(alpha: 0.3) : const Color(0xFF000000).withValues(alpha: 0.03);
}

/// Dynamic text style that respects font size setting
/// 
/// Usage: 
///   Text('Hello', style: AppTextStyles.h1(context))
///   Text('Body', style: AppTextStyles.body(context, weight: FontWeight.w600))
class AppTextStyles {
  AppTextStyles._();

  // ─── Base sizes (at Normal scale = 1.0) ───────────────────────────────────
  // These match WhatsApp/Instagram readability standards
  
  static const double _display = 48;      // Hero numbers, big stats
  static const double _h1 = 32;           // Screen titles (was 26, now readable)
  static const double _h2 = 22;           // Card titles, section headers
  static const double _h3 = 18;           // Subsection headers
  static const double _body = 16;         // Body text (WhatsApp message size)
  static const double _bodySmall = 14;    // Secondary body, descriptions
  static const double _caption = 12;      // Labels, badges, hints
  static const double _micro = 11;        // Timestamps, tiny labels

  // ─── Scale-aware getters ─────────────────────────────────────────────────
  
  static double _scale(BuildContext context) {
    // First check our app setting
    final container = ProviderContainer();
    final appScale = container.read(fontSizeProvider).scale;
    
    // Also respect system accessibility setting (but cap it to prevent overflow)
    final mediaScale = MediaQuery.textScalerOf(context).scale(1.0);
    final systemScale = mediaScale.clamp(0.8, 1.5);
    
    // Combine: app setting * system setting, but cap at 1.6x max
    return (appScale * systemScale).clamp(0.8, 1.6);
  }

  static double _sized(BuildContext context, double base) {
    return base * _scale(context);
  }

  // ─── Style builders ────────────────────────────────────────────────────────
  
  static TextStyle display(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _display),
    fontWeight: weight ?? FontWeight.w900,
    color: color ?? ThemeColors.of(context).textPrimary,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static TextStyle h1(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h1),
    fontWeight: weight ?? FontWeight.w800,
    color: color ?? ThemeColors.of(context).textPrimary,
    letterSpacing: -0.8,
  );

  static TextStyle h2(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h2),
    fontWeight: weight ?? FontWeight.w700,
    color: color ?? ThemeColors.of(context).textPrimary,
  );

  static TextStyle h3(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h3),
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? ThemeColors.of(context).textPrimary,
  );

  static TextStyle body(BuildContext context, {FontWeight? weight, Color? color, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _body),
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? ThemeColors.of(context).textPrimary,
    height: height ?? 1.4,
  );

  static TextStyle bodySmall(BuildContext context, {FontWeight? weight, Color? color, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _bodySmall),
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? ThemeColors.of(context).textSecondary,
    height: height ?? 1.5,
  );

  static TextStyle caption(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _caption),
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? ThemeColors.of(context).textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle micro(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _micro),
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? ThemeColors.of(context).textMuted,
  );

  static TextStyle button(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _body),
    fontWeight: weight ?? FontWeight.w700,
    color: color ?? Colors.white,
  );

  static TextStyle navLabel(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _micro),
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? Colors.white,
  );
}

/// App Colors (keep in sync with golden_ratio.dart)
/// 
/// NOTE: For dark mode support, use ThemeColors.of(context) instead.
/// These static colors remain for backward compatibility.
