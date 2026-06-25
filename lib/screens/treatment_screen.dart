import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import 'add_medication_screen.dart';
import 'appointment_screen.dart';

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
const _orange = Color(0xFFFFA726);

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
      'color': _accentDark,
    },
    {
      'name': 'Omega-3 Fish Oil',
      'schedule': 'Daily—08:00',
      'stock': 45,
      'color': const Color(0xFF448AFF),
    },
    {
      'name': 'Magnesium 400mg',
      'schedule': 'Evening—20:00',
      'stock': 12,
      'color': const Color(0xFF9C27B0),
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
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Header ───────────────────────────────────────────
                    Row(
                      children: [
                        const Text(
                          'Treatment',
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: _textPrimary,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Haptics.light(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              size: 18,
                              color: _textPrimary,
                            ),
                          ),
                        ),
                      ],
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 0.ms, duration: 500.ms)
                        .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 20),

                    // ── Add Button ───────────────────────────────────────
                    GestureDetector(
                      onTap: _showAddOptions,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _accentLight.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _accentLight),
                        ),
                        child: const Center(
                          child: Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _accentDark,
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 100.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 20),

                    // ── Medication Cards ─────────────────────────────────
                    ..._medications.asMap().entries.map((entry) {
                      final i = entry.key;
                      final med = entry.value;
                      final isLow = (med['stock'] as int) < 15;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _cardBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: (med['color'] as Color).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded,
                                    size: 18,
                                    color: med['color'] as Color,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    med['name'] as String,
                                    style: const TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 48),
                              child: Text(
                                med['schedule'] as String,
                                style: const TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 13,
                                  color: _textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: isLow ? const Color(0xFFFFF3E0) : const Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${med['stock']} pill(s) left',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isLow ? _orange : _textSecondary,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isLow ? const Color(0xFFFFF3E0) : _accentLight.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isLow ? Icons.warning_amber_rounded : Icons.alarm_rounded,
                                    size: 18,
                                    color: isLow ? _orange : _accentDark,
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

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Add Options Overlay ──────────────────────────────
            if (_showAddMenu)
              GestureDetector(
                onTap: _hideAddOptions,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.4),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {}, // prevent tap through
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
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
                            const Divider(height: 1),
                            _AddOption(
                              label: 'Measurement',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            const Divider(height: 1),
                            _AddOption(
                              label: 'Activity',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            const Divider(height: 1),
                            _AddOption(
                              label: 'Symptom check',
                              onTap: () {
                                _hideAddOptions();
                                Haptics.light();
                              },
                            ),
                            const Divider(height: 1),
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
                            const Divider(height: 1),
                            GestureDetector(
                              onTap: _hideAddOptions,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: const Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: _accentDark,
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

// ─── Add Option ──────────────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Artific',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _accentDark,
            ),
          ),
        ),
      ),
    );
  }
}
