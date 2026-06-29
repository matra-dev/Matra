import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';

/// Day Detail Screen — Hero-zoomed calendar view with dot matrix adherence
/// Opens when tapping a day in the Today page week strip
class DayDetailScreen extends StatefulWidget {
  final DateTime selectedDate;
  final int dayOffset;

  const DayDetailScreen({
    super.key,
    required this.selectedDate,
    required this.dayOffset,
  });

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _calendarCtrl;
  late final ScrollController _scrollCtrl;

  // Demo adherence data for the month (0-100 for each day)
  final List<int> _monthAdherence = [
    100, 100, 85, 100, 100, 70, 100, // week 1
    100, 100, 100, 100, 85, 100, 100, // week 2
    100, 100, 100, 60, 100, 100, 100, // week 3
    100, 100, 100, 100, 100, 100, 100, // week 4
    100, 100, 100, // remaining
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _calendarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scrollCtrl = ScrollController();
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _calendarCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _dotsCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    _calendarCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _getMonthDays() {
    final firstDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, 1);
    final daysInMonth = DateTime(widget.selectedDate.year, widget.selectedDate.month + 1, 0).day;
    return List.generate(daysInMonth, (i) => firstDay.add(Duration(days: i)));
  }

  int _getAdherenceForDay(DateTime day) {
    final dayIndex = day.day - 1;
    if (dayIndex < _monthAdherence.length) {
      return _monthAdherence[dayIndex];
    }
    return 100;
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final monthDays = _getMonthDays();
    final firstWeekday = monthDays.first.weekday % 7; // 0=Sunday
    final adherence = _getAdherenceForDay(widget.selectedDate);
    final isPerfect = adherence == 100;

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header with Hero tag ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.sm, GR.lg, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.pop(context);
                      },
                      child: Hero(
                        tag: 'day_back_button',
                        child: Container(
                          width: GR.lg + 2,
                          height: GR.lg + 2,
                          decoration: BoxDecoration(
                            color: tc.cardBg,
                            borderRadius: BorderRadius.circular(GR.radiusMd),
                            border: Border.all(color: tc.border),
                          ),
                          child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: tc.textPrimary),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // ── Hero Day Card ────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Hero(
                  tag: 'day_card_${widget.dayOffset}',
                  child: Material(
                    color: Colors.transparent,
                    child: GoldenCard(
                      padding: EdgeInsets.all(GR.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE').format(widget.selectedDate),
                                    style: AppTextStyles.h2(context),
                                  ),
                                  SizedBox(height: GR.xs),
                                  Text(
                                    DateFormat('MMMM d, yyyy').format(widget.selectedDate),
                                    style: AppTextStyles.bodySmall(context),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Big day number
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: tc.accent.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(GR.radiusMd + 4),
                                ),
                                child: Center(
                                  child: Text(
                                    '${widget.selectedDate.day}',
                                    style: AppTextStyles.display(context, color: tc.accent),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.lg),
                          // Adherence row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Adherence',
                                      style: AppTextStyles.caption(context),
                                    ),
                                    SizedBox(height: GR.xs),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _entranceCtrl,
                                          builder: (_, __) {
                                            final v = Curves.easeOutCubic.transform(_entranceCtrl.value);
                                            return Text(
                                              (adherence * v).toStringAsFixed(0),
                                              style: AppTextStyles.h1(context, color: isPerfect ? tc.accentDark : tc.orange),
                                            );
                                          },
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: GR.xs + 2),
                                          child: Text(
                                            '%',
                                            style: AppTextStyles.h3(context, color: tc.textMuted),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Status pill
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                                decoration: BoxDecoration(
                                  color: isPerfect ? tc.accentLight.withValues(alpha: 0.4) : tc.orangeLight.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                                  border: Border.all(
                                    color: isPerfect ? tc.accentLight : tc.orangeLight,
                                  ),
                                ),
                                child: Text(
                                  isPerfect ? 'Perfect' : 'Partial',
                                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: isPerfect ? tc.accentDark : tc.orange),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.lg),
                          // Dot matrix scale
                          _buildDotMatrixScale(adherence),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Stats Row ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Row(
                  children: [
                    _buildStatCard(
                      label: 'Taken',
                      value: isPerfect ? '5' : '3',
                      unit: 'supplements',
                      color: tc.accentDark,
                      bgColor: tc.accentBg,
                      delay: 0,
                    ),
                    SizedBox(width: GR.sm),
                    _buildStatCard(
                      label: 'Missed',
                      value: isPerfect ? '0' : '2',
                      unit: 'doses',
                      color: tc.orange,
                      bgColor: tc.orangeLight.withValues(alpha: 0.4),
                      delay: 100,
                    ),
                    SizedBox(width: GR.sm),
                    _buildStatCard(
                      label: 'Streak',
                      value: '12',
                      unit: 'days',
                      color: tc.blue,
                      bgColor: tc.blue.withValues(alpha: 0.1),
                      delay: 200,
                    ),
                  ],
                ),
              ),
            ),

            // ── Monthly Calendar with Dot Matrix ─────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: GoldenCard(
                  padding: EdgeInsets.all(GR.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(widget.selectedDate),
                        style: AppTextStyles.h3(context),
                      ),
                      SizedBox(height: GR.md),
                      // Day labels
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                          return SizedBox(
                            width: 36,
                            child: Text(
                              d,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption(context, weight: FontWeight.w700),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: GR.sm),
                      // Calendar grid
                      AnimatedBuilder(
                        animation: _calendarCtrl,
                        builder: (context, child) {
                          final progress = Curves.easeOutCubic.transform(_calendarCtrl.value);
                          return _buildCalendarGrid(
                            context,
                            monthDays,
                            firstWeekday,
                            progress,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Time Slot Breakdown ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule Breakdown',
                      style: AppTextStyles.h3(context),
                    ),
                    SizedBox(height: GR.md),
                    _buildTimeSlotRow(context, 'Morning', '08:00', 3, 2, Icons.wb_sunny_rounded, const Color(0xFFFFB74D)),
                    SizedBox(height: GR.sm),
                    _buildTimeSlotRow(context, 'Afternoon', '13:00', 2, 2, Icons.wb_cloudy_rounded, const Color(0xFF4FC3F7)),
                    SizedBox(height: GR.sm),
                    _buildTimeSlotRow(context, 'Evening', '20:00', 2, 1, Icons.nights_stay_rounded, const Color(0xFF9575CD)),
                  ],
                ),
              ),
            ),

            // Bottom padding
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildDotMatrixScale(int adherence) {
    final tc = ThemeColors.of(context);
    const dotCount = 30;
    final activeCount = (dotCount * adherence / 100).round();

    return AnimatedBuilder(
      animation: _dotsCtrl,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_dotsCtrl.value);
        final visibleCount = (activeCount * progress).round();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(dotCount, (i) {
            final isActive = i < visibleCount;
            final intensity = isActive ? (i / activeCount).clamp(0.3, 1.0) : 0.0;
            final color = isActive
                ? Color.lerp(tc.amber, tc.accentDark, intensity)!
                : tc.border;

            return Container(
              width: 5,
              height: 5,
              margin: EdgeInsets.symmetric(horizontal: GR.xs - 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            )
                .animate(delay: Duration(milliseconds: i * 20))
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  duration: 200.ms,
                  curve: Curves.easeOutBack,
                );
          }),
        );
      },
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    List<DateTime> days,
    int firstWeekday,
    double progress,
  ) {
    final tc = ThemeColors.of(context);
    final totalCells = firstWeekday + days.length;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: GR.sm + 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayIndex = cellIndex - firstWeekday;

              if (dayIndex < 0 || dayIndex >= days.length) {
                return const SizedBox(width: 36, height: 44);
              }

              final day = days[dayIndex];
              final isSelected = day.day == widget.selectedDate.day;
              final isToday = day.day == DateTime.now().day &&
                  day.month == DateTime.now().month &&
                  day.year == DateTime.now().year;
              final dayAdherence = _getAdherenceForDay(day);
              final isPerfect = dayAdherence == 100;

              // Stagger animation based on cell position
              final cellProgress = ((progress * totalCells - cellIndex) / 1).clamp(0.0, 1.0);
              final easedProgress = Curves.easeOutCubic.transform(cellProgress);

              return Opacity(
                opacity: easedProgress,
                child: Transform.scale(
                  scale: 0.5 + (0.5 * easedProgress),
                  child: GestureDetector(
                    onTap: () {
                      Haptics.selection();
                      // Could navigate to that day
                    },
                    child: Container(
                      width: 36,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tc.accent.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        border: Border.all(
                          color: isSelected
                              ? tc.accent
                              : isToday
                                  ? tc.accent.withValues(alpha: 0.5)
                                  : Colors.transparent,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? tc.accentDark : tc.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          // Dot matrix adherence indicator (3 dots)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (dotIndex) {
                              final threshold = (dotIndex + 1) * 33;
                              final dotActive = dayAdherence >= threshold;
                              return Container(
                                width: 3.5,
                                height: 3.5,
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  color: dotActive
                                      ? isPerfect ? tc.accent : tc.orange
                                      : tc.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required int delay,
  }) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: GoldenCard(
        padding: EdgeInsets.all(GR.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption(context, color: tc.textSecondary),
            ),
            SizedBox(height: GR.xs),
            Text(
              value,
              style: AppTextStyles.h2(context, color: color),
            ),
            SizedBox(height: GR.xs - 2),
            Text(
              unit,
              style: AppTextStyles.caption(context, color: tc.textSecondary),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 400 + delay), duration: 500.ms)
        .slideY(begin: 0.3, end: 0, delay: Duration(milliseconds: 400 + delay), duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTimeSlotRow(
    BuildContext context,
    String slot,
    String time,
    int total,
    int taken,
    IconData icon,
    Color color,
  ) {
    final tc = ThemeColors.of(context);
    final missed = total - taken;

    return GoldenCard(
      padding: EdgeInsets.all(GR.md + 2),
      child: Row(
        children: [
          Container(
            width: GR.lg + 2,
            height: GR.lg + 2,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
            ),
            child: Icon(icon, size: GR.iconSm, color: color),
          ),
          SizedBox(width: GR.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  slot,
                  style: AppTextStyles.body(context, weight: FontWeight.w600),
                ),
                SizedBox(height: GR.xs - 2),
                Text(
                  time,
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          // Mini dot matrix
          Row(
            children: List.generate(total, (i) {
              final isTaken = i < taken;
              return Container(
                width: 6,
                height: 6,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isTaken ? color : tc.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
          SizedBox(width: GR.sm),
          Text(
            '$taken/$total',
            style: AppTextStyles.caption(context, weight: FontWeight.w700, color: color),
          ),
        ],
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 600), duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 600), duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
