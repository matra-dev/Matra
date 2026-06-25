import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

// ─── Light Mode Palette ──────────────────────────────────────────────────────
const _bg = Color(0xFFFAFAFA);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFE8E8E8);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF6B7280);
const _textMuted = Color(0xFF9CA3AF);
const _accent = Color(0xFF00BFA5);
const _accentLight = Color(0xFFB8E0D2);
const _accentDark = Color(0xFF00897B);
const _amber = Color(0xFFFFB74D);

class MetricDetailScreen extends StatefulWidget {
  const MetricDetailScreen({super.key});

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _trendCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _trendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _dotsCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _trendCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    _trendCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Header ───────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          size: 18,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: const Icon(
                          Icons.share_outlined,
                          size: 18,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 600.ms)
                    .slideY(begin: -0.3, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                // ── Title ────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Vitamin D',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _textPrimary,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'December 16, 2025 · Daily Intake',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _textMuted,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 150.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                // ── Big Value ──────────────────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AnimatedBuilder(
                        animation: _entranceCtrl,
                        builder: (_, __) {
                          final v = Curves.easeOutCubic.transform(
                            ((_entranceCtrl.value - 0.3).clamp(0.0, 0.4)) / 0.4,
                          );
                          return Text(
                            (2000 * v).toStringAsFixed(0),
                            style: const TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: _textPrimary,
                              height: 1.0,
                              letterSpacing: -2,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text(
                          'IU',
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 300.ms, duration: 800.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 800.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── Status Pill ──────────────────────────────────────
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentLight),
                    ),
                    child: const Text(
                      'On Track',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _accentDark,
                      ),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 32),

                // ── Dot Matrix Scale ───────────────────────────────────
                AnimatedBuilder(
                  animation: _dotsCtrl,
                  builder: (context, child) {
                    final progress = Curves.easeOutCubic.transform(_dotsCtrl.value);
                    return _DotMatrixScale(
                      value: 2000,
                      min: 0,
                      max: 4000,
                      progress: progress,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // ── About Card ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 14,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ABOUT',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Essential for calcium absorption and bone health. Supports immune function and muscle strength.',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Take with a meal containing fat for best absorption. Morning doses align with natural sunlight rhythms.',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: _textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 700.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── Trend Card ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'TREND',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Dec 1 - Dec 16',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '+12%',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _accentDark,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Text(
                              'this month',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 140,
                        child: AnimatedBuilder(
                          animation: _trendCtrl,
                          builder: (context, child) {
                            final progress = Curves.easeOutCubic.transform(_trendCtrl.value);
                            return _TrendChart(
                              progress: progress,
                              data: const [1200, 1400, 1600, 1500, 1800, 2000, 1900, 2100, 2000, 2200, 2000, 2000, 2100, 1900, 2000, 2000],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 900.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── Weekly Breakdown ───────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'THIS WEEK',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _accentLight.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '6/7 days',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _accentDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DayPill(day: 'M', taken: true, delay: 0),
                          _DayPill(day: 'T', taken: true, delay: 1),
                          _DayPill(day: 'W', taken: true, delay: 2),
                          _DayPill(day: 'T', taken: true, delay: 3, isToday: true),
                          _DayPill(day: 'F', taken: true, delay: 4),
                          _DayPill(day: 'S', taken: false, delay: 5),
                          _DayPill(day: 'S', taken: true, delay: 6),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 1100.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 1100.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Dot Matrix Scale ────────────────────────────────────────────────────────
class _DotMatrixScale extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double progress;

  const _DotMatrixScale({
    required this.value,
    required this.min,
    required this.max,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    const dotCount = 40;
    final normalizedValue = ((value - min) / (max - min)).clamp(0.0, 1.0);
    final activeCount = (dotCount * normalizedValue * progress).round();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dotCount, (i) {
            final isActive = i < activeCount;
            final intensity = isActive ? (i / activeCount).clamp(0.3, 1.0) : 0.0;
            final color = isActive
                ? Color.lerp(_amber, _accentDark, intensity)!
                : const Color(0xFFE5E7EB);

            return Container(
              width: 5.5,
              height: 5.5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  delay: Duration(milliseconds: i * 15),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                );
          }),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(0),
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
            Text(
              max.toStringAsFixed(0),
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Trend Chart (Dot Matrix Line) ───────────────────────────────────────────
class _TrendChart extends StatelessWidget {
  final double progress;
  final List<double> data;

  const _TrendChart({required this.progress, required this.data});

  @override
  Widget build(BuildContext context) {
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _YLabel(maxVal.toStringAsFixed(0)),
            _YLabel(((minVal + maxVal) / 2).toStringAsFixed(0)),
            _YLabel(minVal.toStringAsFixed(0)),
          ],
        ),
        const SizedBox(width: 8),
        // Chart area
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 140),
            painter: _TrendDotsPainter(
              data: data,
              minVal: minVal,
              maxVal: maxVal,
              progress: progress,
            ),
          ),
        ),
      ],
    );
  }
}

class _YLabel extends StatelessWidget {
  final String text;
  const _YLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Artific',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: _textMuted,
      ),
    );
  }
}

class _TrendDotsPainter extends CustomPainter {
  final List<double> data;
  final double minVal;
  final double maxVal;
  final double progress;

  _TrendDotsPainter({
    required this.data,
    required this.minVal,
    required this.maxVal,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final range = maxVal - minVal;
    final colCount = data.length;
    final colWidth = size.width / colCount;
    const dotSize = 4.5;
    const dotsPerCol = 8;
    const dotSpacing = 5.5;

    final visibleCols = (colCount * progress).ceil().clamp(1, colCount);

    for (int col = 0; col < visibleCols; col++) {
      final val = data[col];
      final normalizedVal = ((val - minVal) / range).clamp(0.0, 1.0);
      final activeDots = (dotsPerCol * normalizedVal).round();

      final cx = col * colWidth + colWidth / 2;

      for (int row = 0; row < dotsPerCol; row++) {
        final isActive = row < activeDots;
        final cy = size.height - (row * dotSpacing + dotSpacing / 2);
        final intensity = isActive ? (row / activeDots).clamp(0.3, 1.0) : 0.0;

        final color = isActive
            ? Color.lerp(_amber, _accentDark, intensity)!
            : const Color(0xFFE5E7EB);

        final alpha = isActive ? 1.0 : 0.3;
        final paint = Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(cx, cy),
          dotSize / 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TrendDotsPainter old) {
    return old.progress != progress;
  }
}

// ─── Day Pill ────────────────────────────────────────────────────────────────
class _DayPill extends StatelessWidget {
  final String day;
  final bool taken;
  final bool isToday;
  final int delay;

  const _DayPill({
    required this.day,
    required this.taken,
    this.isToday = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 52,
      decoration: BoxDecoration(
        color: taken ? _accentLight.withValues(alpha: 0.3) : _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? _accent
              : taken
                  ? _accentLight
                  : _cardBorder,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? _accentDark : _textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Icon(
            taken ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 14,
            color: taken ? _accent : _textMuted,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 1200 + delay * 60), duration: 400.ms)
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: 1200 + delay * 60),
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
  }
}
