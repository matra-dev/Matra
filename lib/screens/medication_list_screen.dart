import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class MedicationListScreen extends StatefulWidget {
  const MedicationListScreen({super.key});

  @override
  State<MedicationListScreen> createState() => _MedicationListScreenState();
}

class _MedicationListScreenState extends State<MedicationListScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D3',
      'dosage': '2000 IU',
      'schedule': 'Daily — 08:00',
      'stock': 29,
      'color': AppColors.accentDark,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Softgel',
      'takenWith': 'Food',
      'nextRefill': 'Jul 12',
      'adherence': 96,
      'times': ['08:00'],
    },
    {
      'name': 'Omega-3',
      'dosage': 'Fish Oil',
      'schedule': 'Daily — 08:00',
      'stock': 45,
      'color': AppColors.blue,
      'icon': Icons.water_drop_rounded,
      'form': 'Softgel',
      'takenWith': 'Food',
      'nextRefill': 'Aug 05',
      'adherence': 92,
      'times': ['08:00'],
    },
    {
      'name': 'Magnesium',
      'dosage': '400mg',
      'schedule': 'Evening — 20:00',
      'stock': 12,
      'color': AppColors.purple,
      'icon': Icons.bolt_rounded,
      'form': 'Tablet',
      'takenWith': 'Water',
      'nextRefill': 'Jun 18',
      'adherence': 88,
      'times': ['20:00'],
    },
    {
      'name': 'Vitamin B12',
      'dosage': '1000 mcg',
      'schedule': 'Morning — 08:00',
      'stock': 60,
      'color': AppColors.orange,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Sublingual',
      'takenWith': 'Empty stomach',
      'nextRefill': 'Sep 01',
      'adherence': 98,
      'times': ['08:00'],
    },
    {
      'name': 'Zinc',
      'dosage': '25 mg',
      'schedule': 'Daily — 13:00',
      'stock': 8,
      'color': AppColors.red,
      'icon': Icons.wb_cloudy_rounded,
      'form': 'Capsule',
      'takenWith': 'Food',
      'nextRefill': 'Jun 14',
      'adherence': 85,
      'times': ['13:00'],
    },
    {
      'name': 'Probiotics',
      'dosage': '50B CFU',
      'schedule': 'Morning — 08:00',
      'stock': 15,
      'color': AppColors.accentDark,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Capsule',
      'takenWith': 'Empty stomach',
      'nextRefill': 'Jun 22',
      'adherence': 90,
      'times': ['08:00'],
    },
  ];

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

  void _showMedicationDetail(Map<String, dynamic> med) {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MedicationDetailSheet(med: med),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            // Header with back button
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
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: tc.textPrimary),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // Title — h2 like Settings page, not h1
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
                child: Text(
                  'My Medications',
                  style: AppTextStyles.h2(context),
                ),
              ),
            ),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, GR.md),
                child: const Divider(height: 1, color: AppColors.border),
              ),
            ),

            // Medication list
            SliverPadding(
              padding: EdgeInsets.fromLTRB(GR.lg, 0, GR.lg, GR.xxl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final med = _medications[index];
                    final isLow = (med['stock'] as int) < 15;

                    return GestureDetector(
                      onTap: () => _showMedicationDetail(med),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon — bare, no background
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
                            // Name + schedule
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
                            // Stock badge
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs + 2),
                              decoration: BoxDecoration(
                                color: isLow ? AppColors.orangeLight.withValues(alpha: 0.5) : AppColors.accentBg,
                                borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                              ),
                              child: Text(
                                '${med['stock']}',
                                style: AppTextStyles.caption(
                                  context,
                                  weight: FontWeight.w700,
                                  color: isLow ? AppColors.orange : AppColors.accentDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms, curve: Curves.easeOutCubic);
                  },
                  childCount: _medications.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────
// Medication Detail Bottom Sheet
// ───────────────────────────────────────────────

class _MedicationDetailSheet extends StatelessWidget {
  final Map<String, dynamic> med;

  const _MedicationDetailSheet({required this.med});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isLow = (med['stock'] as int) < 15;
    final adherence = med['adherence'] as int;
    final adherenceColor = adherence >= 95
        ? tc.accentDark
        : adherence >= 85
            ? tc.orange
            : tc.red;

    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Padding(
              padding: EdgeInsets.only(top: GR.sm, bottom: GR.md),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: icon + name + dosage
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: (med['color'] as Color).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(GR.radiusMd + 4),
                    ),
                    child: Icon(
                      med['icon'] as IconData,
                      size: 28,
                      color: med['color'] as Color,
                    ),
                  ),
                  SizedBox(width: GR.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med['name'] as String,
                          style: AppTextStyles.h3(context),
                        ),
                        SizedBox(height: GR.xs - 2),
                        Text(
                          med['dosage'] as String,
                          style: AppTextStyles.bodySmall(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: GR.lg),

            // Quick stats row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    label: 'Stock',
                    value: '${med['stock']}',
                    unit: 'left',
                    color: isLow ? AppColors.orange : AppColors.accentDark,
                    bgColor: isLow ? AppColors.orangeLight.withValues(alpha: 0.4) : AppColors.accentBg,
                  ),
                  SizedBox(width: GR.sm),
                  _buildStatCard(
                    context,
                    label: 'Adherence',
                    value: '$adherence%',
                    unit: 'this month',
                    color: adherenceColor,
                    bgColor: adherenceColor.withValues(alpha: 0.1),
                  ),
                ],
              ),
            ),

            SizedBox(height: GR.lg),

            // Details list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: GoldenCard(
                padding: EdgeInsets.all(GR.md),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Schedule', med['schedule'] as String),
                    const Divider(height: 1, color: AppColors.border),
                    _buildDetailRow(context, 'Form', med['form'] as String),
                    const Divider(height: 1, color: AppColors.border),
                    _buildDetailRow(context, 'Take with', med['takenWith'] as String),
                    const Divider(height: 1, color: AppColors.border),
                    _buildDetailRow(context, 'Next refill', med['nextRefill'] as String),
                  ],
                ),
              ),
            ),

            SizedBox(height: GR.lg),

            // Time chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder times',
                    style: AppTextStyles.body(context, weight: FontWeight.w500),
                  ),
                  SizedBox(height: GR.sm),
                  Wrap(
                    spacing: GR.sm,
                    children: (med['times'] as List<String>).map((time) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        ),
                        child: Text(
                          time,
                          style: AppTextStyles.caption(
                            context,
                            weight: FontWeight.w600,
                            color: AppColors.accentDark,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: GR.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Color bgColor,
  }) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(GR.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(GR.radiusMd),
        ),
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
              style: AppTextStyles.h3(context, color: color),
            ),
            SizedBox(height: GR.xs - 2),
            Text(
              unit,
              style: AppTextStyles.caption(context, color: tc.textSecondary),
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
          Text(
            label,
            style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.body(context, weight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
