import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? height;
  final double? width;
  final List<Color>? gradientColors;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool animate;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.height,
    this.width,
    this.gradientColors,
    this.borderRadius = AppSpacing.cardRadius,
    this.onTap,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [
      const Color(0xFFE8F5E9).withValues(alpha: 0.7),
      const Color(0xFFD4EDDA).withValues(alpha: 0.5),
      const Color(0xFFC8E6C9).withValues(alpha: 0.3),
    ];

    Widget card = Container(
      height: height,
      width: width,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        border: Border.all(
          color: const Color(0xFFA5D6A7).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.15),
            ),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}

class LiquidGlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final List<Color>? gradientColors;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const LiquidGlassButton({
    super.key,
    required this.child,
    required this.onTap,
    this.gradientColors,
    this.borderRadius = AppSpacing.buttonRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? AppColors.greenGradient;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          boxShadow: [
            BoxShadow(
              color: colors[1].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: child,
          ),
        ),
      ),
    );
  }
}
