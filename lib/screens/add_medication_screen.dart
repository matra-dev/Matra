import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

import '../theme/app_text_styles.dart';
class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _searchCtrl;
  final _searchFocus = FocusNode();
  String _query = '';

  final List<Map<String, dynamic>> _medications = [
    {'name': 'Vitamin D3', 'dosage': '2000 IU', 'type': 'Supplement'},
    {'name': 'Omega-3 Fish Oil', 'dosage': '1000 mg', 'type': 'Supplement'},
    {'name': 'Magnesium Glycinate', 'dosage': '400 mg', 'type': 'Supplement'},
    {'name': 'Vitamin B12', 'dosage': '1000 mcg', 'type': 'Supplement'},
    {'name': 'Zinc', 'dosage': '25 mg', 'type': 'Supplement'},
    {'name': 'Probiotics', 'dosage': '50 Billion CFU', 'type': 'Supplement'},
    {'name': 'Iron', 'dosage': '18 mg', 'type': 'Supplement'},
    {'name': 'Calcium', 'dosage': '600 mg', 'type': 'Supplement'},
    {'name': 'Multivitamin', 'dosage': '1 tablet', 'type': 'Supplement'},
    {'name': 'Melatonin', 'dosage': '3 mg', 'type': 'Supplement'},
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _searchCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _searchCtrl.forward();
    _searchFocus.requestFocus();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return [];
    return _medications
        .where((m) => m['name'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: AppColors.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Add Medication',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
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
                height: GR.buttonMd,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(GR.radiusMd),
                ),
                child: Row(
                  children: [
                    SizedBox(width: GR.md),
                    Icon(Icons.search_rounded, size: GR.iconSm, color: AppColors.textMuted),
                    SizedBox(width: GR.md),
                    Expanded(
                      child: TextField(
                        focusNode: _searchFocus,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search for medication',
                          hintStyle: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 16,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          Haptics.light();
                          setState(() => _query = '');
                        },
                        child: Padding(
                          padding: EdgeInsets.all(GR.md),
                          child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                        ),
                      ),
                    SizedBox(width: GR.sm),
                  ],
                ),
              ),
            )
                .animate(controller: _searchCtrl)
                .fadeIn(delay: 0.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Empty State or Results
            Expanded(
              child: _query.isEmpty ? _buildEmptyState() : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: GR.lg * 4,
            height: GR.lg * 4,
            decoration: BoxDecoration(
              color: AppColors.accentLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(GR.radiusLg),
            ),
            child: Icon(Icons.medication_rounded, size: GR.iconLg + 8, color: AppColors.accentDark),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), delay: 300.ms, duration: 600.ms, curve: Curves.easeOutBack),
          SizedBox(height: GR.lg),
          Text(
            'Type the name of the medication,\nvitamin, or supplement you want to add',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 400.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final results = _filtered;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: GR.iconLg + 8, color: AppColors.textMuted),
            SizedBox(height: GR.md),
            Text(
              'No results for "$_query"',
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: GR.lg),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final med = results[index];
        return GestureDetector(
          onTap: () {
            Haptics.success();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${med['name']} to your stack',
                  style: const TextStyle(fontFamily: 'Artific'),
                ),
                backgroundColor: AppColors.accentDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GR.radiusMd)),
              ),
            );
          },
          child: GoldenCard(
            padding: EdgeInsets.all(GR.md + 3),
            child: Row(
              children: [
                Container(
                  width: GR.lg + 2,
                  height: GR.lg + 2,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: Icon(Icons.medication_rounded, size: GR.iconSm + 2, color: AppColors.accentDark),
                ),
                SizedBox(width: GR.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name']!,
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: GR.xs),
                      Text(
                        '${med['dosage']} · ${med['type']}',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.add_circle_rounded, color: AppColors.accent, size: GR.iconMd),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: index * 60), duration: 400.ms)
            .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: index * 60), duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }
}
