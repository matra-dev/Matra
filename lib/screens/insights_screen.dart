import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import 'progress_screen.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
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

  void _navigateToProgress() {
    Haptics.medium();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProgressScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GR.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: GR.sm),

                // ── Header ───────────────────────────────────────────
                Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 1),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          size: GR.iconSm + 2,
                          color: tc.textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 600.ms)
                    .slideY(begin: -0.3, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl),

                // ── Title ────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Vitamin D',
                        style: AppTextStyles.h1(context),
                      ),
                      SizedBox(height: GR.xs + 2),
                      Text(
                        'December 16, 2025 · Daily Intake',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 150.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl + 2),

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
                            style: AppTextStyles.display(context),
                          );
                        },
                      ),
                      SizedBox(width: GR.xs + 2),
                      Padding(
                        padding: EdgeInsets.only(bottom: GR.md + 2),
                        child: Text(
                          'IU',
                          style: AppTextStyles.h3(context, color: tc.textMuted),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 300.ms, duration: 800.ms)
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), delay: 300.ms, duration: 800.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.lg),

                // ── Status Pill ──────────────────────────────────────
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.md + 1, vertical: GR.xs + 2),
                    decoration: BoxDecoration(
                      color: tc.accentLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                      border: Border.all(color: tc.accentLight),
                    ),
                    child: Text(
                      'On Track',
                      style: AppTextStyles.caption(context, weight: FontWeight.w700, color: tc.accentDark),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),

                SizedBox(height: GR.xl + 2),

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

                SizedBox(height: GR.xl + 2),

                // ── Trend Card ─────────────────────────────────────────
                GoldenCard(
                  padding: EdgeInsets.all(GR.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: GR.iconSm - 2,
                            color: tc.textMuted,
                          ),
                          SizedBox(width: GR.xs + 2),
                          Text(
                            'TREND',
                            style: AppTextStyles.caption(context),
                          ),
                          const Spacer(),
                          Text(
                            'Dec 1 - Dec 16',
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                      SizedBox(height: GR.lg),
                      Row(
                        children: [
                          Container(
                            width: GR.xs + 2,
                            height: GR.xs + 2,
                            decoration: BoxDecoration(
                              color: tc.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: GR.xs + 2),
                          Text(
                            '+12%',
                            style: AppTextStyles.h2(context, color: tc.accentDark),
                          ),
                          SizedBox(width: GR.xs - 2),
                          Padding(
                            padding: EdgeInsets.only(top: GR.xs - 2),
                            child: Text(
                              'this month',
                              style: AppTextStyles.bodySmall(context),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: GR.lg + 2),
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
                    .fadeIn(delay: 700.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.md + 3),

                // ── Weekly Adherence (tappable) ────────────────────────
                GestureDetector(
                  onTap: _navigateToProgress,
                  child: GoldenCard(
                    padding: EdgeInsets.all(GR.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: GR.iconSm - 2,
                              color: tc.textMuted,
                            ),
                            SizedBox(width: GR.xs + 2),
                            Text(
                              'WEEKLY ADHERENCE',
                              style: AppTextStyles.caption(context),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Text(
                                  'View All',
                                  style: AppTextStyles.caption(context, color: tc.accent),
                                ),
                                SizedBox(width: GR.xs - 2),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: tc.accent,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: GR.md),
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
                        SizedBox(height: GR.md),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                          decoration: BoxDecoration(
                            color: tc.accentLight.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(GR.radiusMd),
                          ),
                          child: Center(
                            child: Text(
                              '6/7 days · On Track',
                              style: AppTextStyles.bodySmall(context, weight: FontWeight.w600, color: tc.accentDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 900.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xxl + GR.xl),
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
    final tc = ThemeColors.of(context);
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
                ? Color.lerp(tc.amber, tc.accentDark, intensity)!
                : tc.border;

            return Container(
              width: 5.5,
              height: 5.5,
              margin: EdgeInsets.symmetric(horizontal: GR.xs - 2),
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
        SizedBox(height: GR.sm + 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              min.toStringAsFixed(0),
              style: AppTextStyles.caption(context),
            ),
            Text(
              max.toStringAsFixed(0),
              style: AppTextStyles.caption(context),
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
        SizedBox(width: GR.sm + 2),
        // Chart area
        Expanded(
          child: CustomPaint(
            size: const Size(double.infinity, 140),
            painter: _TrendDotsPainter(
              data: data,
              minVal: minVal,
              maxVal: maxVal,
              progress: progress,
              inactiveColor: ThemeColors.of(context).border,
              amberColor: ThemeColors.of(context).amber,
              accentDarkColor: ThemeColors.of(context).accentDark,
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
      style: AppTextStyles.micro(context),
    );
  }
}

class _TrendDotsPainter extends CustomPainter {
  final List<double> data;
  final double minVal;
  final double maxVal;
  final double progress;
  final Color inactiveColor;
  final Color amberColor;
  final Color accentDarkColor;

  _TrendDotsPainter({
    required this.data,
    required this.minVal,
    required this.maxVal,
    required this.progress,
    required this.inactiveColor,
    required this.amberColor,
    required this.accentDarkColor,
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
            ? Color.lerp(amberColor, accentDarkColor, intensity)!
            : inactiveColor;

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
    final tc = ThemeColors.of(context);
    return Container(
      width: 38,
      height: 52,
      decoration: BoxDecoration(
        color: taken ? tc.accentLight.withValues(alpha: 0.3) : tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd + 1),
        border: Border.all(
          color: isToday
              ? tc.accent
              : taken
                  ? tc.accentLight
                  : tc.border,
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
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? tc.accentDark : tc.textSecondary,
            ),
          ),
          SizedBox(height: GR.xs),
          Icon(
            taken ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: GR.iconSm - 2,
            color: taken ? tc.accent : tc.textMuted,
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
