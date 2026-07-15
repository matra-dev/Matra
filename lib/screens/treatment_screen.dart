import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';
import 'add_medication_screen.dart';
import 'medication_list_screen.dart';
import 'supplement_detail_screen.dart';

class TreatmentScreen extends ConsumerStatefulWidget {
  const TreatmentScreen({super.key});

  @override
  ConsumerState<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends ConsumerState<TreatmentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) _dotsCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    super.dispose();
  }

  void _navigateToAddMedication() {
    Haptics.medium();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    );
  }

  void _navigateToMedicationList() {
    Haptics.medium();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MedicationListScreen()),
    );
  }

  void _navigateToSupplementDetail(Supplement supplement) {
    Haptics.medium();
    ref.read(selectedSupplementProvider.notifier).state = supplement;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SupplementDetailScreen(supplement: supplement)),
    );
  }

  void _showMoodBottomSheet() {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _MoodBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final supplementsAsync = ref.watch(supplementsProvider);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: GR.sm),

                // ── Header ────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(Icons.settings_outlined, size: GR.iconSm, color: tc.textPrimary),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.lg),

                // ── Adherence Hero ───────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Adherence',
                        style: AppTextStyles.h2(context),
                      ),
                      SizedBox(height: GR.xs + 2),
                      Text(
                        'This Week \u00B7 Track your progress',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 150.ms, duration: 700.ms)
                    .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 700.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl + 2),

                // ── Big Adherence Value ──────────────────────────────
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
                            (86 * v).toStringAsFixed(0),
                            style: AppTextStyles.display(context),
                          );
                        },
                      ),
                      SizedBox(width: GR.xs + 2),
                      Padding(
                        padding: EdgeInsets.only(bottom: GR.md + 2),
                        child: Text(
                          '%',
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
                      'Excellent',
                      style: AppTextStyles.caption(context, weight: FontWeight.w700, color: tc.accentDark),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0), delay: 500.ms, duration: 500.ms, curve: Curves.easeOutBack),

                SizedBox(height: GR.xl + 2),

                // ── Dot Matrix Adherence Scale ───────────────────────
                AnimatedBuilder(
                  animation: _dotsCtrl,
                  builder: (context, child) {
                    final progress = Curves.easeOutCubic.transform(_dotsCtrl.value);
                    return _DotMatrixScale(
                      value: 86,
                      min: 0,
                      max: 100,
                      progress: progress,
                    );
                  },
                ),

                SizedBox(height: GR.xl + 2),

                // ── Quick Actions ────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.add_rounded,
                        label: 'Add Med',
                        color: tc.accentDark,
                        delay: 100,
                        controller: _entranceCtrl,
                        onTap: _navigateToAddMedication,
                      ),
                    ),
                    SizedBox(width: GR.md),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.sentiment_satisfied_rounded,
                        label: 'Mood',
                        color: tc.textSecondary,
                        delay: 150,
                        controller: _entranceCtrl,
                        onTap: _showMoodBottomSheet,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: GR.lg),

                // ── Medications Section ──────────────────────────────
                Row(
                  children: [
                    Text(
                      'My Medications',
                      style: AppTextStyles.h3(context),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _navigateToMedicationList,
                      child: Text(
                        'See All',
                        style: AppTextStyles.caption(context, color: tc.accent),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 250.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.md),

                // ── Real Medication List from Provider ───────────────
                supplementsAsync.when(
                  loading: () => Center(
                    child: Padding(
                      padding: EdgeInsets.all(GR.xl),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: tc.accent,
                      ),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(GR.xl),
                      child: Text(
                        'Error loading medications',
                        style: AppTextStyles.bodySmall(context, color: tc.textMuted),
                      ),
                    ),
                  ),
                  data: (supplements) {
                    if (supplements.isEmpty) {
                      return _buildEmptyState(context, tc);
                    }
                    return Column(
                      children: supplements.take(5).toList().asMap().entries.map((entry) {
                        final i = entry.key;
                        final supp = entry.value;
                        final isLow = supp.isLowStock;

                        return GestureDetector(
                          onTap: () => _navigateToSupplementDetail(supp),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon
                                SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Icon(
                                    _getIconForSupplement(supp.name),
                                    size: 26,
                                    color: isLow ? tc.orange : tc.accentDark,
                                  ),
                                ),
                                SizedBox(width: GR.md),
                                // Name + schedule
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        supp.name,
                                        style: AppTextStyles.body(context, weight: FontWeight.w500),
                                      ),
                                      SizedBox(height: GR.xs - 2),
                                      Text(
                                        _formatSchedule(supp.timeSlots),
                                        style: AppTextStyles.bodySmall(context),
                                      ),
                                    ],
                                  ),
                                ),
                                // Stock badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                                  decoration: BoxDecoration(
                                    color: isLow ? tc.orangeLight.withValues(alpha: 0.5) : tc.accentBg,
                                    borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                  ),
                                  child: Text(
                                    '${supp.stockCount}',
                                    style: AppTextStyles.caption(
                                      context,
                                      weight: FontWeight.w700,
                                      color: isLow ? tc.orange : tc.accentDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            .animate(controller: _entranceCtrl)
                            .fadeIn(delay: Duration(milliseconds: 300 + i * 100), duration: 500.ms)
                            .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 300 + i * 100), duration: 500.ms, curve: Curves.easeOutCubic);
                      }).toList(),
                    );
                  },
                ),

                SizedBox(height: GR.xxl + GR.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeColors tc) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: GR.xl),
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: tc.textMuted,
            ),
            SizedBox(height: GR.md),
            Text(
              'No medications yet',
              style: AppTextStyles.body(context, color: tc.textMuted),
            ),
            SizedBox(height: GR.sm),
            Text(
              'Tap "Add Med" to get started',
              style: AppTextStyles.caption(context, color: tc.textMuted),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: 300.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  IconData _getIconForSupplement(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('vitamin d') || lower.contains('d3')) return Icons.wb_sunny_rounded;
    if (lower.contains('omega') || lower.contains('fish')) return Icons.water_drop_rounded;
    if (lower.contains('magnesium')) return Icons.bolt_rounded;
    if (lower.contains('iron')) return Icons.bloodtype_rounded;
    if (lower.contains('calcium')) return Icons.fitness_center_rounded;
    if (lower.contains('probiotic')) return Icons.biotech_rounded;
    if (lower.contains('melatonin') || lower.contains('sleep')) return Icons.bedtime_rounded;
    if (lower.contains('b12') || lower.contains('vitamin b')) return Icons.energy_savings_leaf_rounded;
    if (lower.contains('zinc')) return Icons.shield_rounded;
    if (lower.contains('coq')) return Icons.favorite_rounded;
    if (lower.contains('ashwagandha') || lower.contains('ginseng')) return Icons.spa_rounded;
    if (lower.contains('vitamin c')) return Icons.apple_rounded;
    return Icons.medication_rounded;
  }

  String _formatSchedule(List<String> timeSlots) {
    if (timeSlots.isEmpty) return 'No schedule set';
    if (timeSlots.length == 1) return 'Daily \u2014 ${timeSlots.first}';
    return 'Daily \u2014 ${timeSlots.join(', ')}';
  }
}

// ─── Mood Bottom Sheet ───────────────────────────────────────────────────────
class _MoodBottomSheet extends StatefulWidget {
  const _MoodBottomSheet();

  @override
  State<_MoodBottomSheet> createState() => _MoodBottomSheetState();
}

class _MoodBottomSheetState extends State<_MoodBottomSheet> {
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '\uD83D\uDE04', 'label': 'Great'},
    {'emoji': '\uD83D\uDE42', 'label': 'Good'},
    {'emoji': '\uD83D\uDE10', 'label': 'Okay'},
    {'emoji': '\uD83D\uDE15', 'label': 'Bad'},
    {'emoji': '\uD83D\uDE22', 'label': 'Terrible'},
  ];

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(GR.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: GR.lg),
              Text(
                'How are you feeling?',
                style: AppTextStyles.h3(context),
              ),
              SizedBox(height: GR.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _moods.asMap().entries.map((entry) {
                  final i = entry.key;
                  final mood = entry.value;
                  return GestureDetector(
                    onTap: () {
                      Haptics.success();
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Text(
                          mood['emoji'] as String,
                          style: const TextStyle(fontSize: 36),
                        ),
                        SizedBox(height: GR.sm),
                        Text(
                          mood['label'] as String,
                          style: AppTextStyles.caption(context),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 80), duration: 300.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        delay: Duration(milliseconds: i * 80),
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      );
                }).toList(),
              ),
              SizedBox(height: GR.xl),
            ],
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
    const dotCount = 30;
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

// ─── Quick Action Button ─────────────────────────────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int delay;
  final AnimationController controller;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.delay,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: GR.md + 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, size: GR.iconMd, color: color),
            SizedBox(height: GR.sm),
            Text(
              label,
              style: AppTextStyles.caption(context, weight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    )
        .animate(controller: controller)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 500.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 500.ms, curve: Curves.easeOutCubic);
  }
}
