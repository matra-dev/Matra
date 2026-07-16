import 'health_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _trendCtrl;
  late final AnimationController _calendarCtrl;
  late final AnimationController _detailCtrl;
  late final PageController _carouselCtrl;
  int _activeTab = 0;
  int _carouselPage = 0;
  DateTime _calendarMonth = DateTime.now();
  DateTime? _selectedCalendarDay;
  bool _calendarExpanded = true;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _trendCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _calendarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _detailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _carouselCtrl = PageController(viewportFraction: 0.88);
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _trendCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _trendCtrl.dispose();
    _calendarCtrl.dispose();
    _detailCtrl.dispose();
    _carouselCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (index == _activeTab) return;
    Haptics.selection();
    setState(() => _activeTab = index);
    if (index == 2) {
      _calendarCtrl.reset();
      _calendarCtrl.forward();
      _detailCtrl.reset();
      _detailCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: tc.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ───────────────────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.sm, GR.lg, 0),
                child: Row(
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HealthDashboardScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 1),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          size: GR.iconSm + 2,
                          color: tc.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: GR.md),

              // ── Custom pill tabs ─────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Row(
                  children: [
                    _buildTabButton(l10n.overview, 0),
                    SizedBox(width: GR.sm),
                    _buildTabButton(l10n.trends, 1),
                    SizedBox(width: GR.sm),
                    _buildTabButton(l10n.history, 2),
                  ],
                ),
              ),

              SizedBox(height: GR.md),

              // ── Tab Content ──────────────────────────────────────
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_activeTab),
                    child: _activeTab == 0
                        ? _buildOverviewTab()
                        : _activeTab == 1
                            ? _buildTrendsTab()
                            : _buildHistoryTab(),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildTabButton(String label, int index) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isActive = _activeTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
          decoration: BoxDecoration(
            color: isActive ? tc.accent : tc.surface,
            borderRadius: BorderRadius.circular(GR.radiusLg - 1),
            border: Border.all(
              color: isActive ? tc.accent : tc.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? Colors.white : tc.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Tab 1: Overview ─────────────────────────────────────────────────────
  Widget _buildOverviewTab() {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Carousel data: each supplement with its stats
    final supplements = [
      {
        'name': 'Vitamin D3',
        'subtitle': 'Daily Intake',
        'value': '2000',
        'unit': 'IU',
        'status': 'On Track',
        'statusColor': tc.accentDark,
        'statusBg': tc.accentBg,
        'week': [true, true, true, true, true, false, true],
        'summary': '6/7 days · On Track',
      },
      {
        'name': 'Omega-3',
        'subtitle': 'Fish Oil Supplement',
        'value': '1000',
        'unit': 'mg',
        'status': 'On Track',
        'statusColor': tc.accentDark,
        'statusBg': tc.accentBg,
        'week': [true, true, true, true, true, true, true],
        'summary': '7/7 days · Perfect',
      },
      {
        'name': 'Magnesium',
        'subtitle': 'Evening Supplement',
        'value': '400',
        'unit': 'mg',
        'status': 'Needs Attention',
        'statusColor': tc.textSecondary,
        'statusBg': tc.surface,
        'week': [true, false, true, true, false, true, true],
        'summary': '5/7 days · Missed 2',
      },
      {
        'name': 'Zinc',
        'subtitle': 'Immune Support',
        'value': '25',
        'unit': 'mg',
        'status': 'On Track',
        'statusColor': tc.accentDark,
        'statusBg': tc.accentBg,
        'week': [true, true, true, true, true, true, false],
        'summary': '6/7 days · On Track',
      },
      {
        'name': 'Probiotics',
        'subtitle': 'Gut Health',
        'value': '50B',
        'unit': 'CFU',
        'status': 'On Track',
        'statusColor': tc.accentDark,
        'statusBg': tc.accentBg,
        'week': [true, true, false, true, true, true, true],
        'summary': '6/7 days · On Track',
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: GR.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: GR.sm),

          // ── Swipeable Supplement Carousel ──────────────────────
          SizedBox(
            height: 340,
            child: PageView.builder(
              controller: _carouselCtrl,
              physics: const BouncingScrollPhysics(),
              itemCount: supplements.length,
              onPageChanged: (page) {
                Haptics.light();
                setState(() => _carouselPage = page);
              },
              itemBuilder: (context, index) {
                final supp = supplements[index];
                final week = supp['week'] as List<bool>;
                return _buildSupplementCard(
                  context,
                  name: supp['name'] as String,
                  subtitle: supp['subtitle'] as String,
                  value: supp['value'] as String,
                  unit: supp['unit'] as String,
                  status: supp['status'] as String,
                  statusColor: supp['statusColor'] as Color,
                  statusBg: supp['statusBg'] as Color,
                  week: week,
                  summary: supp['summary'] as String,
                  index: index,
                  pageKey: _carouselPage == index ? _carouselPage : -1,
                );
              },
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 100.ms, duration: 600.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 100.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.lg),

          // ── Page Indicator ───────────────────────────────────
          Center(
            child: _buildPageIndicator(context, supplements.length),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 300.ms, duration: 400.ms),

          SizedBox(height: GR.lg + 2),

          // ── Weekly Adherence (global) ────────────────────────
          GoldenCard(
            padding: EdgeInsets.all(GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: GR.iconSm - 2,
                      color: tc.textMuted,
                    ),
                    SizedBox(width: GR.xs + 2),
                    Text(
                      l10n.overallAdherence,
                      style: AppTextStyles.caption(context),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HealthDashboardScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            l10n.viewAll,
                            style: AppTextStyles.caption(context,
                                color: tc.accent),
                          ),
                          SizedBox(width: GR.xs - 2),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: tc.accent,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: GR.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DayPill(day: 'M', taken: true, delay: 0),
                    _DayPill(day: 'T', taken: true, delay: 1),
                    _DayPill(day: 'W', taken: true, delay: 2),
                    _DayPill(day: 'T', taken: true, delay: 3, isToday: true),
                    _DayPill(day: 'F', taken: true, delay: 4),
                    _DayPill(day: 'S', taken: false, delay: 5),
                    _DayPill(day: 'S', taken: true, delay: 6),
                  ],
                ),
                SizedBox(height: GR.md),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                  decoration: BoxDecoration(
                    color: tc.accentLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      '6/7 days · On Track',
                      style: AppTextStyles.bodySmall(context,
                          weight: FontWeight.w600, color: tc.accentDark),
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 500.ms, duration: 700.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 500.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.xxl + GR.xl),
        ],
      ),
    );
  }

  Widget _buildSupplementCard(
    BuildContext context, {
    required String name,
    required String subtitle,
    required String value,
    required String unit,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required List<bool> week,
    required String summary,
    required int index,
    required int pageKey,
  }) {
    final tc = ThemeColors.of(context);
    return Padding(
      key: ValueKey('supp_card_$pageKey'),
      padding: EdgeInsets.symmetric(horizontal: GR.xs + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name + subtitle
          Text(
            name,
            style: AppTextStyles.h1(context),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 80.ms, duration: 500.ms).slideY(
              begin: 0.25,
              end: 0,
              delay: 80.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic),
          SizedBox(height: GR.xs + 2),
          Text(
            '$subtitle · ${DateFormat('MMMM d, yyyy').format(DateTime.now())}',
            style: AppTextStyles.bodySmall(context),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 160.ms, duration: 500.ms).slideY(
              begin: 0.2,
              end: 0,
              delay: 160.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic),
          SizedBox(height: GR.lg + 2),

          // Big value
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: AppTextStyles.display(context),
              ).animate().fadeIn(delay: 260.ms, duration: 500.ms).slideY(
                  begin: 0.3,
                  end: 0,
                  delay: 260.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),
              SizedBox(width: GR.xs + 2),
              Padding(
                padding: EdgeInsets.only(bottom: GR.md + 2),
                child: Text(
                  unit,
                  style: AppTextStyles.h3(context, color: tc.textMuted),
                ).animate().fadeIn(delay: 340.ms, duration: 400.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 340.ms,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic),
              ),
            ],
          ),
          SizedBox(height: GR.lg),

          // Status pill
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: GR.md + 1, vertical: GR.xs + 2),
            decoration: BoxDecoration(
              color: statusBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(GR.radiusLg - 1),
              border: Border.all(color: statusColor.withValues(alpha: 0.2)),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption(context,
                  weight: FontWeight.w700, color: statusColor),
            ),
          )
              .animate()
              .fadeIn(delay: 420.ms, duration: 400.ms)
              .slideY(
                  begin: 0.15,
                  end: 0,
                  delay: 420.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic)
              .scale(
                  begin: Offset(0.92, 0.92),
                  end: Offset(1.0, 1.0),
                  delay: 420.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutBack),
          SizedBox(height: GR.lg),

          // Mini week strip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: week.asMap().entries.map((entry) {
              final i = entry.key;
              final taken = entry.value;
              final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.xs),
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: taken
                            ? tc.accent.withValues(alpha: 0.12)
                            : tc.surface,
                        borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        border: Border.all(
                          color: taken
                              ? tc.accent.withValues(alpha: 0.3)
                              : tc.border,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          taken ? Icons.check_rounded : Icons.close_rounded,
                          size: 14,
                          color: taken ? tc.accent : tc.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: GR.xs - 1),
                    Text(
                      dayLabels[i],
                      style: AppTextStyles.caption(
                        context,
                        weight: FontWeight.w600,
                        color: taken ? tc.accentDark : tc.textMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideY(
              begin: 0.15,
              end: 0,
              delay: 500.ms,
              duration: 500.ms,
              curve: Curves.easeOutCubic),
          SizedBox(height: GR.sm + 2),
          Text(
            summary,
            style: AppTextStyles.caption(context, color: tc.textSecondary),
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms).slideY(
              begin: 0.1,
              end: 0,
              delay: 600.ms,
              duration: 400.ms,
              curve: Curves.easeOutCubic),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(BuildContext context, int count) {
    final tc = ThemeColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        return Container(
          width: i == 0 ? 20 : 8,
          height: 8,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: i == 0 ? tc.accent : tc.border,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  // ─── Tab 2: Trends ───────────────────────────────────────────────────────────
  Widget _buildTrendsTab() {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: GR.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: GR.lg),

          // ── Adherence Trend Bar Chart ────────────────────────
          GoldenCard(
            padding: EdgeInsets.all(GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      size: GR.iconSm - 2,
                      color: tc.textMuted,
                    ),
                    SizedBox(width: GR.xs + 2),
                    Text(
                      l10n.adherenceTrend,
                      style: AppTextStyles.caption(context),
                    ),
                    const Spacer(),
                    Text(
                      'Dec 1 - Dec 16',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
                SizedBox(height: GR.lg),
                Row(
                  children: [
                    Container(
                      width: GR.xs + 2,
                      height: GR.xs + 2,
                      decoration: BoxDecoration(
                        color: tc.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: GR.xs + 2),
                    Text(
                      '+12%',
                      style: AppTextStyles.h2(context, color: tc.accentDark),
                    ),
                    SizedBox(width: GR.xs - 2),
                    Padding(
                      padding: EdgeInsets.only(top: GR.xs - 2),
                      child: Text(
                        'this month',
                        style: AppTextStyles.bodySmall(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GR.lg + 2),
                SizedBox(
                  height: 160,
                  child: AnimatedBuilder(
                    animation: _trendCtrl,
                    builder: (context, child) {
                      final progress =
                          Curves.easeOutCubic.transform(_trendCtrl.value);
                      return _buildGradientAreaChart(context, progress);
                    },
                  ),
                ),
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 700.ms, duration: 700.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 700.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.xl + 2),

          // ── Weekly Dot Matrix Breakdown ────────────────────────
          GoldenCard(
            padding: EdgeInsets.all(GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: GR.iconSm - 2,
                      color: tc.textMuted,
                    ),
                    SizedBox(width: GR.xs + 2),
                    Text(
                      'WEEKLY BREAKDOWN',
                      style: AppTextStyles.caption(context),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: tc.accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: GR.xs),
                        Text(
                          l10n.taken,
                          style: AppTextStyles.caption(context,
                              color: tc.textSecondary),
                        ),
                        SizedBox(width: GR.sm),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: tc.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: GR.xs),
                        Text(
                          l10n.missed,
                          style: AppTextStyles.caption(context,
                              color: tc.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: GR.lg),
                _buildWeeklyDotMatrix(context),
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 900.ms, duration: 700.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 900.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.xl + 2),

          // ── 30-Day Streak Calendar ───────────────────────────
          GoldenCard(
            padding: EdgeInsets.all(GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: GR.iconSm - 2,
                      color: tc.textMuted,
                    ),
                    SizedBox(width: GR.xs + 2),
                    Text(
                      l10n.dayStreak,
                      style: AppTextStyles.caption(context),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: GR.sm + 2, vertical: GR.xs + 1),
                      decoration: BoxDecoration(
                        color: tc.accentBg,
                        borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                      ),
                      child: Text(
                        '24/30 days',
                        style: AppTextStyles.caption(context,
                            weight: FontWeight.w700, color: tc.accentDark),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GR.lg),
                _buildStreakGrid(context),
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 1100.ms, duration: 700.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 1100.ms,
                  duration: 700.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.xxl + GR.xl),
        ],
      ),
    );
  }

  // ─── Tab 3: History ──────────────────────────────────────────────────────────
  Widget _buildHistoryTab() {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    // Rich per-dose data: date -> list of {name, dosage, time, taken, icon, color}
    final doseLogData = <DateTime, List<Map<String, dynamic>>>{
      DateTime(now.year, now.month, now.day): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:15 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:15 AM',
          'taken': true,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:15 PM',
          'taken': false,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
      ],
      DateTime(now.year, now.month, now.day - 1): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:05 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:05 AM',
          'taken': true,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:30 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
        {
          'name': 'Zinc',
          'dosage': '25 mg',
          'time': '01:00 PM',
          'taken': true,
          'icon': Icons.wb_cloudy_rounded,
          'color': AppColors.orange
        },
      ],
      DateTime(now.year, now.month, now.day - 2): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:20 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:20 AM',
          'taken': true,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:00 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
      ],
      DateTime(now.year, now.month, now.day - 3): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '09:00 AM',
          'taken': false,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '09:00 AM',
          'taken': false,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:00 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
      ],
      DateTime(now.year, now.month, now.day - 4): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:10 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:10 AM',
          'taken': true,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:15 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
        {
          'name': 'Zinc',
          'dosage': '25 mg',
          'time': '01:30 PM',
          'taken': true,
          'icon': Icons.wb_cloudy_rounded,
          'color': AppColors.orange
        },
        {
          'name': 'Probiotics',
          'dosage': '50B CFU',
          'time': '08:10 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
      ],
      DateTime(now.year, now.month, now.day - 5): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:00 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:00 AM',
          'taken': true,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:00 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
        {
          'name': 'Zinc',
          'dosage': '25 mg',
          'time': '01:00 PM',
          'taken': true,
          'icon': Icons.wb_cloudy_rounded,
          'color': AppColors.orange
        },
      ],
      DateTime(now.year, now.month, now.day - 6): [
        {
          'name': 'Vitamin D3',
          'dosage': '2000 IU',
          'time': '08:30 AM',
          'taken': true,
          'icon': Icons.wb_sunny_rounded,
          'color': AppColors.accentDark
        },
        {
          'name': 'Omega-3 Fish Oil',
          'dosage': '1000 mg',
          'time': '08:30 AM',
          'taken': false,
          'icon': Icons.water_drop_rounded,
          'color': AppColors.blue
        },
        {
          'name': 'Magnesium',
          'dosage': '400 mg',
          'time': '08:00 PM',
          'taken': true,
          'icon': Icons.bolt_rounded,
          'color': AppColors.purple
        },
      ],
    };

    // Build adherence summary from dose logs
    Map<DateTime, Map<String, int>> adherenceData = {};
    for (final entry in doseLogData.entries) {
      final day = entry.key;
      final items = entry.value;
      final taken = items.where((i) => i['taken'] as bool).length;
      adherenceData[day] = {'taken': taken, 'total': items.length};
    }

    // Add more days with just adherence summary (no detailed logs)
    for (int i = 7; i <= 30; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      if (!adherenceData.containsKey(day)) {
        final patterns = [
          {'taken': 3, 'total': 3},
          {'taken': 4, 'total': 4},
          {'taken': 2, 'total': 4},
          {'taken': 5, 'total': 5},
          {'taken': 3, 'total': 5},
          {'taken': 1, 'total': 4},
          {'taken': 4, 'total': 4},
        ];
        adherenceData[day] = patterns[i % patterns.length];
      }
    }

    // Calculate overall stats
    int totalTaken = 0;
    int totalDoses = 0;
    for (final entry in adherenceData.values) {
      totalTaken += entry['taken']!;
      totalDoses += entry['total']!;
    }
    final adherence =
        totalDoses > 0 ? ((totalTaken / totalDoses) * 100).round() : 0;
    final streakDays = _calculateStreak(adherenceData);

    // Determine which day to show detail for
    final detailDay = _selectedCalendarDay ?? now;
    final hasDetailData = doseLogData.containsKey(detailDay);
    final detailItems = doseLogData[detailDay] ?? [];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: GR.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: GR.lg),

          // ── Month Navigation + Collapse Toggle ───────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Haptics.light();
                  setState(() {
                    _calendarMonth =
                        DateTime(_calendarMonth.year, _calendarMonth.month - 1);
                  });
                  _calendarCtrl.reset();
                  _calendarCtrl.forward();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tc.surface,
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: Icon(Icons.chevron_left_rounded,
                      size: 22, color: tc.textPrimary),
                ),
              ),
              SizedBox(width: GR.md),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _monthYearText(_calendarMonth),
                  key: ValueKey(_monthYearText(_calendarMonth)),
                  style: AppTextStyles.h2(context),
                ),
              ),
              SizedBox(width: GR.md),
              GestureDetector(
                onTap: () {
                  Haptics.light();
                  setState(() {
                    _calendarMonth =
                        DateTime(_calendarMonth.year, _calendarMonth.month + 1);
                  });
                  _calendarCtrl.reset();
                  _calendarCtrl.forward();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tc.surface,
                    borderRadius: BorderRadius.circular(GR.radiusMd),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      size: 22, color: tc.textPrimary),
                ),
              ),
            ],
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 50.ms, duration: 400.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 50.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.lg),

          // ── Collapsible Calendar ─────────────────────────────
          GoldenCard(
            padding: EdgeInsets.all(GR.md + 2),
            child: Column(
              children: [
                // Calendar header with collapse toggle
                Row(
                  children: [
                    Text(
                      'Calendar',
                      style:
                          AppTextStyles.body(context, weight: FontWeight.w700),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Haptics.selection();
                        setState(() => _calendarExpanded = !_calendarExpanded);
                      },
                      child: AnimatedRotation(
                        turns: _calendarExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 22,
                          color: tc.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                // Animated calendar body
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 350),
                  firstCurve: Curves.easeOutCubic,
                  secondCurve: Curves.easeInCubic,
                  sizeCurve: Curves.easeOutCubic,
                  crossFadeState: _calendarExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Column(
                    children: [
                      SizedBox(height: GR.sm + 2),
                      // Day of week headers
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children:
                            ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) {
                          return SizedBox(
                            width: 40,
                            child: Center(
                              child: Text(
                                day,
                                style: AppTextStyles.caption(
                                  context,
                                  weight: FontWeight.w700,
                                  color: tc.textMuted,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: GR.sm + 2),
                      _buildCalendarGrid(context, adherenceData),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
                // Mini summary bar when collapsed
                if (!_calendarExpanded)
                  Padding(
                    padding: EdgeInsets.only(top: GR.sm + 2),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: tc.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: GR.xs + 2),
                        Text(
                          'Tap to expand calendar',
                          style: AppTextStyles.caption(context,
                              color: tc.textSecondary),
                        ),
                        const Spacer(),
                        Text(
                          '$adherence% adherence',
                          style: AppTextStyles.caption(context,
                              weight: FontWeight.w700, color: tc.accentDark),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 150.ms, duration: 500.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 150.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.lg),

          // ── Stats Row ────────────────────────────────────────
          Row(
            children: [
              _buildHistoryStatCard(
                context,
                label: 'Adherence',
                value: '$adherence%',
                color: tc.accentDark,
                bgColor: tc.accentBg,
                icon: Icons.check_circle_rounded,
              ),
              SizedBox(width: GR.sm),
              _buildHistoryStatCard(
                context,
                label: 'Streak',
                value: '$streakDays',
                color: tc.orange,
                bgColor: tc.orangeLight.withValues(alpha: 0.4),
                icon: Icons.local_fire_department_rounded,
              ),
              SizedBox(width: GR.sm),
              _buildHistoryStatCard(
                context,
                label: 'Taken',
                value: '$totalTaken',
                color: tc.textPrimary,
                bgColor: tc.surface,
                icon: Icons.medication_rounded,
              ),
            ],
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 300.ms, duration: 500.ms)
              .slideY(
                  begin: 0.2,
                  end: 0,
                  delay: 300.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic),

          SizedBox(height: GR.lg + 2),

          // ── Legend ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(tc.accent, 'All taken', tc),
              SizedBox(width: GR.md),
              _buildLegendDot(tc.orange, 'Partial', tc),
              SizedBox(width: GR.md),
              _buildLegendDot(tc.red, 'Missed', tc),
              SizedBox(width: GR.md),
              _buildLegendDot(tc.border, 'No data', tc),
            ],
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 400.ms, duration: 400.ms),

          SizedBox(height: GR.lg + 2),

          // ── Selected Day Detail Header ───────────────────────
          Padding(
            padding: EdgeInsets.only(left: GR.xs, bottom: GR.sm),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCalendarDay != null
                          ? _dayName(_selectedCalendarDay!)
                          : 'Today',
                      style: AppTextStyles.h3(context),
                    ),
                    SizedBox(height: GR.xs - 2),
                    Text(
                      _selectedCalendarDay != null
                          ? '${_selectedCalendarDay!.day} ${_monthShort(_selectedCalendarDay!.month)} ${_selectedCalendarDay!.year}'
                          : '${now.day} ${_monthShort(now.month)} ${now.year}',
                      style: AppTextStyles.caption(context),
                    ),
                  ],
                ),
                const Spacer(),
                if (hasDetailData) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: GR.sm + 4, vertical: GR.xs + 2),
                    decoration: BoxDecoration(
                      color: tc.accentBg,
                      borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                    ),
                    child: Text(
                      '${detailItems.where((i) => i['taken'] as bool).length}/${detailItems.length}',
                      style: AppTextStyles.caption(context,
                          weight: FontWeight.w700, color: tc.accentDark),
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: GR.sm + 4, vertical: GR.xs + 2),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                    ),
                    child: Text(
                      'No detailed logs',
                      style: AppTextStyles.caption(context,
                          color: tc.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 500.ms, duration: 400.ms)
              .slideY(
                  begin: 0.15,
                  end: 0,
                  delay: 500.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),

          // ── Detailed Dose List ───────────────────────────────
          if (hasDetailData) ...[
            GoldenCard(
              padding: EdgeInsets.all(GR.md + 2),
              child: Column(
                children: detailItems.asMap().entries.map((itemEntry) {
                  final i = itemEntry.key;
                  final item = itemEntry.value;
                  final isTaken = item['taken'] as bool;
                  final isLast = i == detailItems.length - 1;

                  return Column(
                    children: [
                      Row(
                        children: [
                          // Colored icon container
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (item['color'] as Color)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(GR.radiusMd),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              size: GR.iconSm + 2,
                              color: item['color'] as Color,
                            ),
                          ),
                          SizedBox(width: GR.md),
                          // Name + dosage + time
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: AppTextStyles.body(context,
                                      weight: FontWeight.w600),
                                ),
                                SizedBox(height: GR.xs - 2),
                                Row(
                                  children: [
                                    Text(
                                      item['dosage'] as String,
                                      style: AppTextStyles.bodySmall(context),
                                    ),
                                    SizedBox(width: GR.sm),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      decoration: BoxDecoration(
                                        color: tc.textMuted,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: GR.sm),
                                    Icon(
                                      Icons.access_time_rounded,
                                      size: 11,
                                      color: tc.textMuted,
                                    ),
                                    SizedBox(width: GR.xs),
                                    Text(
                                      item['time'] as String,
                                      style: AppTextStyles.caption(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status with label
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: GR.sm + 2, vertical: GR.xs + 1),
                            decoration: BoxDecoration(
                              color: isTaken
                                  ? tc.accent.withValues(alpha: 0.12)
                                  : tc.surface,
                              borderRadius:
                                  BorderRadius.circular(GR.radiusSm + 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isTaken
                                      ? Icons.check_rounded
                                      : Icons.close_rounded,
                                  size: 14,
                                  color: isTaken ? tc.accent : tc.textMuted,
                                ),
                                SizedBox(width: GR.xs - 1),
                                Text(
                                  isTaken ? 'Taken' : 'Missed',
                                  style: AppTextStyles.caption(
                                    context,
                                    weight: FontWeight.w600,
                                    color: isTaken ? tc.accent : tc.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!isLast) ...[
                        SizedBox(height: GR.sm + 2),
                        Divider(height: 1, color: tc.border),
                        SizedBox(height: GR.sm + 2),
                      ],
                    ],
                  );
                }).toList(),
              ),
            )
                .animate(controller: _detailCtrl)
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(
                    begin: 0.2,
                    end: 0,
                    delay: 100.ms,
                    duration: 500.ms,
                    curve: Curves.easeOutCubic),
          ] else ...[
            // No detailed data for this day
            GoldenCard(
              padding: EdgeInsets.all(GR.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 40,
                      color: tc.textMuted,
                    ),
                    SizedBox(height: GR.sm),
                    Text(
                      'No detailed logs for this day',
                      style: AppTextStyles.bodySmall(context,
                          color: tc.textSecondary),
                    ),
                    SizedBox(height: GR.xs),
                    Text(
                      'Select a day with data from the calendar',
                      style:
                          AppTextStyles.caption(context, color: tc.textMuted),
                    ),
                  ],
                ),
              ),
            )
                .animate(controller: _detailCtrl)
                .fadeIn(delay: 100.ms, duration: 400.ms),
          ],

          SizedBox(height: GR.lg + 2),

          // ── Recent Days with Detailed Logs ───────────────────
          Padding(
            padding: EdgeInsets.only(left: GR.xs, bottom: GR.sm),
            child: Text(
              'Recent Days',
              style: AppTextStyles.h3(context),
            ),
          )
              .animate(controller: _entranceCtrl)
              .fadeIn(delay: 600.ms, duration: 400.ms)
              .slideY(
                  begin: 0.15,
                  end: 0,
                  delay: 600.ms,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic),

          ..._buildRecentDaysList(context, doseLogData, adherenceData),

          SizedBox(height: GR.xxl + GR.xl),
        ],
      ),
    );
  }

  String _monthYearText(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  int _calculateStreak(Map<DateTime, Map<String, int>> data) {
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = DateTime(now.year, now.month, now.day - i);
      final entry = data[day];
      if (entry != null && entry['taken'] == entry['total']) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  Widget _buildLegendDot(Color color, String label, ThemeColors tc) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: GR.xs + 2),
        Text(
          label,
          style: AppTextStyles.caption(context, color: tc.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(
      BuildContext context, Map<DateTime, Map<String, int>> data) {
    final tc = ThemeColors.of(context);
    final year = _calendarMonth.year;
    final month = _calendarMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    final cells = <Widget>[];
    int dayCounter = 1;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    for (int i = 0; i < totalCells; i++) {
      if (i < startWeekday || dayCounter > daysInMonth) {
        cells.add(const SizedBox(width: 40, height: 52));
      } else {
        final day = DateTime(year, month, dayCounter);
        final isToday = day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;
        final isSelected = _selectedCalendarDay != null &&
            day.year == _selectedCalendarDay!.year &&
            day.month == _selectedCalendarDay!.month &&
            day.day == _selectedCalendarDay!.day;
        final entry = data[day];
        final hasData = entry != null;
        final allTaken = hasData && entry['taken'] == entry['total'];
        final partial =
            hasData && entry['taken']! > 0 && entry['taken']! < entry['total']!;
        final missed = hasData && entry['taken'] == 0;

        Color dotColor = tc.border;
        if (allTaken) {
          dotColor = tc.accent;
        } else if (partial) {
          dotColor = tc.orange;
        } else if (missed) {
          dotColor = tc.red;
        }

        cells.add(
          GestureDetector(
            onTap: () {
              Haptics.selection();
              setState(() => _selectedCalendarDay = day);
              _detailCtrl.reset();
              _detailCtrl.forward();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 52,
              decoration: BoxDecoration(
                color: isSelected
                    ? tc.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(GR.radiusMd),
                border:
                    isToday ? Border.all(color: tc.accent, width: 1.5) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayCounter',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 15,
                      fontWeight: isToday || isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: isToday
                          ? tc.accent
                          : isSelected
                              ? tc.accentDark
                              : day.weekday == 6 || day.weekday == 7
                                  ? tc.textMuted
                                  : tc.textPrimary,
                    ),
                  ),
                  SizedBox(height: GR.xs + 2),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          )
              .animate(controller: _calendarCtrl)
              .fadeIn(
                delay: Duration(milliseconds: (i % 7 + (i ~/ 7) * 3) * 35),
                duration: const Duration(milliseconds: 300),
              )
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                delay: Duration(milliseconds: (i % 7 + (i ~/ 7) * 3) * 35),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
              ),
        );
        dayCounter++;
      }
    }

    return Column(
      children: [
        for (int row = 0; row < cells.length ~/ 7; row++)
          Padding(
            padding: EdgeInsets.only(bottom: GR.xs + 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: cells.sublist(row * 7, (row + 1) * 7),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildRecentDaysList(
    BuildContext context,
    Map<DateTime, List<Map<String, dynamic>>> doseLogData,
    Map<DateTime, Map<String, int>> adherenceData,
  ) {
    final tc = ThemeColors.of(context);
    final now = DateTime.now();
    final sortedDays = doseLogData.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return sortedDays.asMap().entries.map((entry) {
      final i = entry.key;
      final day = entry.value;
      final items = doseLogData[day]!;
      final taken = items.where((item) => item['taken'] as bool).length;
      final total = items.length;
      final allTaken = taken == total;
      final partial = taken > 0 && taken < total;

      Color dotColor = tc.border;
      if (allTaken) {
        dotColor = tc.accent;
      } else if (partial) {
        dotColor = tc.orange;
      } else {
        dotColor = tc.red;
      }

      String dayLabel;
      final diff = now.difference(day).inDays;
      if (diff == 0) {
        dayLabel = 'Today';
      } else if (diff == 1) {
        dayLabel = 'Yesterday';
      } else {
        dayLabel = _dayName(day);
      }

      return Padding(
        padding: EdgeInsets.only(bottom: GR.sm + 2),
        child: GestureDetector(
          onTap: () {
            Haptics.selection();
            setState(() {
              _selectedCalendarDay = day;
              _calendarMonth = DateTime(day.year, day.month);
              _calendarExpanded = true;
            });
            _detailCtrl.reset();
            _detailCtrl.forward();
          },
          child: GoldenCard(
            padding: EdgeInsets.all(GR.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: tc.surface,
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${day.day}',
                            style: AppTextStyles.body(context,
                                weight: FontWeight.w700),
                          ),
                          Text(
                            _monthShort(day.month),
                            style: AppTextStyles.caption(context,
                                color: tc.textMuted),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: GR.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayLabel,
                            style: AppTextStyles.body(context,
                                weight: FontWeight.w600),
                          ),
                          SizedBox(height: GR.xs - 2),
                          Text(
                            '$taken/$total doses taken',
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: GR.sm + 2),
                // Mini dose chips
                Wrap(
                  spacing: GR.xs + 2,
                  runSpacing: GR.xs + 2,
                  children: items.map((item) {
                    final isTaken = item['taken'] as bool;
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: GR.sm + 2, vertical: GR.xs + 1),
                      decoration: BoxDecoration(
                        color: isTaken
                            ? (item['color'] as Color).withValues(alpha: 0.1)
                            : tc.surface,
                        borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        border: Border.all(
                          color: isTaken
                              ? (item['color'] as Color).withValues(alpha: 0.3)
                              : tc.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 12,
                            color:
                                isTaken ? item['color'] as Color : tc.textMuted,
                          ),
                          SizedBox(width: GR.xs),
                          Text(
                            item['name'] as String,
                            style: AppTextStyles.caption(
                              context,
                              weight: FontWeight.w600,
                              color: isTaken
                                  ? item['color'] as Color
                                  : tc.textMuted,
                            ),
                          ),
                          SizedBox(width: GR.xs - 1),
                          Text(
                            item['time'] as String,
                            style: AppTextStyles.caption(context,
                                color: tc.textMuted),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(controller: _entranceCtrl)
          .fadeIn(
              delay: Duration(milliseconds: 700 + i * 100),
              duration: const Duration(milliseconds: 400))
          .slideY(
              begin: 0.15,
              end: 0,
              delay: Duration(milliseconds: 700 + i * 100),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic);
    }).toList();
  }

  String _dayName(DateTime day) {
    const names = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return names[day.weekday - 1];
  }

  String _monthShort(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[month - 1];
  }

  Widget _buildHistoryStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    final tc = ThemeColors.of(context);
    return Expanded(
      child: GoldenCard(
        padding: EdgeInsets.all(GR.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                SizedBox(width: GR.xs),
                Text(
                  label,
                  style:
                      AppTextStyles.caption(context, color: tc.textSecondary),
                ),
              ],
            ),
            SizedBox(height: GR.xs + 2),
            Text(
              value,
              style: AppTextStyles.h2(context, color: color),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Weekly Dot Matrix ─────────────────────────────────────────────────────
  Widget _buildWeeklyDotMatrix(BuildContext context) {
    final tc = ThemeColors.of(context);
    final weekData = [
      {'day': 'Mon', 'total': 5, 'taken': 4},
      {'day': 'Tue', 'total': 5, 'taken': 5},
      {'day': 'Wed', 'total': 5, 'taken': 4},
      {'day': 'Thu', 'total': 5, 'taken': 5},
      {'day': 'Fri', 'total': 5, 'taken': 5},
      {'day': 'Sat', 'total': 5, 'taken': 3},
      {'day': 'Sun', 'total': 5, 'taken': 4},
    ];

    return Column(
      children: weekData.asMap().entries.map((entry) {
        final i = entry.key;
        final d = entry.value;
        final total = d['total'] as int;
        final taken = d['taken'] as int;
        final adherence = ((taken / total) * 100).round();
        final isHigh = adherence >= 90;

        return Padding(
          padding: EdgeInsets.only(bottom: i == weekData.length - 1 ? 0 : 8),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  d['day'] as String,
                  style: AppTextStyles.bodySmall(context, weight: FontWeight.w500),
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(total, (dotIndex) {
                    final isTaken = dotIndex < taken;
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: const EdgeInsets.only(right: 3),
                        decoration: BoxDecoration(
                          color: isTaken ? tc.accent : tc.surface,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(
                            delay: Duration(
                                milliseconds: 1000 + i * 60 + dotIndex * 25),
                            duration: 180.ms,
                          )
                          .scale(
                            begin: const Offset(0.0, 0.0),
                            end: const Offset(1.0, 1.0),
                            delay: Duration(
                                milliseconds: 1000 + i * 60 + dotIndex * 25),
                            duration: 180.ms,
                            curve: Curves.easeOutBack,
                          ),
                    );
                  }),
                ),
              ),
              SizedBox(width: 12),
              Text(
                '$adherence%',
                style: AppTextStyles.caption(
                  context,
                  weight: FontWeight.w600,
                  color: isHigh ? tc.accentDark : tc.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ─── 30-Day Streak Grid ────────────────────────────────────────────────────
  Widget _buildStreakGrid(BuildContext context) {
    final tc = ThemeColors.of(context);
    final streakData = [
      true, true, false, true, true, true, true,
      true, true, true, true, false, true, true,
      true, true, true, true, true, true, true,
      true, false, true, true, true, true, true,
      true, true, true,
    ];

    final rows = <List<bool>>[];
    for (int r = 0; r < 5; r++) {
      final row = <bool>[];
      for (int c = 0; c < 6; c++) {
        final idx = r * 6 + c;
        if (idx < streakData.length) row.add(streakData[idx]);
      }
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...rows.asMap().entries.map((rowEntry) {
          final rowIdx = rowEntry.key;
          final rowDays = rowEntry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: rowIdx < rows.length - 1 ? 4 : 0),
            child: Row(
              children: rowDays.asMap().entries.map((dayEntry) {
                final dayIdx = dayEntry.key;
                final isPerfect = dayEntry.value;
                final dayNum = rowIdx * 6 + dayIdx + 1;
                final globalIdx = dayNum - 1;

                return Expanded(
                  child: Container(
                    height: 32,
                    margin: EdgeInsets.only(
                        right: dayIdx < rowDays.length - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: isPerfect
                          ? tc.accent.withValues(alpha: 0.1)
                          : tc.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isPerfect
                            ? tc.accent.withValues(alpha: 0.2)
                            : tc.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: AppTextStyles.caption(
                          context,
                          weight: FontWeight.w500,
                          color: isPerfect ? tc.accentDark : tc.textMuted,
                        ),
                      ),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(
                        delay: Duration(milliseconds: 1200 + globalIdx * 25),
                        duration: 200.ms,
                      )
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1.0, 1.0),
                        delay: Duration(milliseconds: 1200 + globalIdx * 25),
                        duration: 200.ms,
                        curve: Curves.easeOutBack,
                      ),
                );
              }).toList(),
            ),
          );
        }),

        SizedBox(height: GR.md),

        Row(
          children: [
            Expanded(
              child: _buildStatItem(context, '24', 'Perfect', tc.accentDark),
            ),
            SizedBox(width: GR.sm),
            Expanded(
              child: _buildStatItem(context, '6', 'Missed', tc.textSecondary),
            ),
            SizedBox(width: GR.sm),
            Expanded(
              child: _buildStatItem(context, '80%', 'Adherence', tc.textPrimary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color valueColor) {
    final tc = ThemeColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.h3(context, color: valueColor),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption(context, color: tc.textSecondary),
        ),
      ],
    );
  }

  // ─── Gradient Area Chart ───────────────────────────────────────────────────
  Widget _buildGradientAreaChart(BuildContext context, double progress) {
    final tc = ThemeColors.of(context);
    final data = const [
      65,
      72,
      68,
      85,
      90,
      88,
      92,
      95,
      89,
      94,
      96,
      91,
      93,
      97,
      98,
      96
    ];
    final labels = const [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '14',
      '15',
      '16'
    ];

    return CustomPaint(
      size: const Size(double.infinity, 160),
      painter: _GradientAreaPainter(
        data: data,
        labels: labels,
        progress: progress,
        lineColor: tc.accent,
        fillGradientStart: tc.accent.withValues(alpha: 0.35),
        fillGradientEnd: tc.accent.withValues(alpha: 0.02),
        gridColor: tc.border,
        textColor: tc.textMuted,
      ),
    );
  }
}

// ─── Gradient Area Chart Painter ─────────────────────────────────────────────
class _GradientAreaPainter extends CustomPainter {
  final List<int> data;
  final List<String> labels;
  final double progress;
  final Color lineColor;
  final Color fillGradientStart;
  final Color fillGradientEnd;
  final Color gridColor;
  final Color textColor;

  _GradientAreaPainter({
    required this.data,
    required this.labels,
    required this.progress,
    required this.lineColor,
    required this.fillGradientStart,
    required this.fillGradientEnd,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    const padding = EdgeInsets.only(left: 28, right: 8, top: 16, bottom: 24);
    final chartW = size.width - padding.left - padding.right;
    final chartH = size.height - padding.top - padding.bottom;

    const maxVal = 100.0;
    const minVal = 50.0;
    final range = maxVal - minVal;

    final visibleCount = (data.length * progress).ceil().clamp(1, data.length);

    // Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i <= 4; i++) {
      final y = padding.top + (chartH * i / 4);
      canvas.drawLine(
        Offset(padding.left, y),
        Offset(padding.left + chartW, y),
        gridPaint,
      );
    }

    // Build points
    final points = <Offset>[];
    for (int i = 0; i < visibleCount; i++) {
      final x = padding.left + (i / (data.length - 1)) * chartW;
      final normalizedVal = ((data[i] - minVal) / range).clamp(0.0, 1.0);
      final y = padding.top + chartH - (normalizedVal * chartH);
      points.add(Offset(x, y));
    }

    if (points.length < 2) return;

    // Smooth curve using Catmull-Rom spline
    final smoothPoints = _smoothCurve(points);

    // Draw gradient fill area
    final fillPath = Path();
    fillPath.moveTo(points.first.dx, padding.top + chartH);
    fillPath.lineTo(points.first.dx, points.first.dy);

    for (int i = 1; i < smoothPoints.length; i++) {
      fillPath.lineTo(smoothPoints[i].dx, smoothPoints[i].dy);
    }

    fillPath.lineTo(smoothPoints.last.dx, padding.top + chartH);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillGradientStart, fillGradientEnd],
      ).createShader(Rect.fromLTWH(padding.left, padding.top, chartW, chartH))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw line on top
    final linePath = Path();
    linePath.moveTo(smoothPoints.first.dx, smoothPoints.first.dy);
    for (int i = 1; i < smoothPoints.length; i++) {
      linePath.lineTo(smoothPoints[i].dx, smoothPoints[i].dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    // Draw dots at data points
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotOutlinePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final isLast = i == points.length - 1;
      final radius = isLast ? 5.0 : 3.5;

      // White outline
      canvas.drawCircle(points[i], radius + 1.5, dotOutlinePaint);
      // Colored dot
      canvas.drawCircle(points[i], radius, dotPaint);
    }

    // Draw Y-axis labels
    final labelStyle = TextStyle(
      fontFamily: 'Artific',
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: textColor,
    );

    for (int i = 0; i <= 4; i++) {
      final val = (maxVal - (range * i / 4)).toStringAsFixed(0);
      final y = padding.top + (chartH * i / 4);
      final span = TextSpan(text: val, style: labelStyle);
      final tp = TextPainter(text: span);
      tp.layout();
      tp.paint(canvas, Offset(padding.left - tp.width - 6, y - tp.height / 2));
    }

    // Draw X-axis labels (every 4th)
    for (int i = 0; i < points.length; i += 4) {
      final span = TextSpan(text: labels[i], style: labelStyle);
      final tp = TextPainter(text: span);
      tp.layout();
      tp.paint(
        canvas,
        Offset(points[i].dx - tp.width / 2, padding.top + chartH + 6),
      );
    }
  }

  List<Offset> _smoothCurve(List<Offset> points) {
    if (points.length < 3) return points;

    final result = <Offset>[];
    result.add(points.first);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      for (int j = 1; j <= 8; j++) {
        final t = j / 8;
        final x = _catmullRom(p0.dx, p1.dx, p2.dx, p3.dx, t);
        final y = _catmullRom(p0.dy, p1.dy, p2.dy, p3.dy, t);
        result.add(Offset(x, y));
      }
    }

    result.add(points.last);
    return result;
  }

  double _catmullRom(double p0, double p1, double p2, double p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    return 0.5 *
        ((2 * p1) +
            (-p0 + p2) * t +
            (2 * p0 - 5 * p1 + 4 * p2 - p3) * t2 +
            (-p0 + 3 * p1 - 3 * p2 + p3) * t3);
  }

  @override
  bool shouldRepaint(covariant _GradientAreaPainter old) {
    return old.progress != progress || old.data.length != data.length;
  }
}

// ─── Day Pill (used in Overview tab) ─────────────────────────────────────────
class _DayPill extends StatelessWidget {
  final String day;
  final bool taken;
  final bool isToday;
  final int delay;

  const _DayPill({
    required this.day,
    required this.taken,
    this.isToday = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      width: 38,
      height: 52,
      decoration: BoxDecoration(
        color: taken ? tc.accentLight.withValues(alpha: 0.3) : tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd + 1),
        border: Border.all(
          color: isToday
              ? tc.accent
              : taken
                  ? tc.accentLight
                  : tc.border,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 14,
              fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
              color: isToday ? tc.accentDark : tc.textSecondary,
            ),
          ),
          SizedBox(height: GR.xs),
          Icon(
            taken ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: GR.iconSm - 2,
            color: taken ? tc.accent : tc.textMuted,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: 1200 + delay * 60),
            duration: const Duration(milliseconds: 400))
        .scale(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1.0, 1.0),
          delay: Duration(milliseconds: 1200 + delay * 60),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
        );
  }
}
