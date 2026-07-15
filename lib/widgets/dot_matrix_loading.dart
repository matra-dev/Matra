import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Dot matrix loading animation — replaces CircularProgressIndicator
/// Matches the app's dot matrix design language used in adherence scales.
class DotMatrixLoading extends StatefulWidget {
  final double dotSize;
  final int dotCount;
  final Color? color;
  final Duration duration;

  const DotMatrixLoading({
    super.key,
    this.dotSize = 6,
    this.dotCount = 5,
    this.color,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<DotMatrixLoading> createState() => _DotMatrixLoadingState();
}

class _DotMatrixLoadingState extends State<DotMatrixLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    final spacing = widget.dotSize * 0.8;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.dotCount, (i) {
            // Staggered wave animation
            final delay = i / widget.dotCount;
            final t = ((_ctrl.value - delay) % 1.0 + 1.0) % 1.0;
            final eased = Curves.easeInOutCubic.transform(t);
            
            // Scale bounces from 0.3 to 1.0 and back
            final scale = 0.3 + 0.7 * (t < 0.5 ? eased * 2 : (1 - eased) * 2).clamp(0.0, 1.0);
            // Opacity fades with scale
            final opacity = scale;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(widget.dotSize / 2),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Centered dot matrix loading with optional text below
class DotMatrixLoadingCenter extends StatelessWidget {
  final String? text;
  final Color? color;
  final double dotSize;

  const DotMatrixLoadingCenter({
    super.key,
    this.text,
    this.color,
    this.dotSize = 6,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DotMatrixLoading(color: color ?? tc.accent, dotSize: dotSize),
          if (text != null) ...[
            const SizedBox(height: 16),
            Text(
              text!,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: tc.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
