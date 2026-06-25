import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

// ─── Light Mode Palette ──────────────────────────────────────────────────────
const _bg = Color(0xFFFAFAFA);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFE8E8E8);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF6B7280);
const _textMuted = Color(0xFF9CA3AF);
const _accent = Color(0xFF00BFA5);
const _accentLight = Color(0xFFB8E0D2);
const _accentDark = Color(0xFF00897B);

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
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Header ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Haptics.light();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _cardBorder),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'Add Medication',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 500.ms)
                .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 20),

            // ── Search Bar ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, size: 20, color: _textMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        focusNode: _searchFocus,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          color: _textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search for medication',
                          hintStyle: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 16,
                            color: _textMuted,
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
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.close_rounded, size: 18, color: _textMuted),
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            )
                .animate(controller: _searchCtrl)
                .fadeIn(delay: 0.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 24),

            // ── Empty State or Results ───────────────────────────
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyState()
                  : _buildResults(),
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
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _accentLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 36,
              color: _accentDark,
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 300.ms, duration: 600.ms)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), delay: 300.ms, duration: 600.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          const Text(
            'Type the name of the medication,\nvitamin, or supplement you want to add',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
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
            const Icon(Icons.search_off_rounded, size: 48, color: _textMuted),
            const SizedBox(height: 16),
            Text(
              'No results for "$_query"',
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                backgroundColor: _accentDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accentLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    size: 20,
                    color: _accentDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med['name']!,
                        style: const TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med['dosage']} · ${med['type']}',
                        style: const TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 12,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.add_circle_rounded,
                  color: _accent,
                  size: 24,
                ),
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
