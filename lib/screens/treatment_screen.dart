import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import 'add_medication_screen.dart';
import 'appointment_screen.dart';

class TreatmentScreen extends StatefulWidget {
  const TreatmentScreen({super.key});

  @override
  State<TreatmentScreen> createState() => _TreatmentScreenState();
}

class _TreatmentScreenState extends State<TreatmentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  bool _showAddMenu = false;

  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'Vitamin D3 2000 IU',
      'schedule': 'Daily—08:00',
      'stock': 29,
      'color': AppColors.accentDark,
    },
    {
      'name': 'Omega-3 Fish Oil',
      'schedule': 'Daily—08:00',
      'stock': 45,
      'color': AppColors.blue,
    },
    {
      'name': 'Magnesium 400mg',
      'schedule': 'Evening—20:00',
      'stock': 12,
      'color': AppColors.purple,
    },
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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

  void _showAddOptions() {
    Haptics.medium();
    setState(() => _showAddMenu = true);
  }

  void _hideAddOptions() {
    setState(() => _showAddMenu = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: GR.sm),

                    // Header
                    Row(
                      children: [
                        Text(
                          'Treatment',
                          style: AppTextStyles.h1(context),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Haptics.light(),
                          child: Container(
                            width: GR.lg + 2,
                            height: GR.lg + 2,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(GR.radiusMd),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Icon(Icons.settings_outlined, size: GR.iconSm, color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 0.ms, duration: 500.ms)
                        .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.lg),

                    // Add Button
                    GestureDetector(
                      onTap: _showAddOptions,
                      child: Container(
                        width: double.infinity,
                        height: GR.buttonMd,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: AppColors.accentLight),
                        ),
                        child: Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentDark,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.lg),

                    // Medication Cards
                    ..._medications.asMap().entries.map((entry) {
                      final i = entry.key;
                      final med = entry.value;
                      final isLow = (med['stock'] as int) < 15;

                      return GoldenCard(
                        padding: EdgeInsets.all(GR.md + 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: GR.lg + 2,
                                  height: GR.lg + 2,
                                  decoration: BoxDecoration(
                                    color: (med['color'] as Color).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(GR.radiusMd),
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded,
                                    size: GR.iconSm,
                                    color: med['color'] as Color,
                                  ),
                                ),
                                SizedBox(width: GR.md),
                                Expanded(
                                  child: Text(
                                    med['name'] as String,
                                    style: AppTextStyles.h3(context, weight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: GR.sm),
                            Padding(
                              padding: EdgeInsets.only(left: GR.lg + 2 + GR.md),
                              child: Text(
                                med['schedule'] as String,
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ),
                            SizedBox(height: GR.md),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.xs + 2),
                                  decoration: BoxDecoration(
                                    color: isLow ? AppColors.orangeLight : AppColors.surface,
                                    borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                  ),
                                  child: Text(
                                    '${med['stock']} pill(s) left',
                                    style: AppTextStyles.caption(context, weight: FontWeight.w600, color: isLow ? AppColors.orange : AppColors.textSecondary),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: GR.lg + 2,
                                  height: GR.lg + 2,
                                  decoration: BoxDecoration(
                                    color: isLow ? AppColors.orangeLight : AppColors.accentLight.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(GR.radiusMd),
                                  ),
                                  child: Icon(
                                    isLow ? Icons.warning_amber_rounded : Icons.alarm_rounded,
                                    size: GR.iconSm,
                                    color: isLow ? AppColors.orange : AppColors.accentDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(delay: Duration(milliseconds: 200 + i * 100), duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 200 + i * 100), duration: 500.ms, curve: Curves.easeOutCubic);
                    }),

                    SizedBox(height: GR.lg),
                  ],
                ),
              ),
            ),

            // Add Options Overlay
            if (_showAddMenu)
              GestureDetector(
                onTap: _hideAddOptions,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: GR.lg + 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(GR.radiusLg),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _AddOption(
                              label: 'Medication',
                              onTap: () {
                                _hideAddOptions();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
                                );
                              },
                            ),
                            Divider(height: 1),
                            _AddOption(
                              label: 'Measurement',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            Divider(height: 1),
                            _AddOption(
                              label: 'Activity',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            Divider(height: 1),
                            _AddOption(
                              label: 'Symptom check',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            Divider(height: 1),
                            _AddOption(
                              label: 'Doctor appointment',
                              onTap: () {
                                _hideAddOptions();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AppointmentScreen()),
                                );
                              },
                            ),
                            Divider(height: 1),
                            GestureDetector(
                              onTap: _hideAddOptions,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: GR.md + 3),
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accentDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

class _AddOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _AddOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: GR.md + 3),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.accentDark,
            ),
          ),
        ),
      ),
    );
  }
}
