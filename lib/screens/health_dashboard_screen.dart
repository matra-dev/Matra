import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/golden_ratio.dart';

// ─── Local aliases for backward compatibility ─────────────────────────────────
const _bg = AppColors.bg;
const _cardBg = AppColors.cardBg;
const _cardBorder = AppColors.border;
const _textPrimary = AppColors.textPrimary;
const _textSecondary = AppColors.textSecondary;
const _textMuted = AppColors.textMuted;
const _accent = AppColors.accent;
const _accentLight = AppColors.accentLight;
const _accentDark = AppColors.accentDark;
const _orange = AppColors.orange;
const _blue = AppColors.blue;
const _purple = AppColors.purple;
const _red = AppColors.red;

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});

  @override
  State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _morphCtrl;
  late final AnimationController _countCtrl;

  @override
  void initState() {
    super.initState();
    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _start();
  }

  void _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _morphCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _countCtrl.forward();
  }

  @override
  void dispose() {
    _morphCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    Haptics.medium();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableW = constraints.maxWidth;

            return AnimatedBuilder(
              animation: _morphCtrl,
              builder: (context, _) {
                final morph = Curves.easeInOutCubicEmphasized
                    .transform(_morphCtrl.value.clamp(0.0, 1.0));
                final siblings = ((morph - 0.4) / 0.6).clamp(0.0, 1.0);

                // Hero morph: full width → 56% width, same row height
                final heroStartW = availableW - 40;
                final heroEndW = (availableW - 40) * 0.56;
                final heroW =
                    heroStartW + (heroEndW - heroStartW) * morph;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      // ── Header ───────────────────────────────────────
                      Opacity(
                        opacity: siblings,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Haptics.light();
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _cardBg,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _cardBorder),
                                ),
                                child: const Icon(Icons.arrow_back_rounded, size: 18, color: _textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Health',
                                  style: TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: _textPrimary,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                  ),
                                ),
                                Text(
                                  'Overview',
                                  style: TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: _textMuted,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 17,
                                color: _accent,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Row 1: Hero (left) + Date/Streak (right) ─────
                      Expanded(
                        flex: 5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Hero Card
                            Container(
                              width: heroW,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _cardBg,
                                borderRadius: BorderRadius.circular(
                                    20 - 2 * morph),
                                border: Border.all(color: _cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black
                                        .withValues(alpha: 0.04 * morph),
                                    blurRadius: 14 * morph,
                                    offset: Offset(0, 3 * morph),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Opacity(
                                    opacity: morph,
                                    child: const Text(
                                      '2025',
                                      style: TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _textMuted,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2 + 6 * (1 - morph)),
                                  AnimatedBuilder(
                                    animation: _countCtrl,
                                    builder: (_, __) {
                                      final v = Curves.easeOutCubic
                                          .transform(_countCtrl.value);
                                      return Text(
                                        '+${(94 * v).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 28 + 18 * (1 - morph),
                                          fontWeight: FontWeight.w900,
                                          color: _accentDark,
                                          height: 1.0,
                                          letterSpacing: -1.2,
                                        ),
                                      );
                                    },
                                  ),
                                  Opacity(
                                    opacity: morph,
                                    child: const Padding(
                                      padding: EdgeInsets.only(top: 2),
                                      child: Text(
                                        'Adherence rate this year.\nStay consistent.',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: _textSecondary,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  SizedBox(
                                    height: 28,
                                    child: CustomPaint(
                                      size: const Size(double.infinity, 28),
                                      painter: _SparklinePainter(
                                        ctrl: _countCtrl,
                                        color: _accentDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Right column: Date + Streak
                            if (morph > 0.3)
                              Expanded(
                                child: Opacity(
                                  opacity: siblings,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      children: [
                                        _SmallCard(
                                          delay: 0,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '16',
                                                style: TextStyle(
                                                  fontFamily: 'Artific',
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w900,
                                                  color: _textPrimary,
                                                  height: 1.0,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Tue.',
                                                    style: TextStyle(
                                                      fontFamily: 'Artific',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    'December',
                                                    style: TextStyle(
                                                      fontFamily: 'Artific',
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: _textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _SmallCard(
                                          delay: 1,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    width: 6,
                                                    height: 6,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color: _orange,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  const Text(
                                                    '16 Days',
                                                    style: TextStyle(
                                                      fontFamily: 'Artific',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: _textPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                '110 hrs, 32 min',
                                                style: TextStyle(
                                                  fontFamily: 'Artific',
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400,
                                                  color: _textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: List.generate(8, (i) {
                                                  return Container(
                                                    width: 5,
                                                    height: 5,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 3),
                                                    decoration: BoxDecoration(
                                                      color: i < 6
                                                          ? _accent
                                                          : const Color(
                                                              0xFFE5E7EB),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Row 2: Adherence + Supplements ───────────────
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            _SmallCard(
                              delay: 2,
                              child: Row(
                                children: [
                                  _IconBadge(
                                    icon: Icons.check_circle_rounded,
                                    bg: _accent.withValues(alpha: 0.1),
                                    fg: _accent,
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Adherence',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: _textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '94%',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: _textPrimary,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _SmallCard(
                              delay: 3,
                              child: Row(
                                children: [
                                  _IconBadge(
                                    icon: Icons.medication_rounded,
                                    bg: _blue.withValues(alpha: 0.1),
                                    fg: _blue,
                                  ),
                                  const SizedBox(width: 10),
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Supplements',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: _textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        '7 active',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: _textPrimary,
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Row 3: Weekly bars + Consistency ─────────────
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SmallCard(
                              delay: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'This Week',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        '6/7 days',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: _textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      _WeekBar(h: 0.55, l: 'M', t: false),
                                      _WeekBar(h: 0.8, l: 'T', t: false),
                                      _WeekBar(h: 0.65, l: 'W', t: false),
                                      _WeekBar(h: 1.0, l: 'T', t: true),
                                      _WeekBar(h: 0.85, l: 'F', t: false),
                                      _WeekBar(h: 0.7, l: 'S', t: false),
                                      _WeekBar(h: 0.45, l: 'S', t: false),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _SmallCard(
                              delay: 5,
                              bg: _accentLight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Consistency',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      0.4,
                                      0.6,
                                      0.5,
                                      0.8,
                                      0.7,
                                      0.9,
                                      0.85
                                    ].map((h) {
                                      return Expanded(
                                        child: Container(
                                          height: 20 * h,
                                          margin:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 2),
                                          decoration: BoxDecoration(
                                            color: _textPrimary
                                                .withValues(alpha: 0.08),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    '1,541',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: _textPrimary,
                                      height: 1.0,
                                    ),
                                  ),
                                  const Text(
                                    'total doses',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: _textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Row 4: Schedule + Stock ──────────────────────
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SmallCard(
                              delay: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Schedule',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _ScheduleRow(
                                    icon: Icons.wb_sunny_rounded,
                                    label: 'Morning',
                                    count: 3,
                                    color: _orange,
                                  ),
                                  const SizedBox(height: 4),
                                  _ScheduleRow(
                                    icon: Icons.wb_cloudy_rounded,
                                    label: 'Afternoon',
                                    count: 2,
                                    color: _blue,
                                  ),
                                  const SizedBox(height: 4),
                                  _ScheduleRow(
                                    icon: Icons.nights_stay_rounded,
                                    label: 'Evening',
                                    count: 2,
                                    color: _purple,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _SmallCard(
                              delay: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Text(
                                        'Stock',
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: _textPrimary,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 13,
                                        color: _orange,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _StockRow(
                                    name: 'Vitamin D',
                                    count: 5,
                                    color: _orange,
                                  ),
                                  const SizedBox(height: 4),
                                  _StockRow(
                                    name: 'Omega-3',
                                    count: 12,
                                    color: _accent,
                                  ),
                                  const SizedBox(height: 4),
                                  _StockRow(
                                    name: 'Magnesium',
                                    count: 3,
                                    color: _red,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── CTA ──────────────────────────────────────────
                      GestureDetector(
                        onTap: _onContinue,
                        child: Container(
                          width: double.infinity,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _textPrimary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Done',
                                  style: TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(
                            delay: 1600.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          )
                          .slideY(
                            begin: 0.3,
                            end: 0,
                            delay: 1600.ms,
                            duration: 600.ms,
                            curve: Curves.easeOutCubic,
                          ),

                      const SizedBox(height: 6),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Small Card ──────────────────────────────────────────────────────────────
class _SmallCard extends StatelessWidget {
  final int delay;
  final Widget child;
  final Color? bg;

  const _SmallCard({required this.delay, required this.child, this.bg});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg ?? _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: (bg == null || bg == _cardBg)
              ? Border.all(color: _cardBorder)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      )
          .animate()
          .fadeIn(
            delay: Duration(milliseconds: 1300 + delay * 80),
            duration: 500.ms,
            curve: Curves.easeOutCubic,
          )
          .scale(
            begin: const Offset(0.88, 0.88),
            end: const Offset(1.0, 1.0),
            delay: Duration(milliseconds: 1300 + delay * 80),
            duration: 500.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}

// ─── Icon Badge ──────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _IconBadge({required this.icon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}

// ─── Sparkline Painter ───────────────────────────────────────────────────────
class _SparklinePainter extends CustomPainter {
  final AnimationController ctrl;
  final Color color;
  const _SparklinePainter({required this.ctrl, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Curves.easeOutCubic.transform(ctrl.value);
    if (p <= 0) return;

    final data = [0.3, 0.5, 0.4, 0.6, 0.55, 0.75, 0.7, 0.9, 0.85, 0.94];
    final pts = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - (data[i] * size.height * 0.7 + size.height * 0.15);
      pts.add(Offset(x, y));
    }

    final barW = size.width / data.length;
    for (int i = 0; i < data.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * barW + 2, 0, barW - 4, size.height),
        Paint()
          ..color = color.withValues(alpha: 0.04)
          ..style = PaintingStyle.fill,
      );
    }

    final path = Path();
    final vis = (pts.length * p).ceil().clamp(1, pts.length);
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < vis; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final mx = (prev.dx + curr.dx) / 2;
      path.cubicTo(mx, prev.dy, mx, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (vis > 0 && p > 0.85) {
      final last = pts[vis - 1];
      canvas.drawCircle(
          last, 4, Paint()..color = color.withValues(alpha: 0.15));
      canvas.drawCircle(last, 2, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.ctrl.value != ctrl.value;
}

// ─── Week Bar ────────────────────────────────────────────────────────────────
class _WeekBar extends StatelessWidget {
  final double h;
  final String l;
  final bool t;
  const _WeekBar({required this.h, required this.l, required this.t});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 32 * h,
          decoration: BoxDecoration(
            color: t ? _accent : _accent.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          l,
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 9,
            fontWeight: t ? FontWeight.w700 : FontWeight.w500,
            color: t ? _accent : _textMuted,
          ),
        ),
      ],
    );
  }
}

// ─── Schedule Row ────────────────────────────────────────────────────────────
class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 11, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Artific',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Stock Row ───────────────────────────────────────────────────────────────
class _StockRow extends StatelessWidget {
  final String name;
  final int count;
  final Color color;
  const _StockRow({
    required this.name,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(
              fontFamily: 'Artific',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: (count / 15).clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$count',
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}
