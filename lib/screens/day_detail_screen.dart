import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import '../providers/app_provider.dart';

/// Day Detail Screen — Hero-zoomed calendar view with expandable pill breakdown
/// Opens when tapping a day in the Today page week strip
class DayDetailScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final int dayOffset;

  const DayDetailScreen({
    super.key,
    required this.selectedDate,
    required this.dayOffset,
  });

  @override
  ConsumerState<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends ConsumerState<DayDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;
  late final AnimationController _calendarCtrl;
  late final ScrollController _scrollCtrl;

  DateTime _selectedDay;

  // Track which time slots are expanded
  final Set<String> _expandedSlots = {};

  _DayDetailScreenState() : _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.selectedDate;
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

  /// Build real pill data from supplements provider + dose logs
  List<Map<String, dynamic>> _getPillsForDay(DateTime day) {
    final supplements = ref.read(supplementsProvider).value ?? [];
    final doseLogs = ref.read(doseLogsProvider).value ?? [];
    final dayStr = DateTime(day.year, day.month, day.day).toIso8601String().split('T')[0];

    if (supplements.isEmpty) return [];

    // Group supplements by time slot
    final slots = <String, List<Map<String, dynamic>>>{};
    for (final supp in supplements) {
      for (final slot in supp.timeSlots) {
        final taken = doseLogs.any((l) => 
          l.supplementId == supp.id && l.date == dayStr
        );
        slots.putIfAbsent(slot, () => []).add({
          'name': supp.name,
          'dosage': supp.dosageText,
          'taken': taken,
        });
      }
    }

    // Convert to the format the UI expects
    final slotOrder = ['Morning', 'Afternoon', 'Evening'];
    final slotIcons = {
      'Morning': Icons.wb_sunny_rounded,
      'Afternoon': Icons.wb_cloudy_rounded,
      'Evening': Icons.nights_stay_rounded,
    };
    final slotTimes = {
      'Morning': '08:00',
      'Afternoon': '13:00',
      'Evening': '20:00',
    };

    final result = <Map<String, dynamic>>[];
    for (final slotName in slotOrder) {
      if (slots.containsKey(slotName) && slots[slotName]!.isNotEmpty) {
        result.add({
          'slot': slotName,
          'time': slotTimes[slotName] ?? '12:00',
          'icon': slotIcons[slotName] ?? Icons.access_time_rounded,
          'pills': slots[slotName]!,
        });
      }
    }
    return result;
  }

  int _getAdherenceForDay(DateTime day) {
    final pills = _getPillsForDay(day);
    if (pills.isEmpty) return 100;
    int total = 0;
    int taken = 0;
    for (final slot in pills) {
      final slotPills = slot['pills'] as List<Map<String, dynamic>>;
      total += slotPills.length;
      taken += slotPills.where((p) => p['taken'] as bool).length;
    }
    return total > 0 ? ((taken / total) * 100).round() : 100;
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
    _entranceCtrl.stop();
    _dotsCtrl.stop();
    _calendarCtrl.stop();
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    _calendarCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<DateTime> _getMonthDays() {
    final firstDay = DateTime(_selectedDay.year, _selectedDay.month, 1);
    final daysInMonth = DateTime(_selectedDay.year, _selectedDay.month + 1, 0).day;
    return List.generate(daysInMonth, (i) => firstDay.add(Duration(days: i)));
  }

  void _onDaySelected(DateTime day) {
    Haptics.selection();
    setState(() {
      _selectedDay = day;
      _expandedSlots.clear(); // collapse all when switching days
    });
    // Re-trigger dot matrix animation for new day
    _dotsCtrl.stop();
    _dotsCtrl.reset();
    _dotsCtrl.forward();
  }

  void _toggleSlot(String slot) {
    Haptics.light();
    setState(() {
      if (_expandedSlots.contains(slot)) {
        _expandedSlots.remove(slot);
      } else {
        _expandedSlots.add(slot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final monthDays = _getMonthDays();
    final firstWeekday = monthDays.first.weekday % 7; // 0=Sunday
    final adherence = _getAdherenceForDay(_selectedDay);
    final isPerfect = adherence == 100;
    final pillsForDay = _getPillsForDay(_selectedDay);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ────────────────────────────────────────
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
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 1),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: tc.textPrimary),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedDay),
                      style: AppTextStyles.body(context, weight: FontWeight.w600),
                    ),
                    const Spacer(),
                    SizedBox(width: GR.lg + 2),
                  ],
                ),
              ),
            ),

            // ── Hero Date Card ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Hero(
                  tag: 'day_card_${widget.dayOffset}',
                  child: GoldenCard(
                    padding: EdgeInsets.all(GR.lg),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('EEEE').format(_selectedDay),
                                  style: AppTextStyles.h2(context),
                                ),
                                SizedBox(height: GR.xs),
                                Text(
                                  DateFormat('MMMM d, yyyy').format(_selectedDay),
                                  style: AppTextStyles.bodySmall(context),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                              decoration: BoxDecoration(
                                color: isPerfect ? tc.accentBg : tc.surface,
                                borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                              ),
                              child: Text(
                                '$adherence%',
                                style: AppTextStyles.caption(
                                  context,
                                  weight: FontWeight.w700,
                                  color: isPerfect ? tc.accentDark : tc.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: GR.lg),
                        _buildDotMatrixScale(adherence),
                        SizedBox(height: GR.sm),
                        Text(
                          isPerfect ? 'Perfect day — all doses taken' : '$adherence% adherence — some doses missed',
                          style: AppTextStyles.caption(context, color: tc.textSecondary),
                        ),
                      ],
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
                      label: 'Doses',
                      value: '${pillsForDay.fold<int>(0, (sum, s) => sum + (s['pills'] as List).length)}',
                      unit: 'scheduled',
                      color: tc.textPrimary,
                      bgColor: tc.surface,
                      delay: 0,
                    ),
                    SizedBox(width: GR.sm),
                    _buildStatCard(
                      label: 'Taken',
                      value: '${pillsForDay.fold<int>(0, (sum, s) => sum + (s['pills'] as List).where((p) => p['taken'] as bool).length)}',
                      unit: 'doses',
                      color: tc.accentDark,
                      bgColor: tc.accentBg,
                      delay: 100,
                    ),
                    SizedBox(width: GR.sm),
                    _buildStatCard(
                      label: 'Missed',
                      value: '${pillsForDay.fold<int>(0, (sum, s) => sum + (s['pills'] as List).where((p) => !(p['taken'] as bool)).length)}',
                      unit: 'doses',
                      color: tc.textSecondary,
                      bgColor: tc.surface,
                      delay: 200,
                    ),
                  ],
                ),
              ),
            ),

            // ── Water & Calorie Summary ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Consumer(
                  builder: (context, ref, _) {
                    final dayStr = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day).toIso8601String().split('T')[0];
                    final waterTotal = ref.watch(waterLogsProvider.notifier).getTotalForDate(dayStr);
                    final calorieTotal = ref.watch(calorieLogsProvider.notifier).getTotalForDate(dayStr);
                    final waterGoal = 2500;
                    final calorieGoal = 2000;
                    final waterProgress = (waterTotal / waterGoal).clamp(0.0, 1.0);
                    final calorieProgress = (calorieTotal / calorieGoal).clamp(0.0, 1.0);

                    return Row(
                      children: [
                        Expanded(
                          child: _buildTrackerSummaryCard(
                            icon: Icons.water_drop_rounded,
                            iconColor: const Color(0xFF4FC3F7),
                            label: 'Water',
                            value: '$waterTotal ml',
                            progress: waterProgress,
                            progressColor: const Color(0xFF4FC3F7),
                            delay: 250,
                          ),
                        ),
                        SizedBox(width: GR.sm),
                        Expanded(
                          child: _buildTrackerSummaryCard(
                            icon: Icons.local_fire_department_rounded,
                            iconColor: const Color(0xFFFFA726),
                            label: 'Calories',
                            value: '$calorieTotal kcal',
                            progress: calorieProgress,
                            progressColor: const Color(0xFFFFA726),
                            delay: 350,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // ── Monthly Calendar ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: GoldenCard(
                  padding: EdgeInsets.all(GR.lg),
                  child: Column(
                    children: [
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

            // ── Schedule Breakdown ─────────────────────────────
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
                    ...pillsForDay.asMap().entries.map((entry) {
                      final slot = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: GR.sm),
                        child: _buildExpandableTimeSlot(context, slot),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom padding
            SliverPadding(padding: EdgeInsets.only(bottom: GR.xxl)),
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
                ? Color.lerp(tc.textMuted, tc.accentDark, intensity)!
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
              final isSelected = day.day == _selectedDay.day &&
                  day.month == _selectedDay.month &&
                  day.year == _selectedDay.year;
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
                    onTap: () => _onDaySelected(day),
                    child: Container(
                      width: 36,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? tc.accent.withValues(alpha: 0.12) : Colors.transparent,
                        borderRadius: BorderRadius.circular(GR.radiusSm),
                        border: isToday
                            ? Border.all(color: tc.accent, width: 1.5)
                            : isSelected
                                ? Border.all(color: tc.accent.withValues(alpha: 0.3))
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: AppTextStyles.caption(
                              context,
                              weight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isToday
                                  ? tc.accent
                                  : isSelected
                                      ? tc.accentDark
                                      : tc.textPrimary,
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
                                      ? isPerfect ? tc.accent : tc.textSecondary
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

  Widget _buildTrackerSummaryCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double progress,
    required Color progressColor,
    required int delay,
  }) {
    final tc = ThemeColors.of(context);
    return GoldenCard(
      padding: EdgeInsets.all(GR.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
              const Spacer(),
              Text(
                label,
                style: AppTextStyles.caption(context, color: tc.textSecondary),
              ),
            ],
          ),
          SizedBox(height: GR.sm + 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: tc.textPrimary,
            ),
          ),
          SizedBox(height: GR.sm + 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 5,
              decoration: BoxDecoration(
                color: tc.border.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 400 + delay), duration: 500.ms)
        .slideY(begin: 0.3, end: 0, delay: Duration(milliseconds: 400 + delay), duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildExpandableTimeSlot(BuildContext context, Map<String, dynamic> slot) {
    final tc = ThemeColors.of(context);
    final slotName = slot['slot'] as String;
    final time = slot['time'] as String;
    final icon = slot['icon'] as IconData;
    final pills = slot['pills'] as List<Map<String, dynamic>>;
    final total = pills.length;
    final taken = pills.where((p) => p['taken'] as bool).length;
    final isExpanded = _expandedSlots.contains(slotName);

    Color slotColor;
    switch (slotName) {
      case 'Morning':
        slotColor = tc.textPrimary;
        break;
      case 'Afternoon':
        slotColor = tc.textSecondary;
        break;
      case 'Evening':
        slotColor = tc.textMuted;
        break;
      default:
        slotColor = tc.accent;
    }

    return GoldenCard(
      padding: EdgeInsets.all(GR.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row — tappable to expand
          GestureDetector(
            onTap: () => _toggleSlot(slotName),
            child: Row(
              children: [
                Container(
                  width: GR.lg + 2,
                  height: GR.lg + 2,
                  decoration: BoxDecoration(
                    color: slotColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                  ),
                  child: Icon(icon, size: GR.iconSm, color: slotColor),
                ),
                SizedBox(width: GR.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slotName,
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
                        color: isTaken ? slotColor : tc.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                SizedBox(width: GR.sm),
                Text(
                  '$taken/$total',
                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: slotColor),
                ),
                SizedBox(width: GR.sm),
                // Expand/collapse chevron
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: tc.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Expanded pill list
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeInCubic,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                SizedBox(height: GR.sm + 2),
                Divider(height: 1, color: tc.border),
                SizedBox(height: GR.sm + 2),
                ...pills.asMap().entries.map((pillEntry) {
                  final i = pillEntry.key;
                  final pill = pillEntry.value;
                  final isTaken = pill['taken'] as bool;
                  final isLast = i == pills.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : GR.sm + 2),
                    child: Row(
                      children: [
                        // Status icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isTaken
                                ? tc.accent.withValues(alpha: 0.12)
                                : tc.surface,
                            borderRadius: BorderRadius.circular(GR.radiusSm),
                          ),
                          child: Center(
                            child: Icon(
                              isTaken ? Icons.check_rounded : Icons.close_rounded,
                              size: 16,
                              color: isTaken ? tc.accent : tc.textMuted,
                            ),
                          ),
                        ),
                        SizedBox(width: GR.md),
                        // Pill name + dosage
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pill['name'] as String,
                                style: AppTextStyles.body(
                                  context,
                                  weight: isTaken ? FontWeight.w400 : FontWeight.w500,
                                  color: isTaken ? tc.textMuted : tc.textPrimary,
                                ),
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                pill['dosage'] as String,
                                style: AppTextStyles.caption(context, color: tc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        // Taken/Missed label
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 1),
                          decoration: BoxDecoration(
                            color: isTaken ? tc.accentBg : tc.surface,
                            borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                          ),
                          child: Text(
                            isTaken ? 'Taken' : 'Missed',
                            style: AppTextStyles.caption(
                              context,
                              weight: FontWeight.w600,
                              color: isTaken ? tc.accentDark : tc.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 600), duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 600), duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
