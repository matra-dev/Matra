import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';
import '../widgets/dot_matrix_loading.dart';
import 'add_medication_screen.dart';

class MedicationListScreen extends ConsumerStatefulWidget {
  const MedicationListScreen({super.key});

  @override
  ConsumerState<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends ConsumerState<MedicationListScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _showMedicationDetail(Supplement supp) {
    Haptics.medium();
    ref.read(selectedSupplementProvider.notifier).state = supp;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SupplementDetailSheet(supplement: supp),
    );
  }

  void _navigateToAddMedication() {
    Haptics.medium();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
    );
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
    if (timeSlots.isEmpty) return 'No schedule';
    if (timeSlots.length == 1) return 'Daily \u2014 ${timeSlots.first}';
    return 'Daily \u2014 ${timeSlots.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final supplementsAsync = ref.watch(supplementsProvider);
    final doseLogsAsync = ref.watch(doseLogsProvider);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Header with back + add
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
                    GestureDetector(
                      onTap: _navigateToAddMedication,
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.accent,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 1),
                        ),
                        child: Icon(Icons.add_rounded, size: GR.iconSm, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Text('My Medications', style: AppTextStyles.h2(context)),
              ),
            ),

            // Subtitle count
            SliverToBoxAdapter(
              child: supplementsAsync.when(
                loading: () => Padding(
                  padding: EdgeInsets.fromLTRB(GR.lg, GR.xs, GR.lg, 0),
                  child: Text('Loading...', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
                ),
                error: (_, __) => Padding(
                  padding: EdgeInsets.fromLTRB(GR.lg, GR.xs, GR.lg, 0),
                  child: Text('Error loading', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
                ),
                data: (supplements) {
                  final takenCount = doseLogsAsync.value?.length ?? 0;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(GR.lg, GR.xs, GR.lg, 0),
                    child: Text(
                      '${supplements.length} medications \u00B7 $takenCount taken today',
                      style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                    ),
                  );
                },
              ),
            ),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, GR.md),
                child: Divider(height: 1, color: tc.border),
              ),
            ),

            // Medication list
            supplementsAsync.when(
              loading: () => SliverToBoxAdapter(
                child: DotMatrixLoadingCenter(dotSize: 6, color: tc.accent),
              ),
              error: (_, __) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(GR.xl),
                    child: Text(
                      'Error loading medications',
                      style: AppTextStyles.bodySmall(context, color: tc.textMuted),
                    ),
                  ),
                ),
              ),
              data: (supplements) {
                if (supplements.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _buildEmptyState(context, tc),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(GR.lg, 0, GR.lg, GR.xxl),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final supp = supplements[index];
                        return _buildMedicationItem(context, supp, index);
                      },
                      childCount: supplements.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeColors tc) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: GR.xxl),
        child: Column(
          children: [
            Icon(Icons.medication_outlined, size: 48, color: tc.textMuted),
            SizedBox(height: GR.md),
            Text(
              'No medications yet',
              style: AppTextStyles.body(context, color: tc.textMuted),
            ),
            SizedBox(height: GR.sm),
            Text(
              'Tap + to add your first medication',
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

  Widget _buildMedicationItem(BuildContext context, Supplement supp, int index) {
    final tc = ThemeColors.of(context);
    final stock = supp.stockCount;
    final isLow = supp.isLowStock;
    final takenToday = ref.watch(doseLogsProvider.notifier).isTakenToday(supp.id);

    return GestureDetector(
      onTap: () => _showMedicationDetail(supp),
      child: Container(
        margin: EdgeInsets.only(bottom: GR.sm + 2),
        padding: EdgeInsets.all(GR.md),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(GR.radiusLg - 2),
          border: Border.all(color: tc.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with background circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: takenToday ? tc.accent.withValues(alpha: 0.1) : tc.surface,
                borderRadius: BorderRadius.circular(GR.radiusMd + 2),
              ),
              child: Icon(
                _getIconForSupplement(supp.name),
                size: 24,
                color: takenToday ? tc.accent : tc.textMuted,
              ),
            ),
            SizedBox(width: GR.md),

            // Name + schedule + stock bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          supp.name,
                          style: AppTextStyles.body(context, weight: FontWeight.w500),
                        ),
                      ),
                      if (isLow)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: GR.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: tc.orangeLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(GR.radiusSm),
                          ),
                          child: Text(
                            'Low',
                            style: AppTextStyles.caption(
                              context,
                              weight: FontWeight.w700,
                              color: tc.orange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: GR.xs - 2),
                  Text(
                    _formatSchedule(supp.timeSlots),
                    style: AppTextStyles.bodySmall(context),
                  ),
                  SizedBox(height: GR.xs),
                  // Stock bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: tc.surface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (stock / 60).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isLow ? tc.orange : tc.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: GR.sm),
                      Text(
                        '$stock left',
                        style: AppTextStyles.caption(
                          context,
                          weight: FontWeight.w600,
                          color: isLow ? tc.orange : tc.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: GR.sm),
            // Taken indicator
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: takenToday ? tc.accent.withValues(alpha: 0.1) : tc.surface,
                borderRadius: BorderRadius.circular(GR.radiusSm + 2),
              ),
              child: Icon(
                takenToday ? Icons.check_rounded : Icons.circle_outlined,
                size: 18,
                color: takenToday ? tc.accent : tc.textMuted,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// ─── Supplement Detail Bottom Sheet ──────────────────────────────────────────
class _SupplementDetailSheet extends StatelessWidget {
  final Supplement supplement;

  const _SupplementDetailSheet({required this.supplement});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final stock = supplement.stockCount;
    final isLow = supplement.isLowStock;

    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: EdgeInsets.only(top: GR.md),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: GR.lg),

            // Icon + name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: tc.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(GR.radiusLg - 4),
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      size: 28,
                      color: tc.accent,
                    ),
                  ),
                  SizedBox(width: GR.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplement.name,
                          style: AppTextStyles.h3(context),
                        ),
                        SizedBox(height: GR.xs - 2),
                        Text(
                          supplement.dosageText,
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: GR.lg),

            // Quick stats
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    label: 'Stock',
                    value: '$stock',
                    unit: 'remaining',
                    color: isLow ? tc.orange : tc.accent,
                    bgColor: isLow ? tc.orangeLight.withValues(alpha: 0.3) : tc.accent.withValues(alpha: 0.08),
                    progress: (stock / 60).clamp(0.0, 1.0),
                  ),
                  SizedBox(width: GR.sm),
                  _buildStatCard(
                    context,
                    label: 'Frequency',
                    value: '${supplement.frequency}x',
                    unit: 'per day',
                    color: tc.accentDark,
                    bgColor: tc.accentBg,
                    progress: supplement.frequency / 4,
                  ),
                ],
              ),
            ),
            SizedBox(height: GR.lg),

            // Details
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Container(
                padding: EdgeInsets.all(GR.md),
                decoration: BoxDecoration(
                  color: tc.cardBg,
                  borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                  border: Border.all(color: tc.border),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Schedule', _formatSchedule(supplement.timeSlots)),
                    Divider(height: 1, color: tc.border),
                    _buildDetailRow(context, 'Dosage', supplement.dosageText),
                    Divider(height: 1, color: tc.border),
                    _buildDetailRow(context, 'Started', supplement.startDate),
                  ],
                ),
              ),
            ),
            SizedBox(height: GR.lg),

            // Time chips
            if (supplement.timeSlots.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reminder times', style: AppTextStyles.body(context, weight: FontWeight.w500)),
                    SizedBox(height: GR.sm),
                    Wrap(
                      spacing: GR.sm,
                      children: supplement.timeSlots.map((time) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                          decoration: BoxDecoration(
                            color: tc.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                          ),
                          child: Text(
                            time,
                            style: AppTextStyles.caption(
                              context,
                              weight: FontWeight.w600,
                              color: tc.accentDark,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            SizedBox(height: GR.lg),

            // Close button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: GestureDetector(
                onTap: () {
                  Haptics.light();
                  Navigator.pop(context);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: tc.cardBg,
                    borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                    border: Border.all(color: tc.border),
                  ),
                  child: Center(
                    child: Text(
                      'Close',
                      style: AppTextStyles.bodySmall(context, weight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: GR.xxl),
          ],
        ),
      ),
    );
  }

  String _formatSchedule(List<String> timeSlots) {
    if (timeSlots.isEmpty) return 'No schedule';
    if (timeSlots.length == 1) return timeSlots.first;
    return timeSlots.join(', ');
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
    required double progress,
  }) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(GR.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption(context, color: tc.textSecondary)),
            SizedBox(height: GR.xs),
            Text(value, style: AppTextStyles.h3(context, color: color)),
            SizedBox(height: GR.xs - 2),
            Text(unit, style: AppTextStyles.caption(context, color: tc.textSecondary)),
            SizedBox(height: GR.sm),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
      child: Row(
        children: [
          Text(label, style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
          const Spacer(),
          Text(value, style: AppTextStyles.body(context, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}
