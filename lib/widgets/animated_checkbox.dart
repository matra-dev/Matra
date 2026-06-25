import 'package:flutter/material.dart';
import '../utils/haptics.dart';

/// Sleek animated checkbox with spring physics and checkmark draw animation.
/// 
/// Design inspired by premium iOS apps — circular shape with a smooth
/// spring bounce on tap, and a hand-drawn style checkmark that animates in.
class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 44,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    if (widget.value) {
      _fillController.value = 1.0;
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _fillController.forward(from: 0.0);
        _checkController.forward(from: 0.0);
      } else {
        _fillController.reverse();
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.toggle();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: Listenable.merge([_fillController, _checkController]),
        builder: (context, child) {
          final fillProgress = _fillController.value;
          final checkProgress = _checkController.value;

          // Scale: press down then spring back up
          final scale = fillProgress < 0.4
              ? 1.0 - (0.12 * (fillProgress / 0.4))
              : 0.88 + (0.12 * ((fillProgress - 0.4) / 0.6));

          // Color interpolation: border gray → filled accent
          final borderColor = Color.lerp(
            const Color(0xFFD0D0D0),
            const Color(0xFF00BFA5),
            fillProgress,
          )!;

          final bgColor = Color.lerp(
            Colors.transparent,
            const Color(0xFF00BFA5),
            fillProgress,
          )!;

          return Transform.scale(
            scale: scale,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(
                  color: borderColor,
                  width: 2.5,
                ),
                boxShadow: fillProgress > 0.1
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00BFA5).withValues(alpha: 0.25 * fillProgress),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: checkProgress > 0.01
                  ? CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _CheckmarkPainter(
                        progress: checkProgress,
                        color: Colors.white,
                        strokeWidth: 3.0,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws a smooth checkmark with animated stroke.
class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CheckmarkPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Checkmark path — short down stroke then long up stroke
    // Relative to the circle center
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.28;

    // Start point (left of checkmark)
    final start = Offset(cx - r * 0.6, cy + r * 0.1);
    // Corner point (bottom of first stroke)
    final corner = Offset(cx - r * 0.15, cy + r * 0.55);
    // End point (top-right of checkmark)
    final end = Offset(cx + r * 0.75, cy - r * 0.45);

    // First stroke: down to corner (0% → 45% of animation)
    final firstPhaseEnd = 0.45;
    if (progress > 0) {
      final firstProgress = (progress / firstPhaseEnd).clamp(0.0, 1.0);
      final currentCorner = Offset.lerp(start, corner, firstProgress)!;
      canvas.drawLine(start, currentCorner, paint);
    }

    // Second stroke: corner to end (45% → 100% of animation)
    if (progress > firstPhaseEnd) {
      final secondProgress = ((progress - firstPhaseEnd) / (1.0 - firstPhaseEnd)).clamp(0.0, 1.0);
      final currentEnd = Offset.lerp(corner, end, secondProgress)!;
      canvas.drawLine(corner, currentEnd, paint);
      // Also draw the completed first stroke
      canvas.drawLine(start, corner, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckmarkPainter old) {
    return old.progress != progress;
  }
}
