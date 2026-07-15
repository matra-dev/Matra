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
      'maxStock': 30,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Softgel',
      'takenWith': 'Food',
      'nextRefill': 'Jul 12',
      'adherence': 96,
      'times': ['08:00'],
      'takenToday': true,
    },
    {
      'name': 'Omega-3',
      'dosage': 'Fish Oil',
      'schedule': 'Daily — 08:00',
      'stock': 45,
      'maxStock': 60,
      'icon': Icons.water_drop_rounded,
      'form': 'Softgel',
      'takenWith': 'Food',
      'nextRefill': 'Aug 05',
      'adherence': 92,
      'times': ['08:00'],
      'takenToday': true,
    },
    {
      'name': 'Magnesium',
      'dosage': '400mg',
      'schedule': 'Evening — 20:00',
      'stock': 12,
      'maxStock': 30,
      'icon': Icons.bolt_rounded,
      'form': 'Tablet',
      'takenWith': 'Water',
      'nextRefill': 'Jun 18',
      'adherence': 88,
      'times': ['20:00'],
      'takenToday': false,
    },
    {
      'name': 'Vitamin B12',
      'dosage': '1000 mcg',
      'schedule': 'Morning — 08:00',
      'stock': 60,
      'maxStock': 60,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Sublingual',
      'takenWith': 'Empty stomach',
      'nextRefill': 'Sep 01',
      'adherence': 98,
      'times': ['08:00'],
      'takenToday': true,
    },
    {
      'name': 'Zinc',
      'dosage': '25 mg',
      'schedule': 'Daily — 13:00',
      'stock': 8,
      'maxStock': 30,
      'icon': Icons.wb_cloudy_rounded,
      'form': 'Capsule',
      'takenWith': 'Food',
      'nextRefill': 'Jun 14',
      'adherence': 85,
      'times': ['13:00'],
      'takenToday': false,
    },
    {
      'name': 'Probiotics',
      'dosage': '50B CFU',
      'schedule': 'Morning — 08:00',
      'stock': 15,
      'maxStock': 30,
      'icon': Icons.wb_sunny_rounded,
      'form': 'Capsule',
      'takenWith': 'Empty stomach',
      'nextRefill': 'Jun 22',
      'adherence': 90,
      'times': ['08:00'],
      'takenToday': true,
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
                      onTap: () {
                        Haptics.light();
                        // Navigate to add medication
                      },
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
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.xs, GR.lg, 0),
                child: Text(
                  '${_medications.length} medications · ${_medications.where((m) => m['takenToday'] as bool).length} taken today',
                  style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                ),
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
            SliverPadding(
              padding: EdgeInsets.fromLTRB(GR.lg, 0, GR.lg, GR.xxl),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final med = _medications[index];
                    return _buildMedicationItem(context, med, index);
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

  Widget _buildMedicationItem(BuildContext context, Map<String, dynamic> med, int index) {
    final tc = ThemeColors.of(context);
    final stock = med['stock'] as int;
    final maxStock = med['maxStock'] as int;
    final adherence = med['adherence'] as int;
    final isLow = stock < 15;
    final takenToday = med['takenToday'] as bool;
    final stockRatio = (stock / maxStock).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () => _showMedicationDetail(med),
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
                med['icon'] as IconData,
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
                          med['name'] as String,
                          style: AppTextStyles.body(context, weight: FontWeight.w600),
                        ),
                      ),
                      if (takenToday)
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: tc.accent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
                        ),
                    ],
                  ),
                  SizedBox(height: GR.xs - 1),
                  Text(
                    med['schedule'] as String,
                    style: AppTextStyles.caption(context, color: tc.textSecondary),
                  ),
                  SizedBox(height: GR.xs + 2),
                  // Stock bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: tc.surface,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: stockRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isLow ? tc.textSecondary : tc.accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: GR.sm),
                      Text(
                        '$stock left',
                        style: AppTextStyles.micro(context,
                            weight: FontWeight.w600,
                            color: isLow ? tc.textSecondary : tc.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: GR.md),

            // Adherence ring
            _AdherenceRing(adherence: adherence, size: 42),
          ],
        ),
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 100 + index * 60), duration: 400.ms, curve: Curves.easeOutCubic)
        .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1.0, 1.0),
            delay: Duration(milliseconds: 100 + index * 60),
            duration: 400.ms,
            curve: Curves.easeOutBack);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ADHERENCE RING
// ═══════════════════════════════════════════════════════════════════════════════
class _AdherenceRing extends StatelessWidget {
  final int adherence;
  final double size;

  const _AdherenceRing({required this.adherence, this.size = 42});

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final color = adherence >= 95
        ? tc.accent
        : adherence >= 85
            ? tc.textSecondary
            : tc.textMuted;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: adherence / 100,
            strokeWidth: 3.5,
            backgroundColor: tc.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          Center(
            child: Text(
              '$adherence',
              style: AppTextStyles.micro(context, weight: FontWeight.w800, color: tc.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MEDICATION DETAIL BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════════════
class _MedicationDetailSheet extends StatefulWidget {
  final Map<String, dynamic> med;

  const _MedicationDetailSheet({required this.med});

  @override
  State<_MedicationDetailSheet> createState() => _MedicationDetailSheetState();
}

class _MedicationDetailSheetState extends State<_MedicationDetailSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final med = widget.med;
    final stock = med['stock'] as int;
    final maxStock = med['maxStock'] as int;
    final isLow = stock < 15;
    final adherence = med['adherence'] as int;
    final adherenceColor = adherence >= 95
        ? tc.accent
        : adherence >= 85
            ? tc.textSecondary
            : tc.textMuted;
    final takenToday = med['takenToday'] as bool;

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

            // Header: icon + name + dosage + taken badge
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: takenToday ? tc.accent.withValues(alpha: 0.1) : tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusMd + 4),
                    ),
                    child: Icon(
                      med['icon'] as IconData,
                      size: 28,
                      color: takenToday ? tc.accent : tc.textMuted,
                    ),
                  ),
                  SizedBox(width: GR.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(med['name'] as String, style: AppTextStyles.h3(context)),
                        SizedBox(height: GR.xs - 2),
                        Text(med['dosage'] as String, style: AppTextStyles.bodySmall(context)),
                        SizedBox(height: GR.xs),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: GR.sm, vertical: GR.xs - 2),
                          decoration: BoxDecoration(
                            color: takenToday ? tc.accent.withValues(alpha: 0.1) : tc.surface,
                            borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                          ),
                          child: Text(
                            takenToday ? 'Taken today' : 'Not taken yet',
                            style: AppTextStyles.caption(
                              context,
                              weight: FontWeight.w700,
                              color: takenToday ? tc.accent : tc.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate(controller: _ctrl)
                .fadeIn(delay: 0.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 0.ms, duration: 400.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Quick stats row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  _buildStatCard(
                    context,
                    label: 'Stock',
                    value: '$stock',
                    unit: 'of $maxStock',
                    color: isLow ? tc.textSecondary : tc.accent,
                    bgColor: isLow ? tc.surface : tc.accent.withValues(alpha: 0.08),
                    progress: stock / maxStock,
                  ),
                  SizedBox(width: GR.sm),
                  _buildStatCard(
                    context,
                    label: 'Adherence',
                    value: '$adherence%',
                    unit: 'this month',
                    color: adherenceColor,
                    bgColor: tc.surface,
                    progress: adherence / 100,
                  ),
                ],
              ),
            )
                .animate(controller: _ctrl)
                .fadeIn(delay: 100.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 400.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Details list
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: GoldenCard(
                padding: EdgeInsets.all(GR.md),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Schedule', med['schedule'] as String),
                    Divider(height: 1, color: tc.border),
                    _buildDetailRow(context, 'Form', med['form'] as String),
                    Divider(height: 1, color: tc.border),
                    _buildDetailRow(context, 'Take with', med['takenWith'] as String),
                    Divider(height: 1, color: tc.border),
                    _buildDetailRow(context, 'Next refill', med['nextRefill'] as String),
                  ],
                ),
              ),
            )
                .animate(controller: _ctrl)
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Time chips
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminder times', style: AppTextStyles.body(context, weight: FontWeight.w500)),
                  SizedBox(height: GR.sm),
                  Wrap(
                    spacing: GR.sm,
                    children: (med['times'] as List<String>).map((time) {
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
            )
                .animate(controller: _ctrl)
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Action buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Haptics.medium();
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 16, color: tc.textPrimary),
                              SizedBox(width: GR.xs + 2),
                              Text('Edit', style: AppTextStyles.bodySmall(context, weight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: GR.sm),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Haptics.success();
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: takenToday ? tc.surface : tc.accent,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                takenToday ? Icons.check_rounded : Icons.check_circle_rounded,
                                size: 16,
                                color: takenToday ? tc.textMuted : Colors.white,
                              ),
                              SizedBox(width: GR.xs + 2),
                              Text(
                                takenToday ? 'Taken' : 'Mark Taken',
                                style: AppTextStyles.bodySmall(
                                  context,
                                  weight: FontWeight.w600,
                                  color: takenToday ? tc.textMuted : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate(controller: _ctrl)
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 400.ms, curve: Curves.easeOutCubic),

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
