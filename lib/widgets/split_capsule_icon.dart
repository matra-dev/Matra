import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/haptics.dart';

/// Horizontal pill checkbox — monochromatic, minimal, splits on tap.
///
/// Design:
///   • Unchecked: Horizontal outlined pill with subtle idle float
///   • Checked: Pill breaks into left & right halves, no fill, no checkmark
///
/// Tap only — no drag/scroll/pan.
class SplitCapsuleIcon extends StatefulWidget {
  final bool checked;
  final VoidCallback onTap;
  final double size;

  const SplitCapsuleIcon({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 40,
  });

  @override
  State<SplitCapsuleIcon> createState() => _SplitCapsuleIconState();
}

class _SplitCapsuleIconState extends State<SplitCapsuleIcon>
    with TickerProviderStateMixin {
  late final AnimationController _breakCtrl;
  late final AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();
    _breakCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    if (widget.checked) _breakCtrl.value = 1.0;
  }

  @override
  void didUpdateWidget(SplitCapsuleIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _breakCtrl.animateTo(1.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
        );
      } else {
        _breakCtrl.animateTo(0.0,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _breakCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.toggle();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_breakCtrl, _floatCtrl]),
          builder: (context, child) {
            final breakP = _breakCtrl.value;
            final float = _floatCtrl.value;

            // Idle float when intact
            final floatY = breakP < 0.05
                ? math.sin(float * 2 * math.pi) * 0.8
                : 0.0;

            // Scale: press down then spring back
            final scale = breakP < 0.2
                ? 1.0 - (0.05 * (breakP / 0.2))
                : 0.95 + (0.05 * ((breakP - 0.2) / 0.8));

            return Transform.scale(
              scale: scale,
              child: Transform.translate(
                offset: Offset(0, floatY),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _PillPainter(breakProgress: breakP),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PillPainter extends CustomPainter {
  final double breakProgress;

  _PillPainter({required this.breakProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Horizontal pill dimensions
    final pillW = w * 0.62;
    final pillH = h * 0.28;
    final r = pillH / 2;

    // Split offset — left/right drift
    final splitX = breakProgress * w * 0.1;

    // Color: gray outline → teal outline when checked
    final outlineColor = Color.lerp(
      const Color(0xFFBBBBBB),
      const Color(0xFF00BFA5),
      breakProgress,
    )!;

    // === LEFT HALF ===
    canvas.save();
    canvas.translate(cx - splitX, cy);
    canvas.rotate(-breakProgress * 0.08);

    final leftPath = Path();
    // Left cap arc
    leftPath.addArc(
      Rect.fromCenter(center: Offset(-pillW / 4, 0), width: pillH, height: pillH),
      math.pi * 0.5,
      math.pi,
    );
    // Top edge to middle
    leftPath.lineTo(0, -r);
    // Bottom edge to middle
    leftPath.lineTo(0, r);
    leftPath.close();

    // Outline only — no fill
    canvas.drawPath(
      leftPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Break line
    if (breakProgress > 0.05) {
      _drawBreakLine(canvas, 0, -r, r, breakProgress, true);
    }

    canvas.restore();

    // === RIGHT HALF ===
    canvas.save();
    canvas.translate(cx + splitX, cy);
    canvas.rotate(breakProgress * 0.08);

    final rightPath = Path();
    // Right cap arc
    rightPath.addArc(
      Rect.fromCenter(center: Offset(pillW / 4, 0), width: pillH, height: pillH),
      -math.pi * 0.5,
      math.pi,
    );
    // Bottom edge to middle
    rightPath.lineTo(0, r);
    // Top edge to middle
    rightPath.lineTo(0, -r);
    rightPath.close();

    // Outline only — no fill
    canvas.drawPath(
      rightPath,
      Paint()
        ..color = outlineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Break line
    if (breakProgress > 0.05) {
      _drawBreakLine(canvas, 0, -r, r, breakProgress, false);
    }

    canvas.restore();
  }

  void _drawBreakLine(Canvas canvas, double x, double topY, double bottomY,
      double progress, bool isLeft) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final segments = 5;
    final segH = (bottomY - topY) / segments;
    final zigzag = 1.5 * progress;

    path.moveTo(x, topY);
    for (int i = 1; i < segments; i++) {
      final y = topY + i * segH;
      final offsetX = (i % 2 == 0)
          ? (isLeft ? zigzag : -zigzag)
          : (isLeft ? -zigzag : zigzag);
      path.lineTo(x + offsetX, y);
    }
    path.lineTo(x, bottomY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PillPainter old) {
    return old.breakProgress != breakProgress;
  }
}
