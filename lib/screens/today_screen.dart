import '../widgets/dot_matrix_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/supplement_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import '../widgets/split_capsule_icon.dart';
import '../widgets/low_stock_badge.dart';
import '../widgets/empty_state.dart';
import 'day_detail_screen.dart';

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with TickerProviderStateMixin {
  late final AnimationController _listController;
  int _selectedDayOffset = 0;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doseLogsProvider.notifier).loadTodayLogs();
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _listController.stop();
    _listController.dispose();
    super.dispose();
  }

  Map<String, List<Supplement>> _groupByTimeSlot(List<Supplement> supplements) {
    final grouped = <String, List<Supplement>>{};
    for (final supp in supplements) {
      for (final slot in supp.timeSlots) {
        grouped.putIfAbsent(slot, () => []).add(supp);
      }
    }
    return grouped;
  }

  List<String> _getOrderedSlots(Map<String, List<Supplement>> grouped, AppLocalizations l10n) {
    final order = [l10n.morning, l10n.afternoon, l10n.evening];
    return order.where((slot) => grouped.containsKey(slot) && grouped[slot]!.isNotEmpty).toList();
  }

  Future<void> _toggleDose(Supplement supplement) async {
    final isTaken = ref.read(doseLogsProvider.notifier).isTakenToday(supplement.id);
    if (isTaken) {
      await ref.read(doseLogsProvider.notifier).unlogDose(supplement.id);
      await ref.read(supplementsProvider.notifier).incrementStock(supplement.id);
      Haptics.light();
    } else {
      if (supplement.stockCount > 0) {
        await ref.read(doseLogsProvider.notifier).logDose(supplement.id);
        await ref.read(supplementsProvider.notifier).decrementStock(supplement.id);
        Haptics.success();
      } else {
        Haptics.error();
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.outOfStock), backgroundColor: AppColors.red),
          );
        }
      }
    }
  }

  List<DateTime> _getWeekDays() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
  }

  DateTime get _selectedDate {
    final now = DateTime.now();
    return now.add(Duration(days: _selectedDayOffset));
  }

  void _onDaySelected(int offset) {
    if (offset == _selectedDayOffset) {
      // Same day tapped — open detail with hero zoom
      Haptics.medium();
      _openDayDetail(offset);
      return;
    }
    Haptics.selection();
    setState(() => _selectedDayOffset = offset);
    _listController.stop();
    _listController.reset();
    _listController.forward();
  }

  void _openDayDetail(int offset) {
    Haptics.medium();
    final selectedDate = DateTime.now().add(Duration(days: offset));
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: DayDetailScreen(
              selectedDate: selectedDate,
              dayOffset: offset,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final supplementsAsync = ref.watch(supplementsProvider);
    ref.watch(doseLogsProvider);
    final weekDays = _getWeekDays();
    final selectedDate = _selectedDate;

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.3),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            DateFormat('EEE').format(selectedDate),
                            key: ValueKey(_selectedDayOffset),
                            style: AppTextStyles.h1(context),
                          ),
                        ),
                        SizedBox(width: GR.xs + 2),
                        Container(
                          width: GR.xs + 2,
                          height: GR.xs + 2,
                          margin: EdgeInsets.only(top: GR.xs + 2),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF6B6B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        key: ValueKey(_selectedDayOffset),
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat('MMMM d').format(selectedDate),
                            style: AppTextStyles.bodySmall(context),
                          ),
                          Text(
                            DateFormat('yyyy').format(selectedDate),
                            style: AppTextStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Week strip
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.md, GR.sm, GR.md, GR.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.asMap().entries.map((entry) {
                    final i = entry.key;
                    final day = entry.value;
                    final isSelected = i == _selectedDayOffset;

                    return GestureDetector(
                      onTap: () => _onDaySelected(i),
                      child: Hero(
                        tag: 'day_card_$i',
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          width: 48,
                          height: 64,
                          decoration: BoxDecoration(
                            color: isSelected ? tc.surface : Colors.transparent,
                            borderRadius: BorderRadius.circular(GR.radiusMd + 3),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: isSelected ? 24 : 20,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  color: isSelected ? tc.accent : tc.textPrimary,
                                ),
                                child: Text('${day.day}'),
                              ),
                              SizedBox(height: GR.xs),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeOutCubic,
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? tc.accent.withValues(alpha: 0.7) : tc.textMuted,
                                  letterSpacing: 0.5,
                                ),
                                child: Text(DateFormat('EEE').format(day).toUpperCase()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate(delay: Duration(milliseconds: i * 60))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.5, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                  }).toList(),
                ),
              ),
            ),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Divider(height: 1, color: tc.border),
              ),
            ),

            // Content
            supplementsAsync.when(
              data: (supplements) {
                if (supplements.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.medication_rounded,
                      title: l10n.noSupplementsYet,
                      subtitle: l10n.noSupplementsSubtitle,
                    ),
                  );
                }

                final grouped = _groupByTimeSlot(supplements);
                final orderedSlots = _getOrderedSlots(grouped, l10n);

                if (orderedSlots.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.schedule_rounded,
                      title: l10n.noTimeSlotsAssigned,
                      subtitle: l10n.assignTimeSlots,
                    ),
                  );
                }

                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, GR.xl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final slot = orderedSlots[index];
                        final slotSupplements = grouped[slot]!;
                        return _TimeSlotSection(
                          slot: slot,
                          supplements: slotSupplements,
                          onToggle: _toggleDose,
                          listController: _listController,
                          sectionIndex: index,
                          selectedDate: selectedDate,
                        );
                      },
                      childCount: orderedSlots.length,
                    ),
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: DotMatrixLoadingCenter(dotSize: 6, color: tc.accent),
              ),
              error: (err, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: l10n.unableToConnect,
                  subtitle: l10n.checkConnection,
                  action: TextButton.icon(
                    onPressed: () => ref.read(supplementsProvider.notifier).loadSupplements(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                  ),
                ),
              ),
            ),

            // ── Water & Calorie Trackers ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, GR.xl + 4),
                child: Row(
                  children: [
                    Expanded(
                      child: _WaterTrackerCard(
                        listController: _listController,
                      ),
                    ),
                    SizedBox(width: GR.sm + 2),
                    Expanded(
                      child: _CalorieTrackerCard(
                        listController: _listController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotSection extends StatelessWidget {
  final String slot;
  final List<Supplement> supplements;
  final Future<void> Function(Supplement) onToggle;
  final AnimationController listController;
  final int sectionIndex;
  final DateTime selectedDate;

  const _TimeSlotSection({
    required this.slot,
    required this.supplements,
    required this.onToggle,
    required this.listController,
    required this.sectionIndex,
    required this.selectedDate,
  });

  Color _slotColor(BuildContext context) {
    final tc = ThemeColors.of(context);
    switch (slot) {
      case 'Morning':
        return tc.textPrimary;
      case 'Afternoon':
        return tc.textSecondary;
      case 'Evening':
        return tc.textMuted;
      default:
        return tc.accent;
    }
  }

  IconData get _slotIcon {
    switch (slot) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_cloudy_rounded;
      case 'Evening':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time slot header
        Padding(
          padding: EdgeInsets.only(bottom: GR.md, top: GR.sm),
          child: Row(
            children: [
              Container(
                width: GR.lg + 2,
                height: GR.lg + 2,
                decoration: BoxDecoration(
                  color: _slotColor(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                ),
                child: Icon(_slotIcon, size: GR.iconSm, color: _slotColor(context)),
              ),
              SizedBox(width: GR.sm + 2),
              Text(
                slot,
                style: AppTextStyles.body(context, weight: FontWeight.w600, color: _slotColor(context)),
              ),
              SizedBox(width: GR.sm + 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                decoration: BoxDecoration(
                  color: _slotColor(context).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GR.radiusSm),
                ),
                child: Text(
                  '${supplements.length}',
                  style: AppTextStyles.caption(context, weight: FontWeight.w600, color: _slotColor(context)),
                ),
              ),
            ],
          ),
        ).animate(controller: listController)
            .fadeIn(delay: Duration(milliseconds: sectionIndex * 300))
            .slideY(begin: 0.3, end: 0, delay: Duration(milliseconds: sectionIndex * 300), curve: Curves.easeOutCubic),

        // Supplement items with staggered reveal
        ...supplements.asMap().entries.map((entry) {
          final i = entry.key;
          final supp = entry.value;
          return Consumer(
            builder: (context, ref, _) {
              final isTaken = ref.watch(doseLogsProvider.notifier).isTakenToday(supp.id);
              return _SupplementRow(
                supplement: supp,
                isTaken: isTaken,
                onToggle: () => onToggle(supp),
                index: i,
                sectionIndex: sectionIndex,
                listController: listController,
              );
            },
          );
        }),

        const SizedBox(height: 8),
      ],
    );
  }
}

class _SupplementRow extends StatelessWidget {
  final Supplement supplement;
  final bool isTaken;
  final VoidCallback onToggle;
  final int index;
  final int sectionIndex;
  final AnimationController listController;

  const _SupplementRow({
    required this.supplement,
    required this.isTaken,
    required this.onToggle,
    required this.index,
    required this.sectionIndex,
    required this.listController,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    // Morning section (index 0) shows first with no delay per item
    // Other sections have a 400ms "transition" delay before they start appearing
    final baseDelay = sectionIndex == 0 ? 0 : 400;
    final itemDelay = Duration(
      milliseconds: baseDelay + (sectionIndex * 200) + (index * 100) + 100,
    );

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: GR.sm - 2),
        child: Row(
          children: [
            SplitCapsuleIcon(
              checked: isTaken,
              onTap: onToggle,
              size: 36,
            ),
            SizedBox(width: GR.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement.name,
                    style: AppTextStyles.body(context, weight: isTaken ? FontWeight.w400 : FontWeight.w500, color: isTaken ? tc.textMuted : tc.textPrimary),
                  ),
                  if (!isTaken) ...[
                    SizedBox(height: GR.xs - 2),
                    Text(
                      supplement.dosageText,
                      style: AppTextStyles.bodySmall(context, color: tc.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            LowStockBadge(
              stockCount: supplement.stockCount,
              frequency: supplement.frequency,
            ),
          ],
        ),
      ),
    ).animate(controller: listController)
        .fadeIn(delay: itemDelay)
        .slideY(begin: 0.3, end: 0, delay: itemDelay, curve: Curves.easeOutCubic);
  }
}

// ─── Water Tracker Card ─────────────────────────────────────────────────
class _WaterTrackerCard extends ConsumerStatefulWidget {
  final AnimationController listController;

  const _WaterTrackerCard({required this.listController});

  @override
  ConsumerState<_WaterTrackerCard> createState() => _WaterTrackerCardState();
}

class _WaterTrackerCardState extends ConsumerState<_WaterTrackerCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(waterLogsProvider.notifier).loadTodayLogs();
    });
  }

  void _showAddWaterSheet() {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddWaterSheet(
        onAdd: (amount) async {
          await ref.read(waterLogsProvider.notifier).addWaterLog(amount);
          Haptics.success();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final waterAsync = ref.watch(waterLogsProvider);
    final dailyGoal = 2500; // ml
    final current = waterAsync.value?.fold<int>(
          0,
          (sum, l) => sum + l.amountMl,
        ) ??
        0;
    final progress = (current / dailyGoal).clamp(0.0, 1.0);
    final remaining = (dailyGoal - current).clamp(0, dailyGoal);

    return GestureDetector(
      onTap: _showAddWaterSheet,
      child: Container(
        padding: EdgeInsets.all(GR.md + 2),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
          border: Border.all(color: tc.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4FC3F7).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFF4FC3F7)),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: tc.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, size: 14, color: tc.accent),
                ),
              ],
            ),
            SizedBox(height: GR.md),
            Text(
              '$current ml',
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary,
              ),
            ),
            SizedBox(height: GR.xs - 2),
            Text(
              remaining > 0 ? '$remaining ml to goal' : 'Goal reached!',
              style: AppTextStyles.caption(context, color: tc.textSecondary),
            ),
            SizedBox(height: GR.sm + 2),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: tc.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: progress * (MediaQuery.of(context).size.width * 0.35),
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC3F7),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Mini log dots
            if (waterAsync.value != null && waterAsync.value!.isNotEmpty) ...[
              SizedBox(height: GR.sm + 2),
              Wrap(
                spacing: 3,
                runSpacing: 3,
                children: waterAsync.value!.take(8).map((log) {
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4FC3F7).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ).animate(controller: widget.listController)
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Calorie Tracker Card ───────────────────────────────────────────────
class _CalorieTrackerCard extends ConsumerStatefulWidget {
  final AnimationController listController;

  const _CalorieTrackerCard({required this.listController});

  @override
  ConsumerState<_CalorieTrackerCard> createState() => _CalorieTrackerCardState();
}

class _CalorieTrackerCardState extends ConsumerState<_CalorieTrackerCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calorieLogsProvider.notifier).loadTodayLogs();
    });
  }

  void _showAddCalorieSheet() {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddCalorieSheet(
        onAdd: (calories, mealType) async {
          await ref.read(calorieLogsProvider.notifier).addCalorieLog(calories, mealType);
          Haptics.success();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final calorieAsync = ref.watch(calorieLogsProvider);
    final dailyGoal = 2000; // kcal
    final current = calorieAsync.value?.fold<int>(
          0,
          (sum, l) => sum + l.calories,
        ) ??
        0;
    final progress = (current / dailyGoal).clamp(0.0, 1.0);
    final remaining = (dailyGoal - current).clamp(0, dailyGoal);

    // Meal breakdown
    final meals = <String, int>{};
    for (final log in calorieAsync.value ?? []) {
      meals[log.mealType] = ((meals[log.mealType] ?? 0) + log.calories).toInt();
    }

    return GestureDetector(
      onTap: _showAddCalorieSheet,
      child: Container(
        padding: EdgeInsets.all(GR.md + 2),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
          border: Border.all(color: tc.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFFFA726)),
                ),
                const Spacer(),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: tc.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.add_rounded, size: 14, color: tc.accent),
                ),
              ],
            ),
            SizedBox(height: GR.md),
            Text(
              '$current kcal',
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: tc.textPrimary,
              ),
            ),
            SizedBox(height: GR.xs - 2),
            Text(
              remaining > 0 ? '$remaining kcal to goal' : 'Goal reached!',
              style: AppTextStyles.caption(context, color: tc.textSecondary),
            ),
            SizedBox(height: GR.sm + 2),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: tc.border.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      width: progress * (MediaQuery.of(context).size.width * 0.35),
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Meal breakdown
            if (meals.isNotEmpty) ...[
              SizedBox(height: GR.sm + 2),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: meals.entries.map((entry) {
                  final mealColors = {
                    'breakfast': const Color(0xFF9575CD),
                    'lunch': const Color(0xFF4FC3F7),
                    'dinner': const Color(0xFFFF6B6B),
                    'snack': const Color(0xFF00BFA5),
                  };
                  final color = mealColors[entry.key] ?? tc.textSecondary;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.sm, vertical: GR.xs),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(GR.radiusSm),
                    ),
                    child: Text(
                      '${entry.key[0].toUpperCase()}${entry.key.substring(1)} ${entry.value}',
                      style: AppTextStyles.micro(context, color: color, weight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    ).animate(controller: widget.listController)
        .fadeIn(delay: 400.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Add Water Bottom Sheet ───────────────────────────────────────────
class _AddWaterSheet extends StatefulWidget {
  final Function(int) onAdd;

  const _AddWaterSheet({required this.onAdd});

  @override
  State<_AddWaterSheet> createState() => _AddWaterSheetState();
}

class _AddWaterSheetState extends State<_AddWaterSheet> {
  final _amounts = [150, 250, 330, 500];
  int _customAmount = 250;

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(GR.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: GR.lg),
              Text('Log Water', style: AppTextStyles.h2(context)),
              SizedBox(height: GR.xs),
              Text('Stay hydrated throughout the day', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
              SizedBox(height: GR.lg + 2),
              Wrap(
                spacing: GR.sm,
                runSpacing: GR.sm,
                children: _amounts.map((amount) {
                  return GestureDetector(
                    onTap: () {
                      widget.onAdd(amount);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: tc.cardBg,
                        borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                        border: Border.all(color: tc.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.water_drop_rounded, size: 24, color: const Color(0xFF4FC3F7)),
                          SizedBox(height: GR.xs),
                          Text('$amount ml', style: AppTextStyles.bodySmall(context, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: GR.md),
              // Custom amount
              Container(
                padding: EdgeInsets.symmetric(horizontal: GR.md),
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(GR.radiusMd),
                  border: Border.all(color: tc.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Custom amount (ml)',
                          hintStyle: TextStyle(fontFamily: 'Artific', fontSize: 14, color: tc.textMuted),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontFamily: 'Artific', fontSize: 15, color: tc.textPrimary),
                        onChanged: (v) => _customAmount = int.tryParse(v) ?? 250,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onAdd(_customAmount.clamp(1, 5000));
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FC3F7),
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        ),
                        child: Text('Add', style: AppTextStyles.button(context, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Add Calorie Bottom Sheet ───────────────────────────────────────────
class _AddCalorieSheet extends StatefulWidget {
  final Function(int, String) onAdd;

  const _AddCalorieSheet({required this.onAdd});

  @override
  State<_AddCalorieSheet> createState() => _AddCalorieSheetState();
}

class _AddCalorieSheetState extends State<_AddCalorieSheet> {
  String _selectedMeal = 'snack';
  int _calories = 200;

  final _mealOptions = [
    {'type': 'breakfast', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFF9575CD)},
    {'type': 'lunch', 'icon': Icons.wb_cloudy_rounded, 'color': const Color(0xFF4FC3F7)},
    {'type': 'dinner', 'icon': Icons.nights_stay_rounded, 'color': const Color(0xFFFF6B6B)},
    {'type': 'snack', 'icon': Icons.cookie_rounded, 'color': const Color(0xFF00BFA5)},
  ];

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(GR.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: GR.lg),
              Text('Log Calories', style: AppTextStyles.h2(context)),
              SizedBox(height: GR.xs),
              Text('Track your daily energy intake', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
              SizedBox(height: GR.lg + 2),
              // Meal type selector
              Row(
                children: _mealOptions.map((meal) {
                  final isSelected = _selectedMeal == meal['type'];
                  final color = meal['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMeal = meal['type'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withValues(alpha: 0.12) : tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                          border: Border.all(
                            color: isSelected ? color.withValues(alpha: 0.4) : tc.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(meal['icon'] as IconData, size: 18, color: isSelected ? color : tc.textMuted),
                            SizedBox(height: GR.xs - 2),
                            Text(
                              (meal['type'] as String)[0].toUpperCase() + (meal['type'] as String).substring(1),
                              style: AppTextStyles.micro(
                                context,
                                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? color : tc.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: GR.lg),
              // Calorie input
              Container(
                padding: EdgeInsets.symmetric(horizontal: GR.md),
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(GR.radiusMd),
                  border: Border.all(color: tc.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Calories (kcal)',
                          hintStyle: TextStyle(fontFamily: 'Artific', fontSize: 14, color: tc.textMuted),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(fontFamily: 'Artific', fontSize: 15, color: tc.textPrimary),
                        onChanged: (v) => _calories = int.tryParse(v) ?? 200,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        widget.onAdd(_calories.clamp(1, 10000), _selectedMeal);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA726),
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        ),
                        child: Text('Add', style: AppTextStyles.button(context, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
      ),
    );
  }
}
