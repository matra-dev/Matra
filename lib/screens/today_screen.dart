import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
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

  List<String> _getOrderedSlots(Map<String, List<Supplement>> grouped) {
    const order = ['Morning', 'Afternoon', 'Evening'];
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Out of stock!'), backgroundColor: AppColors.red),
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
    final supplementsAsync = ref.watch(supplementsProvider);
    ref.watch(doseLogsProvider);
    final weekDays = _getWeekDays();
    final now = DateTime.now();
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
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.medication_rounded,
                      title: 'No Supplements Yet',
                      subtitle: 'Add your first supplement to start tracking.',
                    ),
                  );
                }

                final grouped = _groupByTimeSlot(supplements);
                final orderedSlots = _getOrderedSlots(grouped);

                if (orderedSlots.isEmpty) {
                  return const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.schedule_rounded,
                      title: 'No Time Slots Assigned',
                      subtitle: 'Assign time slots to your supplements.',
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
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Unable to Connect',
                  subtitle: 'Check your connection.',
                  action: TextButton.icon(
                    onPressed: () => ref.read(supplementsProvider.notifier).loadSupplements(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry'),
                  ),
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

  Color get _slotColor {
    switch (slot) {
      case 'Morning':
        return const Color(0xFFFFB74D);
      case 'Afternoon':
        return const Color(0xFF4FC3F7);
      case 'Evening':
        return const Color(0xFF9575CD);
      default:
        return AppColors.accent;
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
                  color: _slotColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                ),
                child: Icon(_slotIcon, size: GR.iconSm, color: _slotColor),
              ),
              SizedBox(width: GR.sm + 2),
              Text(
                slot,
                style: TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _slotColor,
                ),
              ),
              SizedBox(width: GR.sm + 2),
              Container(
                padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                decoration: BoxDecoration(
                  color: _slotColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GR.radiusSm),
                ),
                child: Text(
                  '${supplements.length}',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    color: _slotColor,
                    fontSize: GR.textSm + 1,
                    fontWeight: FontWeight.w600,
                  ),
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

    return AnimatedBuilder(
      animation: listController,
      builder: (context, child) {
        final animationValue = listController.value;
        final delaySeconds = itemDelay.inMilliseconds / 1000;
        // Smooth ease-out curve for natural feel
        final rawProgress = (animationValue - delaySeconds) * 2.5;
        final itemProgress = rawProgress.clamp(0.0, 1.0);
        final easedProgress = 1 - (1 - itemProgress) * (1 - itemProgress); // easeOutQuad

        return Opacity(
          opacity: easedProgress,
          child: Transform.translate(
            offset: Offset(0, (1 - easedProgress) * 16),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onToggle,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: GR.sm - 2),
          child: Row(
            children: [
              SplitCapsuleIcon(
                checked: isTaken,
                onTap: onToggle,
                size: 48,
              ),
              SizedBox(width: GR.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 16,
                        fontWeight: isTaken ? FontWeight.w400 : FontWeight.w500,
                        color: isTaken ? tc.textMuted : tc.textPrimary,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                        decorationColor: tc.textMuted,
                      ),
                    ),
                    if (!isTaken) ...[
                      SizedBox(height: GR.xs - 2),
                      Text(
                        supplement.dosageText,
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: tc.textMuted,
                        ),
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
      ),
    );
  }
}
