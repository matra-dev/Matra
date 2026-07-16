import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

import '../theme/app_text_styles.dart';
class MeasurementListScreen extends StatefulWidget {
  const MeasurementListScreen({super.key});

  @override
  State<MeasurementListScreen> createState() => _MeasurementListScreenState();
}

class _MeasurementListScreenState extends State<MeasurementListScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _measurements = [
    {'name': 'Blood Pressure', 'unit': 'mmHg', 'icon': Icons.favorite_rounded, 'color': AppColors.textPrimary},
    {'name': 'Resting Heart Rate', 'unit': 'bpm', 'icon': Icons.monitor_heart_rounded, 'color': AppColors.textPrimary},
    {'name': 'Weight', 'unit': 'kg', 'icon': Icons.scale_rounded, 'color': AppColors.textPrimary},
    {'name': 'Blood Sugar (before meal)', 'unit': 'mg/dL', 'icon': Icons.water_drop_rounded, 'color': AppColors.textPrimary},
    {'name': 'Blood Sugar (after meal)', 'unit': 'mg/dL', 'icon': Icons.water_drop_rounded, 'color': AppColors.textPrimary},
    {'name': 'Temperature', 'unit': '°C', 'icon': Icons.thermostat_rounded, 'color': AppColors.textPrimary},
    {'name': 'Oxygen Saturation', 'unit': '%', 'icon': Icons.air_rounded, 'color': AppColors.textPrimary},
    {'name': 'Sleep Duration', 'unit': 'hours', 'icon': Icons.bedtime_rounded, 'color': AppColors.textPrimary},
    {'name': 'Steps', 'unit': 'count', 'icon': Icons.directions_walk_rounded, 'color': AppColors.textPrimary},
    {'name': 'Vitamin D Level', 'unit': 'ng/mL', 'icon': Icons.wb_sunny_rounded, 'color': AppColors.textPrimary},
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.stop();
    _entranceCtrl.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return _measurements;
    return _measurements
        .where((m) => m['name'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: GR.sm),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
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
                  Text(
                    'Select from List',
                    style: AppTextStyles.body(context, weight: FontWeight.w800),
                  ),
                  const Spacer(),
                  SizedBox(width: GR.lg + 2),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 500.ms)
                .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Container(
                height: GR.buttonSm + 4,
                decoration: BoxDecoration(
                  color: tc.surface,
                  borderRadius: BorderRadius.circular(GR.radiusMd),
                ),
                child: Row(
                  children: [
                    SizedBox(width: GR.md),
                    Icon(Icons.search_rounded, size: GR.iconSm, color: tc.textMuted),
                    SizedBox(width: GR.md),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.body(context),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle: AppTextStyles.body(context, color: tc.textMuted),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    SizedBox(width: GR.sm),
                  ],
                ),
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Section Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: GR.lg),
              child: Row(
                children: [
                  Text(
                    'Popular measurements',
                    style: AppTextStyles.caption(context, weight: FontWeight.w600, color: tc.textMuted),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 200.ms, duration: 400.ms),

            SizedBox(height: GR.md),

            // List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  return GestureDetector(
                    onTap: () {
                      Haptics.light();
                      Navigator.pushNamed(context, '/metric_detail');
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 1),
                      padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 3),
                      decoration: BoxDecoration(
                        color: tc.cardBg,
                        border: Border(
                          bottom: BorderSide(color: tc.border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name']!,
                              style: AppTextStyles.body(context, weight: FontWeight.w500),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, size: GR.iconSm, color: tc.textMuted),
                        ],
                      ),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: Duration(milliseconds: 250 + index * 40), duration: 400.ms)
                      .slideX(begin: 0.1, end: 0, delay: Duration(milliseconds: 250 + index * 40), duration: 400.ms, curve: Curves.easeOutCubic);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
