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
const _orange = Color(0xFFFFA726);

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _chartCtrl;
  bool _isCharts = true;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _chartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _chartCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _chartCtrl.dispose();
    super.dispose();
  }

  void _toggleView(bool charts) {
    if (charts == _isCharts) return;
    Haptics.selection();
    setState(() => _isCharts = charts);
    _chartCtrl.reset();
    _chartCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Header with Toggle ───────────────────────────────
                Row(
                  children: [
                    const Spacer(),
                    // Toggle
                    Container(
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleView(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isCharts ? _textPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Charts',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _isCharts ? Colors.white : _textSecondary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleView(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isCharts ? _textPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'List',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: !_isCharts ? Colors.white : _textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: const Text(
                        'Export',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                if (_isCharts) ...[
                  // ── Charts View ────────────────────────────────────
                  Text(
                    'See your daily steps and much more',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 20),

                  // Health Connect Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _accentLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 28,
                            color: _accentDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connect with Health',
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sync your daily steps, heart rate, and sleep data automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 13,
                            color: _textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => Haptics.medium(),
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _accentDark,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Connect',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 200.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 24),

                  // Weekly adherence chart
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              'Vitamin D3',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _textPrimary,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'This Week',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 12,
                                color: _textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _DayCircle(day: 'Fri', taken: false, delay: 0),
                            _DayCircle(day: 'Sat', taken: false, delay: 1),
                            _DayCircle(day: 'Sun', taken: false, delay: 2),
                            _DayCircle(day: 'Mon', taken: false, delay: 3),
                            _DayCircle(day: 'Tue', taken: false, delay: 4),
                            _DayCircle(day: 'Wed', taken: false, delay: 5),
                            _DayCircle(day: 'Thu', taken: true, isToday: true, delay: 6),
                          ],
                        ),
                      ],
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: 24),

                  // Personalize button
                  GestureDetector(
                    onTap: () => Haptics.medium(),
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
                          'Personalize',
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _accentDark,
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                ] else ...[
                  // ── List View ────────────────────────────────────
                  _buildListView(),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    final entries = [
      {'date': 'Wed, 06/24/2026', 'med': 'Vitamin D3 2000 IU', 'taken': true},
      {'date': 'Tue, 06/23/2026', 'med': 'Vitamin D3 2000 IU', 'taken': true},
      {'date': 'Mon, 06/22/2026', 'med': 'Vitamin D3 2000 IU', 'taken': true},
      {'date': 'Sun, 06/21/2026', 'med': 'Vitamin D3 2000 IU', 'taken': false},
      {'date': 'Sat, 06/20/2026', 'med': 'Vitamin D3 2000 IU', 'taken': true},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 16),
              child: Text(
                e['date'] as String,
                style: const TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textMuted,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.medication_rounded,
                    size: 18,
                    color: _textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e['med'] as String,
                      style: const TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    (e['taken'] as bool) ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                    size: 20,
                    color: (e['taken'] as bool) ? _accent : _textMuted,
                  ),
                ],
              ),
            ),
          ],
        )
            .animate(controller: _chartCtrl)
            .fadeIn(delay: Duration(milliseconds: i * 80), duration: 400.ms)
            .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: i * 80), duration: 400.ms, curve: Curves.easeOutCubic);
      }).toList(),
    );
  }
}

// ─── Day Circle ──────────────────────────────────────────────────────────────
class _DayCircle extends StatelessWidget {
  final String day;
  final bool taken;
  final bool isToday;
  final int delay;

  const _DayCircle({
    required this.day,
    required this.taken,
    this.isToday = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? _accentDark : _textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: taken ? _accentLight.withValues(alpha: 0.4) : const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(18),
            border: isToday
                ? Border.all(color: _accentDark, width: 2)
                : taken
                    ? Border.all(color: _accentLight)
                    : null,
          ),
          child: taken
              ? const Icon(Icons.check_rounded, size: 16, color: _accentDark)
              : const Icon(Icons.question_mark_rounded, size: 14, color: _textMuted),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + delay * 60), duration: 300.ms)
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), delay: Duration(milliseconds: 400 + delay * 60), duration: 300.ms, curve: Curves.easeOutBack);
  }
}
