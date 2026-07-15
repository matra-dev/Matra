import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import 'main_navigation_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;
  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    Haptics.medium();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MainNavigationScreen();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.bg,
      body: Stack(
        children: [
          // Soft multi-color radial gradient background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.25),
                      radius: 0.85,
                      colors: [
                        const Color(0xFFE8F5E9).withValues(
                          alpha: 0.5 + (_pulseController.value * 0.15),
                        ),
                        const Color(0xFFFAFAFA),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Main content
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Title
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        final value = Curves.easeOutCubic.transform(
                          ((_entranceController.value - 0.1).clamp(0.0, 0.3)) / 0.3,
                        );
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * -20),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Matra',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: tc.textPrimary,
                              letterSpacing: -1.2,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Medication Reminder',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: tc.textSecondary,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                          Text(
                            '& Supplement Tracker',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: tc.textSecondary,
                              letterSpacing: -0.3,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 3D Rotating capsule visualization
                    SizedBox(
                      width: size.width * 0.50,
                      height: size.width * 0.65,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_rotateController, _pulseController]),
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(size.width * 0.50, size.width * 0.65),
                            painter: _CapsuleBarsPainter(
                              rotation: _rotateController.value * 2 * math.pi,
                              pulse: _pulseController.value,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Feature tags row — simple staggered fade in
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeatureTag(
                          controller: _entranceController,
                          delay: 0.45,
                          icon: Icons.schedule_rounded,
                          label: 'Reminders',
                          gradientColors: const [Color(0xFF00BFA5), Color(0xFF00E5FF)],
                        ),
                        const SizedBox(width: 8),
                        _FeatureTag(
                          controller: _entranceController,
                          delay: 0.55,
                          icon: Icons.insights_rounded,
                          label: 'Insights',
                          gradientColors: const [Color(0xFF2962FF), Color(0xFF00BFA5)],
                        ),
                        const SizedBox(width: 8),
                        _FeatureTag(
                          controller: _entranceController,
                          delay: 0.65,
                          icon: Icons.inventory_2_rounded,
                          label: 'Stock',
                          gradientColors: const [Color(0xFF00E5FF), Color(0xFF2962FF)],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Subtitle
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        final value = Curves.easeOutCubic.transform(
                          ((_entranceController.value - 0.70).clamp(0.0, 0.25)) / 0.25,
                        );
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 15),
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Never miss a dose. Track your supplements\nwith smart reminders and stock alerts.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: tc.textMuted,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Get Started button — black with rounded corners like home page
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (context, child) {
                        final value = Curves.easeOutCubic.transform(
                          ((_entranceController.value - 0.78).clamp(0.0, 0.22)) / 0.22,
                        );
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, (1 - value) * 20),
                            child: child,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: _onGetStarted,
                        child: Container(
                          width: 200,
                          height: 56,
                          decoration: BoxDecoration(
                            color: tc.textPrimary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: tc.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final IconData icon;
  final String label;
  final List<Color> gradientColors;

  const _FeatureTag({
    required this.controller,
    required this.delay,
    required this.icon,
    required this.label,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final value = Curves.easeOutCubic.transform(
          ((controller.value - delay).clamp(0.0, 0.25)) / 0.25,
        );
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: tc.cardBg.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: tc.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds);
              },
              child: Icon(
                icon,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapsuleBarsPainter extends CustomPainter {
  final double rotation;
  final double pulse;

  _CapsuleBarsPainter({
    required this.rotation,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final capsuleHeight = size.height * 0.85;
    final capsuleWidth = size.width * 0.55;

    const barCount = 32;
    const barWidth = 3.5;

    // Emerald -> Cyan -> Blue gradient stops
    const colors = [
      Color(0xFF00BFA5), // Emerald
      Color(0xFF00E5FF), // Cyan
      Color(0xFF2962FF), // Blue
    ];

    // Sort bars by depth for proper rendering
    final bars = <_BarData>[];

    for (int i = 0; i < barCount; i++) {
      final angle = (i / barCount) * 2 * math.pi + rotation;
      final x = centerX + math.sin(angle) * capsuleWidth;
      final depth = math.cos(angle); // -1 (back) to 1 (front)

      // Capsule shape height at this x position
      final normalizedX = (x - centerX) / capsuleWidth;
      final shapeFactor = math.sqrt((1 - normalizedX * normalizedX).clamp(0.0, 1.0));
      final barHeight = capsuleHeight * shapeFactor;

      bars.add(_BarData(
        x: x,
        y: centerY,
        width: barWidth,
        height: barHeight,
        depth: depth,
        index: i,
      ));
    }

    // Sort back to front
    bars.sort((a, b) => a.depth.compareTo(b.depth));

    for (final bar in bars) {
      // Depth-based opacity and glow
      final depthFactor = (bar.depth + 1) / 2; // 0 to 1
      final isFront = bar.depth > 0;

      // Position along the gradient (0 to 1) based on bar index + rotation
      final gradientPos = ((bar.index / barCount) + (rotation / (2 * math.pi))) % 1.0;

      // Interpolate between gradient colors
      final Color barColor = _lerpGradient(colors, gradientPos);

      // Pulse effect on brightness
      final pulseBoost = pulse * 0.08 * depthFactor;
      final alpha = 0.35 + (depthFactor * 0.55) + pulseBoost;

      final color = barColor.withValues(alpha: alpha.clamp(0.0, 1.0));

      // Glow effect for front bars
      if (isFront) {
        final glowPaint = Paint()
          ..color = color.withValues(alpha: 0.15 * depthFactor)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(bar.x, bar.y),
              width: bar.width + 6,
              height: bar.height + 6,
            ),
            const Radius.circular(4),
          ),
          glowPaint,
        );
      }

      // Main bar
      final barPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(bar.x, bar.y),
            width: bar.width,
            height: bar.height,
          ),
          const Radius.circular(2),
        ),
        barPaint,
      );

      // Highlight on front-facing bars
      if (isFront && depthFactor > 0.6) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.35 * depthFactor)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(bar.x - 0.5, bar.y - bar.height * 0.1),
              width: bar.width * 0.4,
              height: bar.height * 0.7,
            ),
            const Radius.circular(1),
          ),
          highlightPaint,
        );
      }
    }
  }

  Color _lerpGradient(List<Color> colors, double t) {
    if (colors.length == 1) return colors[0];

    final segment = 1.0 / (colors.length - 1);
    final index = (t / segment).floor().clamp(0, colors.length - 2);
    final localT = ((t - index * segment) / segment).clamp(0.0, 1.0);

    return Color.lerp(colors[index], colors[index + 1], localT)!;
  }

  @override
  bool shouldRepaint(covariant _CapsuleBarsPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.pulse != pulse;
  }
}

class _BarData {
  final double x;
  final double y;
  final double width;
  final double height;
  final double depth;
  final int index;

  _BarData({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.depth,
    required this.index,
  });
}
