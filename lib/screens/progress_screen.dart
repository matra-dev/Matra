import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

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
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: GR.sm),

                // Header with Toggle
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      height: GR.buttonSm + 4,
                      padding: EdgeInsets.all(GR.xs),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(GR.radiusLg),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _toggleView(true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm),
                              decoration: BoxDecoration(
                                color: _isCharts ? AppColors.textPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(GR.radiusMd),
                              ),
                              child: Text(
                                'Charts',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _isCharts ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _toggleView(false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm),
                              decoration: BoxDecoration(
                                color: !_isCharts ? AppColors.textPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(GR.radiusMd),
                              ),
                              child: Text(
                                'List',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: !_isCharts ? Colors.white : AppColors.textSecondary,
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
                      child: Text(
                        'Export',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl),

                if (_isCharts) ...[
                  // Charts View
                  Text(
                    'See your daily steps and much more',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 100.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.lg),

                  // Health Connect Card
                  GoldenCard(
                    padding: EdgeInsets.all(GR.lg),
                    child: Column(
                      children: [
                        Container(
                          width: GR.lg * 3,
                          height: GR.lg * 3,
                          decoration: BoxDecoration(
                            color: AppColors.accentLight.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(GR.radiusLg),
                          ),
                          child: Icon(Icons.favorite_rounded, size: GR.iconLg + 2, color: AppColors.accentDark),
                        ),
                        SizedBox(height: GR.md),
                        Text(
                          'Connect with Health',
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: GR.sm),
                        Text(
                          'Sync your daily steps, heart rate, and sleep data automatically.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: GR.md),
                        GestureDetector(
                          onTap: () => Haptics.medium(),
                          child: Container(
                            width: double.infinity,
                            height: GR.buttonSm + 4,
                            decoration: BoxDecoration(
                              color: AppColors.accentDark,
                              borderRadius: BorderRadius.circular(GR.radiusMd),
                            ),
                            child: Center(
                              child: Text(
                                'Connect',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 16,
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

                  SizedBox(height: GR.lg),

                  // Weekly adherence chart
                  GoldenCard(
                    padding: EdgeInsets.all(GR.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Vitamin D3',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'This Week',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 14,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: GR.lg),
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

                  SizedBox(height: GR.lg),

                  // Personalize button
                  GestureDetector(
                    onTap: () => Haptics.medium(),
                    child: Container(
                      width: double.infinity,
                      height: GR.buttonSm + 4,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: AppColors.accentLight),
                      ),
                      child: Center(
                        child: Text(
                          'Personalize',
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
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                ] else ...[
                  _buildListView(),
                ],

                SizedBox(height: GR.lg),
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
              padding: EdgeInsets.only(left: GR.xs, bottom: GR.sm, top: i == 0 ? 0 : GR.lg),
              child: Text(
                e['date'] as String,
                style: TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            GoldenCard(
              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 3),
              child: Row(
                children: [
                  Icon(Icons.medication_rounded, size: GR.iconSm, color: AppColors.textMuted),
                  SizedBox(width: GR.md),
                  Expanded(
                    child: Text(
                      e['med'] as String,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    (e['taken'] as bool) ? Icons.check_circle_rounded : Icons.help_outline_rounded,
                    size: GR.iconSm + 2,
                    color: (e['taken'] as bool) ? AppColors.accent : AppColors.textMuted,
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
            fontSize: 12,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            color: isToday ? AppColors.accentDark : AppColors.textMuted,
          ),
        ),
        SizedBox(height: GR.sm),
        Container(
          width: GR.lg + 2,
          height: GR.lg + 2,
          decoration: BoxDecoration(
            color: taken ? AppColors.accentLight.withValues(alpha: 0.4) : AppColors.surface,
            borderRadius: BorderRadius.circular(GR.lg + 2),
            border: isToday
                ? Border.all(color: AppColors.accentDark, width: 2)
                : taken
                    ? Border.all(color: AppColors.accentLight)
                    : null,
          ),
          child: taken
              ? Icon(Icons.check_rounded, size: GR.iconSm, color: AppColors.accentDark)
              : Icon(Icons.question_mark_rounded, size: GR.iconSm - 2, color: AppColors.textMuted),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 400 + delay * 60), duration: 300.ms)
        .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), delay: Duration(milliseconds: 400 + delay * 60), duration: 300.ms, curve: Curves.easeOutBack);
  }
}
