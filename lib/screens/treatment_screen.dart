import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import 'add_medication_screen.dart';
import 'medication_list_screen.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D3',
      'dosage': '2000 IU',
      'schedule': 'Daily — 08:00',
      'stock': 29,
      'color': AppColors.accentDark,
      'icon': Icons.wb_sunny_rounded,
    },
    {
      'name': 'Omega-3',
      'dosage': 'Fish Oil',
      'schedule': 'Daily — 08:00',
      'stock': 45,
      'color': AppColors.textSecondary,
      'icon': Icons.water_drop_rounded,
    },
    {
      'name': 'Magnesium',
      'dosage': '400mg',
      'schedule': 'Evening — 20:00',
      'stock': 12,
      'color': AppColors.textMuted,
      'icon': Icons.bolt_rounded,
    },
  ];

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

                // ── Header (no heading, just action icon) ────────────
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
                        'This Week · 6 of 7 days',
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

                // ── Medication List (like Today page) ────────────────
                ..._medications.asMap().entries.map((entry) {
                  final i = entry.key;
                  final med = entry.value;
                  final isLow = (med['stock'] as int) < 15;

                  return GestureDetector(
                    onTap: () => Haptics.light(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon circle — no border, no fill, just icon
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: Icon(
                              med['icon'] as IconData,
                              size: 26,
                              color: med['color'] as Color,
                            ),
                          ),
                          SizedBox(width: GR.md),
                          // Name + schedule — like Today page name + dosage
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  med['name'] as String,
                                  style: AppTextStyles.body(context, weight: FontWeight.w500),
                                ),
                                SizedBox(height: GR.xs - 2),
                                Text(
                                  med['schedule'] as String,
                                  style: AppTextStyles.bodySmall(context),
                                ),
                              ],
                            ),
                          ),
                          // Stock badge — like LowStockBadge position
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                            decoration: BoxDecoration(
                              color: isLow ? tc.orangeLight.withValues(alpha: 0.5) : tc.accentBg,
                              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                            ),
                            child: Text(
                              '${med['stock']}',
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
                }),

                SizedBox(height: GR.xxl + GR.xl),
              ],
            ),
          ),
        ),
      ),
    );
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
    {'emoji': '😄', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😕', 'label': 'Bad'},
    {'emoji': '😢', 'label': 'Terrible'},
  ];

  void _logMood(String label) {
    Haptics.medium();
    // Log mood with timestamp (could be stored in provider in future)
    final timestamp = DateTime.now();
    debugPrint('Mood logged: $label at $timestamp');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, GR.lg + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: tc.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: GR.lg),

          Text(
            'How are you feeling?',
            style: AppTextStyles.h2(context),
          ),
          SizedBox(height: GR.xs + 2),
          Text(
            'Track your mood to see patterns over time',
            style: AppTextStyles.bodySmall(context),
          ),
          SizedBox(height: GR.xl + 2),

          // Mood icons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _moods.map((mood) {
              return GestureDetector(
                onTap: () => _logMood(mood['label'] as String),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: tc.surface,
                        borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                        border: Border.all(color: tc.border),
                      ),
                      child: Center(
                        child: Text(
                          mood['emoji'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    SizedBox(height: GR.sm),
                    Text(
                      mood['label'] as String,
                      style: AppTextStyles.caption(context, color: tc.textSecondary),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: GR.lg),
        ],
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

// ─── Quick Action Button ───────────────────────────────────────────────────
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
