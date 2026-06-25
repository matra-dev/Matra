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
    {'name': 'Blood Pressure', 'unit': 'mmHg', 'icon': Icons.favorite_rounded, 'color': _accentDark},
    {'name': 'Resting Heart Rate', 'unit': 'bpm', 'icon': Icons.monitor_heart_rounded, 'color': const Color(0xFFE53935)},
    {'name': 'Weight', 'unit': 'kg', 'icon': Icons.scale_rounded, 'color': const Color(0xFF448AFF)},
    {'name': 'Blood Sugar (before meal)', 'unit': 'mg/dL', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFFFF9800)},
    {'name': 'Blood Sugar (after meal)', 'unit': 'mg/dL', 'icon': Icons.water_drop_rounded, 'color': const Color(0xFFFF9800)},
    {'name': 'Temperature', 'unit': '°C', 'icon': Icons.thermostat_rounded, 'color': const Color(0xFF9C27B0)},
    {'name': 'Oxygen Saturation', 'unit': '%', 'icon': Icons.air_rounded, 'color': const Color(0xFF00BCD4)},
    {'name': 'Sleep Duration', 'unit': 'hours', 'icon': Icons.bedtime_rounded, 'color': const Color(0xFF3F51B5)},
    {'name': 'Steps', 'unit': 'count', 'icon': Icons.directions_walk_rounded, 'color': const Color(0xFF4CAF50)},
    {'name': 'Vitamin D Level', 'unit': 'ng/mL', 'icon': Icons.wb_sunny_rounded, 'color': const Color(0xFFFFB74D)},
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
                    'Select from List',
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
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    const Icon(Icons.search_rounded, size: 18, color: _textMuted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        style: const TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 15,
                          color: _textPrimary,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          hintStyle: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 15,
                            color: _textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.15, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: 24),

            // ── Section Title ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Popular measurements',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 200.ms, duration: 400.ms),

            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  return GestureDetector(
                    onTap: () {
                      Haptics.light();
                      Navigator.pushNamed(context, '/metric_detail');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: _cardBg,
                        border: Border(
                          bottom: BorderSide(color: _cardBorder),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item['name']!,
                              style: const TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: _textMuted,
                          ),
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
