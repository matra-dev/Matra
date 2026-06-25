import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'golden_ratio.dart';
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
    color: color ?? AppColors.textPrimary,
    height: 1.0,
    letterSpacing: -1.5,
  );

  static TextStyle h1(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h1),
    fontWeight: weight ?? FontWeight.w800,
    color: color ?? AppColors.textPrimary,
    letterSpacing: -0.8,
  );

  static TextStyle h2(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h2),
    fontWeight: weight ?? FontWeight.w700,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle h3(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _h3),
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? AppColors.textPrimary,
  );

  static TextStyle body(BuildContext context, {FontWeight? weight, Color? color, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _body),
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? AppColors.textPrimary,
    height: height ?? 1.4,
  );

  static TextStyle bodySmall(BuildContext context, {FontWeight? weight, Color? color, double? height}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _bodySmall),
    fontWeight: weight ?? FontWeight.w400,
    color: color ?? AppColors.textSecondary,
    height: height ?? 1.5,
  );

  static TextStyle caption(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _caption),
    fontWeight: weight ?? FontWeight.w600,
    color: color ?? AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static TextStyle micro(BuildContext context, {FontWeight? weight, Color? color}) => TextStyle(
    fontFamily: 'Artific',
    fontSize: _sized(context, _micro),
    fontWeight: weight ?? FontWeight.w500,
    color: color ?? AppColors.textMuted,
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
