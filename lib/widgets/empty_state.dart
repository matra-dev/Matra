import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: tc.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 36,
                color: tc.accent.withValues(alpha: 0.5),
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(delay: 100.ms, duration: 500.ms),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: tc.textPrimary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: tc.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 350.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 350.ms, duration: 500.ms),
            if (action != null) ...[
              const SizedBox(height: 20),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
