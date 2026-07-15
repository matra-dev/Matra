import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

import '../theme/app_text_styles.dart';

class HealthDashboardScreen extends StatefulWidget {
  const HealthDashboardScreen({super.key});
  @override State<HealthDashboardScreen> createState() => _HealthDashboardScreenState();
}

class _HealthDashboardScreenState extends State<HealthDashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _morphCtrl;
  late final AnimationController _countCtrl;

  @override void initState() {
    super.initState();
    _morphCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _countCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _start();
  }

  void _start() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _morphCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) _countCtrl.forward();
  }

  @override void dispose() {
    _morphCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _onContinue() {
    Haptics.medium();
    Navigator.of(context).pop();
  }

  void _showDetail(String title, Widget content) {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _DetailSheet(title: title, content: content),
    );
  }

  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableW = constraints.maxWidth;
            return AnimatedBuilder(
              animation: _morphCtrl,
              builder: (context, _) {
                final morph = Curves.easeInOutCubicEmphasized.transform(_morphCtrl.value.clamp(0.0, 1.0));
                final siblings = ((morph - 0.4) / 0.6).clamp(0.0, 1.0);
                final heroStartW = availableW - 40;
                final heroEndW = (availableW - 40) * 0.56;
                final heroW = heroStartW + (heroEndW - heroStartW) * morph;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Opacity(
                        opacity: siblings,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () { Haptics.light(); Navigator.of(context).pop(); },
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: tc.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: tc.border)),
                                child: Icon(Icons.arrow_back_rounded, size: 18, color: tc.textPrimary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Your Health', style: TextStyle(fontFamily: 'Artific', fontSize: 24, fontWeight: FontWeight.w800, color: tc.textPrimary, letterSpacing: -0.8, height: 1.1)),
                                Text('Overview', style: TextStyle(fontFamily: 'Artific', fontSize: 24, fontWeight: FontWeight.w800, color: tc.textMuted, letterSpacing: -0.8, height: 1.1)),
                              ],
                            ),
                            const Spacer(),
                            Container(
                              width: 38, height: 38,
                              decoration: BoxDecoration(color: tc.cardBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: tc.border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))]),
                              child: Icon(Icons.favorite_rounded, size: 17, color: tc.accent),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 5,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GestureDetector(
                              onTap: () => _showDetail('Adherence', _AdherenceDetail()),
                              child: Container(
                                width: heroW,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: tc.cardBg,
                                  borderRadius: BorderRadius.circular(20 - 2 * morph),
                                  border: Border.all(color: tc.border),
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04 * morph), blurRadius: 14 * morph, offset: Offset(0, 3 * morph))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Opacity(
                                      opacity: morph,
                                      child: Text('2025', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w600, color: tc.textMuted)),
                                    ),
                                    SizedBox(height: 2 + 6 * (1 - morph)),
                                    AnimatedBuilder(
                                      animation: _countCtrl,
                                      builder: (_, __) {
                                        final v = Curves.easeOutCubic.transform(_countCtrl.value);
                                        return Text('+${(94 * v).toStringAsFixed(0)}%', style: TextStyle(fontFamily: 'Artific', fontSize: 28 + 18 * (1 - morph), fontWeight: FontWeight.w900, color: tc.accentDark, height: 1.0, letterSpacing: -1.2));
                                      },
                                    ),
                                    Opacity(
                                      opacity: morph,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text('Adherence rate this year.\nStay consistent.', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w400, color: tc.textSecondary, height: 1.4)),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      height: 28,
                                      child: CustomPaint(
                                        size: const Size(double.infinity, 28),
                                        painter: _SparklinePainter(ctrl: _countCtrl, color: tc.accentDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (morph > 0.3)
                              Expanded(
                                child: Opacity(
                                  opacity: siblings,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Column(
                                      children: [
                                        _TapCard(
                                          onTap: () => _showDetail('Date', _CalendarDetail()),
                                          delay: 0,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text('16', style: TextStyle(fontFamily: 'Artific', fontSize: 24, fontWeight: FontWeight.w900, color: tc.textPrimary, height: 1.0)),
                                              const SizedBox(width: 8),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('Tue.', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                                  Text('December', style: TextStyle(fontFamily: 'Artific', fontSize: 9, fontWeight: FontWeight.w500, color: tc.textSecondary)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _TapCard(
                                          onTap: () => _showDetail('Streak', _StreakDetail()),
                                          delay: 1,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(width: 6, height: 6, decoration: BoxDecoration(color: tc.orange, shape: BoxShape.circle)),
                                                  const SizedBox(width: 6),
                                                  Text('16 Days', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text('110 hrs, 32 min', style: TextStyle(fontFamily: 'Artific', fontSize: 9, fontWeight: FontWeight.w400, color: tc.textSecondary)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: List.generate(8, (i) {
                                                  return Container(
                                                    width: 5, height: 5,
                                                    margin: const EdgeInsets.only(right: 3),
                                                    decoration: BoxDecoration(color: i < 6 ? tc.accent : tc.border, borderRadius: BorderRadius.circular(2)),
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
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            _TapCard(
                              onTap: () => _showDetail('Adherence', _AdherenceDetail()),
                              delay: 2,
                              child: Row(
                                children: [
                                  _IconBadge(icon: Icons.check_circle_rounded, bg: tc.accent.withValues(alpha: 0.1), fg: tc.accent),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Adherence', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w500, color: tc.textSecondary)),
                                      const SizedBox(height: 2),
                                      Text('94%', style: TextStyle(fontFamily: 'Artific', fontSize: 20, fontWeight: FontWeight.w800, color: tc.textPrimary, height: 1.0)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _TapCard(
                              onTap: () => _showDetail('Supplements', _SupplementsDetail()),
                              delay: 3,
                              child: Row(
                                children: [
                                  _IconBadge(icon: Icons.medication_rounded, bg: tc.blue.withValues(alpha: 0.1), fg: tc.blue),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Supplements', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w500, color: tc.textSecondary)),
                                      const SizedBox(height: 2),
                                      Text('7 active', style: TextStyle(fontFamily: 'Artific', fontSize: 18, fontWeight: FontWeight.w800, color: tc.textPrimary, height: 1.0)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TapCard(
                              onTap: () => _showDetail('This Week', _WeekDetail()),
                              delay: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('This Week', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                      const Spacer(),
                                      Text('6/7 days', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w500, color: tc.textSecondary)),
                                    ],
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
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
                            _TapCard(
                              onTap: () => _showDetail('Consistency', _ConsistencyDetail()),
                              delay: 5,
                              bg: tc.accentLight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Consistency', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [0.4, 0.6, 0.5, 0.8, 0.7, 0.9, 0.85].map((h) {
                                      return Expanded(
                                        child: Container(
                                          height: 20 * h,
                                          margin: const EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(color: tc.textPrimary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(2)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('1,541', style: TextStyle(fontFamily: 'Artific', fontSize: 20, fontWeight: FontWeight.w900, color: tc.textPrimary, height: 1.0)),
                                  Text('total doses', style: TextStyle(fontFamily: 'Artific', fontSize: 9, fontWeight: FontWeight.w500, color: tc.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        flex: 3,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TapCard(
                              onTap: () => _showDetail('Schedule', _ScheduleDetail()),
                              delay: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Schedule', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                  const SizedBox(height: 6),
                                  _ScheduleRow(icon: Icons.wb_sunny_rounded, label: 'Morning', count: 3, color: tc.orange),
                                  const SizedBox(height: 4),
                                  _ScheduleRow(icon: Icons.wb_cloudy_rounded, label: 'Afternoon', count: 2, color: tc.blue),
                                  const SizedBox(height: 4),
                                  _ScheduleRow(icon: Icons.nights_stay_rounded, label: 'Evening', count: 2, color: tc.purple),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            _TapCard(
                              onTap: () => _showDetail('Stock', _StockDetail()),
                              delay: 7,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('Stock', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w700, color: tc.textPrimary)),
                                      const Spacer(),
                                      Icon(Icons.warning_amber_rounded, size: 13, color: tc.orange),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _StockRow(name: 'Vitamin D', count: 5, color: tc.orange),
                                  const SizedBox(height: 4),
                                  _StockRow(name: 'Omega-3', count: 12, color: tc.accent),
                                  const SizedBox(height: 4),
                                  _StockRow(name: 'Magnesium', count: 3, color: tc.red),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: _onContinue,
                        child: Container(
                          width: double.infinity,
                          height: 46,
                          decoration: BoxDecoration(color: tc.textPrimary, borderRadius: BorderRadius.circular(14)),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Done', style: TextStyle(fontFamily: 'Artific', fontSize: 15, fontWeight: FontWeight.w600, color: tc.cardBg)),
                                const SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 16, color: tc.cardBg),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: 1600.ms, duration: 600.ms, curve: Curves.easeOutCubic).slideY(begin: 0.3, end: 0, delay: 1600.ms, duration: 600.ms, curve: Curves.easeOutCubic),
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

class _TapCard extends StatelessWidget {
  final int delay;
  final Widget child;
  final Color? bg;
  final VoidCallback onTap;
  const _TapCard({required this.delay, required this.child, this.bg, required this.onTap});

  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg ?? tc.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: (bg == null || bg == tc.cardBg) ? Border.all(color: tc.border) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: child,
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 1300 + delay * 80), duration: 500.ms, curve: Curves.easeOutCubic).scale(
      begin: const Offset(0.88, 0.88),
      end: const Offset(1.0, 1.0),
      delay: Duration(milliseconds: 1300 + delay * 80),
      duration: 500.ms,
      curve: Curves.easeOutBack,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  const _IconBadge({required this.icon, required this.bg, required this.fg});
  @override Widget build(BuildContext context) {
    return Container(width: 32, height: 32, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)), child: Icon(icon, size: 16, color: fg));
  }
}

class _SparklinePainter extends CustomPainter {
  final AnimationController ctrl;
  final Color color;
  const _SparklinePainter({required this.ctrl, required this.color});
  @override void paint(Canvas canvas, Size size) {
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
      canvas.drawRect(Rect.fromLTWH(i * barW + 2, 0, barW - 4, size.height), Paint()..color = color.withValues(alpha: 0.04)..style = PaintingStyle.fill);
    }
    final path = Path();
    final vis = (pts.length * p).ceil().clamp(1, pts.length);
    path.moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < vis; i++) {
      final prev = pts[i - 1]; final curr = pts[i]; final mx = (prev.dx + curr.dx) / 2;
      path.cubicTo(mx, prev.dy, mx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(path, Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    if (vis > 0 && p > 0.85) {
      final last = pts[vis - 1];
      canvas.drawCircle(last, 4, Paint()..color = color.withValues(alpha: 0.15));
      canvas.drawCircle(last, 2, Paint()..color = color);
    }
  }
  @override bool shouldRepaint(covariant _SparklinePainter old) => old.ctrl.value != ctrl.value;
}

class _WeekBar extends StatelessWidget {
  final double h; final String l; final bool t;
  const _WeekBar({required this.h, required this.l, required this.t});
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 32 * h, decoration: BoxDecoration(color: t ? tc.accent : tc.accent.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(3))),
        const SizedBox(height: 3),
        Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 9, fontWeight: t ? FontWeight.w700 : FontWeight.w500, color: t ? tc.accent : tc.textMuted)),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon; final String label; final int count; final Color color;
  const _ScheduleRow({required this.icon, required this.label, required this.count, required this.color});
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Row(
      children: [
        Container(width: 22, height: 22, decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)), child: Icon(icon, size: 11, color: color)),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary)),
        const Spacer(),
        Text('$count', style: TextStyle(fontFamily: 'Artific', fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _StockRow extends StatelessWidget {
  final String name; final int count; final Color color;
  const _StockRow({required this.name, required this.count, required this.color});
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Row(
      children: [
        Expanded(child: Text(name, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))),
        const SizedBox(width: 4),
        Container(width: 36, height: 3, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: (count / 15).clamp(0.0, 1.0), child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))))),
        const SizedBox(width: 5),
        Text('$count', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}

class _DetailSheet extends StatefulWidget {
  final String title;
  final Widget content;
  const _DetailSheet({required this.title, required this.content});
  @override State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(const Duration(milliseconds: 80), () { if (mounted) _ctrl.forward(); });
  }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(color: tc.bg, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(padding: const EdgeInsets.only(top: 12, bottom: 16), child: Container(width: 36, height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)))),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
            Text(widget.title, style: TextStyle(fontFamily: 'Artific', fontSize: 20, fontWeight: FontWeight.w800, color: tc.textPrimary)),
            const Spacer(),
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(width: 32, height: 32, decoration: BoxDecoration(color: tc.cardBg, borderRadius: BorderRadius.circular(10), border: Border.all(color: tc.border)), child: Icon(Icons.close_rounded, size: 16, color: tc.textPrimary))),
          ])).animate(controller: _ctrl).fadeIn(delay: 0.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 0.ms, duration: 400.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 20),
          Flexible(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: widget.content)),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _AdherenceDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_st('94%', 'Adherence', tc), _st('12', 'Weeks', tc), _st('84', 'Days', tc)])
        .animate().fadeIn(delay: 80.ms, duration: 450.ms).slideY(begin: 0.25, end: 0, delay: 80.ms, duration: 450.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 24),
      Text('12-Week History', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 180.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 12),
      _dm(7, 12, 78, 260, tc),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [_ld(tc.accent, 'Taken', tc), const SizedBox(width: 20), _ld(tc.border, 'Missed', tc)])
        .animate().fadeIn(delay: 900.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 900.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 24),
      Text('Weekly Breakdown', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 1000.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 1000.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
        _mb(0.9, 'W1', 1080, tc), _mb(0.85, 'W2', 1130, tc), _mb(1.0, 'W3', 1180, tc), _mb(0.75, 'W4', 1230, tc),
        _mb(0.9, 'W5', 1280, tc), _mb(0.8, 'W6', 1330, tc), _mb(1.0, 'W7', 1380, tc), _mb(0.85, 'W8', 1430, tc),
        _mb(0.9, 'W9', 1480, tc), _mb(1.0, 'W10', 1530, tc), _mb(0.7, 'W11', 1580, tc), _mb(0.9, 'W12', 1630, tc),
      ]),
    ]);
  }
  Widget _st(String v, String l, ThemeColors tc) => Column(children: [Text(v, style: TextStyle(fontFamily: 'Artific', fontSize: 28, fontWeight: FontWeight.w900, color: tc.accentDark, height: 1.0)), const SizedBox(height: 4), Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))]);
  Widget _mb(double h, String l, int d, ThemeColors tc) => Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 18, height: 40 * h, decoration: BoxDecoration(color: h >= 0.9 ? tc.accent : tc.accent.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(3))),
    const SizedBox(height: 4), Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 8, fontWeight: FontWeight.w500, color: tc.textMuted)),
  ]).animate().fadeIn(delay: Duration(milliseconds: d), duration: 350.ms).slideY(begin: 0.35, end: 0, delay: Duration(milliseconds: d), duration: 350.ms, curve: Curves.easeOutCubic).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: d), duration: 350.ms, curve: Curves.easeOutBack);
}

class _CalendarDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final daysInMonth = 31; final firstWeekday = 1;
    final monthData = List.generate(30, (i) => i % 7 != 5);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('December 2025', style: TextStyle(fontFamily: 'Artific', fontSize: 16, fontWeight: FontWeight.w800, color: tc.textPrimary))
        .animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: ['S','M','T','W','T','F','S'].map((d) => Text(d, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w600, color: tc.textMuted))).toList())
        .animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 160.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 8),
      GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 7, childAspectRatio: 1.1, children: [
        ...List.generate(firstWeekday, (_) => const SizedBox.shrink()),
        ...List.generate(daysInMonth, (i) {
          final day = i + 1; final isToday = day == 16; final taken = monthData[i % monthData.length];
          return Center(child: Container(width: 32, height: 32, decoration: BoxDecoration(color: isToday ? tc.accent : taken ? tc.accent.withValues(alpha: 0.12) : Colors.transparent, borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$day', style: TextStyle(fontFamily: 'Artific', fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.w500, color: isToday ? Colors.white : taken ? tc.accentDark : tc.textMuted))))).animate().fadeIn(delay: Duration(milliseconds: 240 + i * 12), duration: 250.ms).scale(begin: const Offset(0.6, 0.6), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 240 + i * 12), duration: 250.ms, curve: Curves.easeOutBack);
        }),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [_ld(tc.accent, 'Taken', tc), const SizedBox(width: 20), _ld(tc.border, 'Missed', tc), const SizedBox(width: 20), _ld(tc.accent, 'Today', tc)])
        .animate().fadeIn(delay: 800.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 800.ms, duration: 400.ms, curve: Curves.easeOutCubic),
    ]);
  }
}

class _StreakDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_st('24', 'Current', tc), _st('42', 'Best', tc), _st('3', 'Missed', tc)])
        .animate().fadeIn(delay: 80.ms, duration: 450.ms).slideY(begin: 0.25, end: 0, delay: 80.ms, duration: 450.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 24),
      Text('30-Day History', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 180.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 12),
      _dm(10, 3, 24, 260, tc),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [_ld(tc.accent, 'On Track', tc), const SizedBox(width: 20), _ld(tc.border, 'Missed', tc)])
        .animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.1, end: 0, delay: 700.ms, duration: 400.ms, curve: Curves.easeOutCubic),
    ]);
  }
  Widget _st(String v, String l, ThemeColors tc) => Column(children: [Text(v, style: TextStyle(fontFamily: 'Artific', fontSize: 28, fontWeight: FontWeight.w900, color: tc.accentDark, height: 1.0)), const SizedBox(height: 4), Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))]);
}

class _SupplementsDetail extends StatelessWidget {
  final List<Map<String, dynamic>> _supplements = const [
    {'name': 'Vitamin D3', 'dose': '2000 IU', 'schedule': 'Morning', 'active': true},
    {'name': 'Omega-3', 'dose': '1000 mg', 'schedule': 'Morning', 'active': true},
    {'name': 'Magnesium', 'dose': '400 mg', 'schedule': 'Evening', 'active': true},
    {'name': 'Zinc', 'dose': '15 mg', 'schedule': 'Afternoon', 'active': true},
    {'name': 'Probiotics', 'dose': '50B CFU', 'schedule': 'Morning', 'active': true},
    {'name': 'B-Complex', 'dose': '1 tablet', 'schedule': 'Morning', 'active': false},
    {'name': 'Iron', 'dose': '18 mg', 'schedule': 'Afternoon', 'active': true},
  ];
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Active Supplements', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 80.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 16),
      ..._supplements.asMap().entries.map((e) {
        final i = e.key; final s = e.value; final isActive = s['active'] as bool;
        return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: isActive ? tc.accent.withValues(alpha: 0.1) : tc.surface, borderRadius: BorderRadius.circular(10)), child: Icon(Icons.medication_rounded, size: 18, color: isActive ? tc.accent : tc.textMuted)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['name'] as String, style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary)),
            Text('${s['dose']} \u00B7 ${s['schedule']}', style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: isActive ? tc.accent.withValues(alpha: 0.1) : tc.surface, borderRadius: BorderRadius.circular(8)), child: Text(isActive ? 'Active' : 'Paused', style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? tc.accentDark : tc.textMuted))),
        ])).animate().fadeIn(delay: Duration(milliseconds: 160 + i * 70), duration: 350.ms).slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 160 + i * 70), duration: 350.ms, curve: Curves.easeOutCubic).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 160 + i * 70), duration: 350.ms, curve: Curves.easeOutBack);
      }),
    ]);
  }
}

class _WeekDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final bars = [0.55, 0.8, 0.65, 1.0, 0.85, 0.7, 0.45]; final labels = ['M','T','W','T','F','S','S'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_st('6/7', 'This Week', tc), _st('28', 'This Month', tc), _st('336', 'This Year', tc)])
        .animate().fadeIn(delay: 80.ms, duration: 450.ms).slideY(begin: 0.25, end: 0, delay: 80.ms, duration: 450.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 24),
      Text('Daily Breakdown', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 180.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: bars.asMap().entries.map((e) {
        final i = e.key; final h = e.value;
        return Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 28, height: 60 * h, decoration: BoxDecoration(color: i == 3 ? tc.accent : tc.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 6), Text(labels[i], style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: i == 3 ? FontWeight.w700 : FontWeight.w500, color: i == 3 ? tc.accent : tc.textMuted)),
        ]).animate().fadeIn(delay: Duration(milliseconds: 260 + i * 60), duration: 350.ms).slideY(begin: 0.35, end: 0, delay: Duration(milliseconds: 260 + i * 60), duration: 350.ms, curve: Curves.easeOutCubic).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 260 + i * 60), duration: 350.ms, curve: Curves.easeOutBack);
      }).toList()),
      const SizedBox(height: 24),
      Text('Week Overview', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 700.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 700.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [true, true, true, true, true, false, true].asMap().entries.map((e) {
        final i = e.key; final taken = e.value;
        return Container(width: 28, height: 28, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(color: taken ? tc.accent.withValues(alpha: 0.12) : tc.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: taken ? tc.accent.withValues(alpha: 0.3) : tc.border)), child: Center(child: Icon(taken ? Icons.check_rounded : Icons.close_rounded, size: 14, color: taken ? tc.accent : tc.textMuted))).animate().fadeIn(delay: Duration(milliseconds: 780 + i * 50), duration: 300.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 780 + i * 50), duration: 300.ms, curve: Curves.easeOutBack);
      }).toList()),
    ]);
  }
  Widget _st(String v, String l, ThemeColors tc) => Column(children: [Text(v, style: TextStyle(fontFamily: 'Artific', fontSize: 24, fontWeight: FontWeight.w900, color: tc.accentDark, height: 1.0)), const SizedBox(height: 4), Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))]);
}

class _ConsistencyDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul']; final values = [0.7, 0.8, 0.75, 0.9, 0.85, 0.92, 0.88];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_st('1,541', 'Total Doses', tc), _st('220', 'Avg/Week', tc), _st('98%', 'On-Time', tc)])
        .animate().fadeIn(delay: 80.ms, duration: 450.ms).slideY(begin: 0.25, end: 0, delay: 80.ms, duration: 450.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 24),
      Text('Monthly Trend', style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary))
        .animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.15, end: 0, delay: 180.ms, duration: 400.ms, curve: Curves.easeOutCubic),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: values.asMap().entries.map((e) {
        final i = e.key; final h = e.value;
        return Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(height: 50 * h, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: tc.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4))).animate().fadeIn(delay: Duration(milliseconds: 260 + i * 70), duration: 350.ms).slideY(begin: 0.4, end: 0, delay: Duration(milliseconds: 260 + i * 70), duration: 350.ms, curve: Curves.easeOutCubic).scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 260 + i * 70), duration: 350.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 6), Text(months[i], style: TextStyle(fontFamily: 'Artific', fontSize: 10, fontWeight: FontWeight.w500, color: tc.textMuted)).animate().fadeIn(delay: Duration(milliseconds: 300 + i * 70), duration: 300.ms),
        ]));
      }).toList()),
    ]);
  }
  Widget _st(String v, String l, ThemeColors tc) => Column(children: [Text(v, style: TextStyle(fontFamily: 'Artific', fontSize: 24, fontWeight: FontWeight.w900, color: tc.accentDark, height: 1.0)), const SizedBox(height: 4), Text(l, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))]);
}

class _ScheduleDetail extends StatelessWidget {
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final slots = [
      {'icon': Icons.wb_sunny_rounded, 'label': 'Morning', 'time': '8:00 AM', 'items': ['Vitamin D3', 'Omega-3', 'Probiotics']},
      {'icon': Icons.wb_cloudy_rounded, 'label': 'Afternoon', 'time': '1:00 PM', 'items': ['Zinc', 'Iron']},
      {'icon': Icons.nights_stay_rounded, 'label': 'Evening', 'time': '8:00 PM', 'items': ['Magnesium', 'B-Complex']},
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ...slots.asMap().entries.map((entry) {
        final i = entry.key; final slot = entry.value;
        return Padding(padding: const EdgeInsets.only(bottom: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(slot['icon'] as IconData, size: 20, color: tc.textSecondary),
            const SizedBox(width: 12),
            Text(slot['label'] as String, style: TextStyle(fontFamily: 'Artific', fontSize: 14, fontWeight: FontWeight.w700, color: tc.textPrimary)),
            const Spacer(),
            Text(slot['time'] as String, style: TextStyle(fontFamily: 'Artific', fontSize: 12, fontWeight: FontWeight.w600, color: tc.textMuted)),
          ]).animate().fadeIn(delay: Duration(milliseconds: 80 + i * 120), duration: 350.ms).slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 80 + i * 120), duration: 350.ms, curve: Curves.easeOutCubic),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.only(left: 32), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: (slot['items'] as List<String>).asMap().entries.map((itemEntry) {
            final j = itemEntry.key; final item = itemEntry.value;
            return Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
              Icon(Icons.check_circle_rounded, size: 14, color: tc.accent), const SizedBox(width: 8),
              Text(item, style: TextStyle(fontFamily: 'Artific', fontSize: 12, fontWeight: FontWeight.w500, color: tc.textSecondary)),
            ])).animate().fadeIn(delay: Duration(milliseconds: 120 + i * 120 + j * 50), duration: 300.ms).slideX(begin: 0.15, end: 0, delay: Duration(milliseconds: 120 + i * 120 + j * 50), duration: 300.ms, curve: Curves.easeOutCubic);
          }).toList())),
        ]));
      }),
    ]);
  }
}

class _StockDetail extends StatelessWidget {
  final List<Map<String, dynamic>> _supplements = const [
    {'name': 'Vitamin D', 'count': 5, 'max': 30, 'color': AppColors.orange},
    {'name': 'Omega-3', 'count': 12, 'max': 60, 'color': AppColors.accent},
    {'name': 'Magnesium', 'count': 3, 'max': 30, 'color': AppColors.red},
    {'name': 'Zinc', 'count': 8, 'max': 30, 'color': AppColors.accent},
    {'name': 'Probiotics', 'count': 15, 'max': 30, 'color': AppColors.accent},
    {'name': 'B-Complex', 'count': 20, 'max': 30, 'color': AppColors.accent},
    {'name': 'Iron', 'count': 7, 'max': 30, 'color': AppColors.accent},
  ];
  @override Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ..._supplements.asMap().entries.map((entry) {
        final i = entry.key; final s = entry.value;
        final stock = s['count'] as int; final max = s['max'] as int; final isLow = stock < 6; final ratio = (stock / max).clamp(0.0, 1.0); final color = s['color'] as Color;
        return Padding(padding: const EdgeInsets.only(bottom: 16), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['name'] as String, style: TextStyle(fontFamily: 'Artific', fontSize: 13, fontWeight: FontWeight.w700, color: tc.textPrimary)),
            const SizedBox(height: 6),
            Container(height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)), child: FractionallySizedBox(alignment: Alignment.centerLeft, widthFactor: ratio, child: Container(decoration: BoxDecoration(color: isLow ? tc.orange : color, borderRadius: BorderRadius.circular(2))))).animate().fadeIn(delay: Duration(milliseconds: 100 + i * 70), duration: 400.ms).slideX(begin: 0.2, end: 0, delay: Duration(milliseconds: 100 + i * 70), duration: 400.ms, curve: Curves.easeOutCubic),
          ])),
          const SizedBox(width: 16),
          Text('$stock', style: TextStyle(fontFamily: 'Artific', fontSize: 14, fontWeight: FontWeight.w800, color: isLow ? tc.orange : tc.textPrimary)).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 70), duration: 300.ms),
          const SizedBox(width: 4),
          if (isLow) Icon(Icons.warning_amber_rounded, size: 16, color: tc.orange).animate().fadeIn(delay: Duration(milliseconds: 250 + i * 70), duration: 250.ms).scale(begin: const Offset(0.5, 0.5), end: const Offset(1.0, 1.0), delay: Duration(milliseconds: 250 + i * 70), duration: 250.ms, curve: Curves.easeOutBack),
        ])).animate().fadeIn(delay: Duration(milliseconds: 80 + i * 70), duration: 350.ms).slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 80 + i * 70), duration: 350.ms, curve: Curves.easeOutCubic);
      }),
    ]);
  }
}

Widget _dm(int cols, int rows, int activeCount, int baseDelay, ThemeColors tc) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: List.generate(rows, (r) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(cols, (c) {
            final idx = r * cols + c;
            final active = idx < activeCount;
            final delayMs = baseDelay + idx * 12;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: c == 0 || c == cols - 1 ? 0 : 1.5),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: active ? tc.accent : tc.border,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ).animate()
                    .fadeIn(delay: Duration(milliseconds: delayMs), duration: 180.ms)
                    .scale(
                        begin: const Offset(0.2, 0.2),
                        end: const Offset(1.0, 1.0),
                        delay: Duration(milliseconds: delayMs),
                        duration: 180.ms,
                        curve: Curves.easeOutBack),
              ),
            );
          }),
        ),
      );
    }),
  );
}

Widget _ld(Color color, String label, ThemeColors tc) {
  return Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))), const SizedBox(width: 6), Text(label, style: TextStyle(fontFamily: 'Artific', fontSize: 11, fontWeight: FontWeight.w500, color: tc.textSecondary))]);
}
