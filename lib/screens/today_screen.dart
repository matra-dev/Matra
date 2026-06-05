import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/supplement_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';
import '../widgets/animated_checkbox.dart';
import '../widgets/low_stock_badge.dart';
import '../widgets/empty_state.dart';

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
            const SnackBar(content: Text('Out of stock!'), backgroundColor: AppColors.danger),
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
    if (offset == _selectedDayOffset) return;
    Haptics.selection();
    setState(() => _selectedDayOffset = offset);
    _listController.reset();
    _listController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final supplementsAsync = ref.watch(supplementsProvider);
    ref.watch(doseLogsProvider);
    final weekDays = _getWeekDays();
    final now = DateTime.now();
    final selectedDate = _selectedDate;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
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
                            style: const TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
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
                            style: const TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                            ),
                          ),
                          Text(
                            DateFormat('yyyy').format(selectedDate),
                            style: const TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999),
                            ),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: weekDays.asMap().entries.map((entry) {
                    final i = entry.key;
                    final day = entry.value;
                    final isSelected = i == _selectedDayOffset;

                    return GestureDetector(
                      onTap: () => _onDaySelected(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCubic,
                        width: 48,
                        height: 64,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: isSelected ? 20 : 18,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              child: Text('${day.day}'),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white70 : const Color(0xFFAAAAAA),
                                letterSpacing: 0.5,
                              ),
                              child: Text(DateFormat('EEE').format(day).toUpperCase()),
                            ),
                          ],
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
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
        return AppColors.primary;
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
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _slotColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_slotIcon, size: 16, color: _slotColor),
              ),
              const SizedBox(width: 10),
              Text(
                slot,
                style: TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _slotColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _slotColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${supplements.length}',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    color: _slotColor,
                    fontSize: 12,
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
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              AnimatedCheckbox(
                value: isTaken,
                onChanged: (_) => onToggle(),
                size: 40,
              ),
              const SizedBox(width: 16),
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
                        color: isTaken ? const Color(0xFFBBBBBB) : Colors.black,
                        decoration: isTaken ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFFCCCCCC),
                      ),
                    ),
                    if (!isTaken) ...[
                      const SizedBox(height: 2),
                      Text(
                        supplement.dosageText,
                        style: const TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFAAAAAA),
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
