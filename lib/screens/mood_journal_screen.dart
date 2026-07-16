import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import '../widgets/dot_matrix_loading.dart';

/// Elegant mood journal screen — opens after selecting a mood
/// Asks what's affecting the user and how Matra can help
class MoodJournalScreen extends StatefulWidget {
  final String moodEmoji;
  final String moodLabel;

  const MoodJournalScreen({
    super.key,
    required this.moodEmoji,
    required this.moodLabel,
  });

  @override
  State<MoodJournalScreen> createState() => _MoodJournalScreenState();
}

class _MoodJournalScreenState extends State<MoodJournalScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  final _noteController = TextEditingController();
  final List<String> _selectedFactors = [];
  bool _isSubmitting = false;
  double _wellnessScore = 0.0;

  final List<Map<String, dynamic>> _factors = [
    {'icon': Icons.bolt_rounded, 'label': 'Energy', 'positive': true},
    {'icon': Icons.bedtime_rounded, 'label': 'Sleep', 'positive': true},
    {'icon': Icons.restaurant_rounded, 'label': 'Diet', 'positive': true},
    {'icon': Icons.fitness_center_rounded, 'label': 'Exercise', 'positive': true},
    {'icon': Icons.work_rounded, 'label': 'Work', 'positive': false},
    {'icon': Icons.people_rounded, 'label': 'Social', 'positive': true},
    {'icon': Icons.healing_rounded, 'label': 'Pain', 'positive': false},
    {'icon': Icons.water_drop_rounded, 'label': 'Hydration', 'positive': true},
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.stop();
    _entranceCtrl.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _toggleFactor(String label) {
    Haptics.selection();
    setState(() {
      if (_selectedFactors.contains(label)) {
        _selectedFactors.remove(label);
      } else {
        _selectedFactors.add(label);
      }
      _calculateWellness();
    });
  }

  void _calculateWellness() {
    if (_selectedFactors.isEmpty) {
      _wellnessScore = 0.0;
      return;
    }
    int positive = 0;
    for (final factor in _factors) {
      if (_selectedFactors.contains(factor['label']) && factor['positive'] == true) {
        positive++;
      }
    }
    _wellnessScore = (positive / _selectedFactors.length) * 100;
  }

  void _submit() async {
    Haptics.success();
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thank you for sharing. You\'re doing great.',
            style: TextStyle(fontFamily: 'Artific', fontSize: 13),
          ),
          backgroundColor: ThemeColors.of(context).accentDark,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Color _moodColor() {
    final tc = ThemeColors.of(context);
    return switch (widget.moodLabel) {
      'Great' => tc.accent,
      'Good' => tc.accent,
      'Okay' => tc.textSecondary,
      'Bad' => const Color(0xFFFF6B6B),
      'Terrible' => const Color(0xFFFF4757),
      _ => tc.accent,
    };
  }

  Color _moodLightColor() {
    return switch (widget.moodLabel) {
      'Great' => const Color(0xFFB2DFDB),
      'Good' => const Color(0xFFB2DFDB),
      'Okay' => const Color(0xFFE0E0E0),
      'Bad' => const Color(0xFFFFCDD2),
      'Terrible' => const Color(0xFFEF9A9A),
      _ => const Color(0xFFB2DFDB),
    };
  }

  String _moodMessage() {
    return switch (widget.moodLabel) {
      'Great' => 'You\'re shining today',
      'Good' => 'Things are looking up',
      'Okay' => 'Every feeling is valid',
      'Bad' => 'We\'re here with you',
      'Terrible' => 'This too shall pass',
      _ => 'How are you feeling?',
    };
  }

  String _moodSubtitle() {
    return switch (widget.moodLabel) {
      'Great' => 'Keep this positive momentum going',
      'Good' => 'Celebrate the small wins',
      'Okay' => 'It\'s perfectly fine to pause',
      'Bad' => 'Be gentle with yourself today',
      'Terrible' => 'Take it one breath at a time',
      _ => 'Tell us more',
    };
  }

  String _promptText() {
    return switch (widget.moodLabel) {
      'Great' => 'What\'s fueling your positive energy?',
      'Good' => 'What\'s been going well?',
      'Okay' => 'Anything on your mind?',
      'Bad' => 'What\'s weighing on you?',
      'Terrible' => 'We\'re listening. What happened?',
      _ => 'Share your thoughts',
    };
  }

  String _wellnessMessage() {
    if (_selectedFactors.isEmpty) return 'Select factors to see your wellness pulse';
    if (_wellnessScore >= 70) return 'Your wellness pulse looks strong';
    if (_wellnessScore >= 40) return 'Mixed signals — let\'s work on balance';
    return 'Some areas need attention — we can help';
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final moodColor = _moodColor();
    final moodLight = _moodLightColor();

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, 0),
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
                          color: tc.surface,
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                        ),
                        child: Icon(Icons.close_rounded, size: 18, color: tc.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Mood Hero with Wellness Pulse ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, GR.lg),
                child: Column(
                  children: [
                    // Mood emoji with animated ring
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: moodLight.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: moodLight.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              widget.moodEmoji,
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 0.ms, duration: 700.ms)
                        .scale(
                          begin: const Offset(0.3, 0.3),
                          end: const Offset(1.0, 1.0),
                          delay: 0.ms,
                          duration: 700.ms,
                          curve: Curves.easeOutBack,
                        ),

                    SizedBox(height: GR.lg),

                    // Mood label
                    Text(
                      widget.moodLabel,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: moodColor,
                        letterSpacing: -0.8,
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 150.ms, duration: 600.ms)
                        .slideY(begin: 0.3, end: 0, delay: 150.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.xs),

                    // Supportive message
                    Text(
                      _moodMessage(),
                      style: AppTextStyles.h3(context),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 250.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, delay: 250.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.xs - 2),

                    // Subtitle
                    Text(
                      _moodSubtitle(),
                      style: AppTextStyles.body(context, color: tc.textSecondary),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 350.ms, duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, delay: 350.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.lg + 2),

                    // Wellness Pulse Dot Matrix
                    if (_selectedFactors.isNotEmpty) ...[
                      _buildWellnessPulse(moodColor),
                      SizedBox(height: GR.sm),
                      Text(
                        _wellnessMessage(),
                        style: AppTextStyles.caption(context, color: tc.textSecondary),
                      )
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutCubic),
                    ],
                  ],
                ),
              ),
            ),

            // ── Divider ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Divider(height: 1, color: tc.border),
              ),
            ),

            // ── What's affecting you? ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg + 2, GR.lg, GR.md),
                child: Row(
                  children: [
                    Text(
                      'What\'s affecting you?',
                      style: AppTextStyles.h3(context),
                    ),
                    const Spacer(),
                    if (_selectedFactors.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.sm + 2, vertical: GR.xs),
                        decoration: BoxDecoration(
                          color: moodColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(GR.radiusSm),
                        ),
                        child: Text(
                          '${_selectedFactors.length} selected',
                          style: AppTextStyles.micro(context, color: moodColor, weight: FontWeight.w600),
                        ),
                      ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),

            // ── Factor chips ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Wrap(
                  spacing: GR.sm,
                  runSpacing: GR.sm,
                  children: _factors.asMap().entries.map((entry) {
                    final i = entry.key;
                    final factor = entry.value;
                    final isSelected = _selectedFactors.contains(factor['label']);
                    return GestureDetector(
                      onTap: () => _toggleFactor(factor['label'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (factor['positive'] ? tc.accent.withValues(alpha: 0.12) : tc.red.withValues(alpha: 0.08))
                              : tc.surface,
                          borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                          border: Border.all(
                            color: isSelected
                                ? (factor['positive'] ? tc.accent.withValues(alpha: 0.4) : tc.red.withValues(alpha: 0.3))
                                : tc.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              factor['icon'] as IconData,
                              size: 16,
                              color: isSelected
                                  ? (factor['positive'] ? tc.accent : tc.red)
                                  : tc.textSecondary,
                            ),
                            SizedBox(width: GR.xs + 2),
                            Text(
                              factor['label'] as String,
                              style: AppTextStyles.body(
                                context,
                                weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? (factor['positive'] ? tc.accent : tc.red)
                                    : tc.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: Duration(milliseconds: 450 + i * 50), duration: 400.ms)
                        .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 450 + i * 50), duration: 400.ms, curve: Curves.easeOutCubic);
                  }).toList(),
                ),
              ),
            ),

            // ── Tell us more ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg + 2, GR.lg, GR.md),
                child: Text(
                  _promptText(),
                  style: AppTextStyles.h3(context),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 700.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),

            // ── Text input ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Container(
                  decoration: BoxDecoration(
                    color: tc.surface,
                    borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                    border: Border.all(color: tc.border),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: tc.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Write freely... your thoughts are safe here',
                      hintStyle: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: tc.textMuted,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(GR.lg),
                    ),
                  ),
                ),
              )
                  .animate(controller: _entranceCtrl)
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0, delay: 800.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            ),

            // ── How can Matra help? ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg + 2, GR.lg, GR.md),
                child: Text(
                  'How can Matra help?',
                  style: AppTextStyles.h3(context),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 900.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 900.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),

            // ── Suggestion cards ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Column(
                  children: [
                    _buildSuggestionCard(
                      icon: Icons.self_improvement_rounded,
                      title: 'Guided Breathing',
                      subtitle: '2 minutes to calm your mind',
                      color: const Color(0xFF00BFA5),
                      delay: 950,
                      onTap: () => _showBreathingExercise(),
                    ),
                    SizedBox(height: GR.sm),
                    _buildSuggestionCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Hydration Check',
                      subtitle: 'Log water and stay refreshed',
                      color: const Color(0xFF4FC3F7),
                      delay: 1050,
                      onTap: () => _showHydrationReminder(),
                    ),
                    SizedBox(height: GR.sm),
                    _buildSuggestionCard(
                      icon: Icons.nightlight_rounded,
                      title: 'Sleep Better',
                      subtitle: 'Tips for restorative rest',
                      color: const Color(0xFF9575CD),
                      delay: 1150,
                      onTap: () => _showSleepTips(),
                    ),
                    SizedBox(height: GR.sm),
                    _buildSuggestionCard(
                      icon: Icons.medication_rounded,
                      title: 'Supplement Check',
                      subtitle: 'See your daily regimen',
                      color: tc.accent,
                      delay: 1250,
                      onTap: () => _navigateToToday(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Submit button ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.lg + 4, GR.lg, GR.xxl),
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: GR.buttonMd,
                    decoration: BoxDecoration(
                      color: _isSubmitting ? tc.border : tc.textPrimary,
                      borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? DotMatrixLoading(dotSize: 5, color: tc.cardBg)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_rounded, size: 16, color: tc.cardBg),
                                SizedBox(width: GR.sm),
                                Text(
                                  'Save & Feel Better',
                                  style: AppTextStyles.button(context, color: tc.cardBg),
                                ),
                              ],
                            ),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 1300.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 1300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Wellness Pulse Dot Matrix ─────────────────────────────────────
  Widget _buildWellnessPulse(Color moodColor) {
    final tc = ThemeColors.of(context);
    final totalDots = 24;
    final activeDots = (_wellnessScore / 100 * totalDots).round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(GR.lg),
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd + 2),
        border: Border.all(color: tc.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, size: 14, color: moodColor.withValues(alpha: 0.6)),
              SizedBox(width: GR.xs),
              Text(
                'Wellness Pulse',
                style: AppTextStyles.caption(context, weight: FontWeight.w600, color: tc.textSecondary),
              ),
            ],
          ),
          SizedBox(height: GR.md),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            alignment: WrapAlignment.center,
            children: List.generate(totalDots, (i) {
              final isActive = i < activeDots;
              final intensity = isActive ? (i / activeDots).clamp(0.3, 1.0) : 0.0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? Color.lerp(moodColor.withValues(alpha: 0.2), moodColor, intensity)
                      : tc.border,
                  borderRadius: BorderRadius.circular(3.5),
                ),
              );
            }),
          ),
          SizedBox(height: GR.sm),
          Text(
            '${_wellnessScore.toStringAsFixed(0)}%',
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: moodColor,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.0, 1.0), duration: 400.ms, curve: Curves.easeOutBack);
  }

  // ─── Suggestion Card ───────────────────────────────────────────────
  Widget _buildSuggestionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    final tc = ThemeColors.of(context);
    return GestureDetector(
      onTap: () {
        Haptics.light();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(GR.md + 2),
        decoration: BoxDecoration(
          color: tc.cardBg,
          borderRadius: BorderRadius.circular(GR.radiusMd + 2),
          border: Border.all(color: tc.border),
        ),
        child: Row(
          children: [
            Container(
              width: GR.lg + 4,
              height: GR.lg + 4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(GR.radiusSm + 2),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(width: GR.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body(context, weight: FontWeight.w600),
                  ),
                  SizedBox(height: GR.xs - 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption(context, color: tc.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.arrow_forward_rounded, size: 14, color: color),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _entranceCtrl)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: delay), duration: 400.ms, curve: Curves.easeOutCubic);
  }

  // ─── Action Handlers ───────────────────────────────────────────────
  void _showBreathingExercise() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _BreathingExerciseSheet(),
    );
  }

  void _showHydrationReminder() {
    Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Water logged! Stay hydrated.', style: TextStyle(fontFamily: 'Artific', fontSize: 13)),
        backgroundColor: const Color(0xFF4FC3F7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSleepTips() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SleepTipsSheet(),
    );
  }

  void _navigateToToday() {
    Haptics.medium();
    Navigator.pop(context);
    // The MainNavigationScreen handles tab switching via provider
  }
}

// ─── Breathing Exercise Bottom Sheet ─────────────────────────────────
class _BreathingExerciseSheet extends StatefulWidget {
  @override
  State<_BreathingExerciseSheet> createState() => _BreathingExerciseSheetState();
}

class _BreathingExerciseSheetState extends State<_BreathingExerciseSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathCtrl;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );
  }

  @override
  void dispose() {
    _breathCtrl.stop();
    _breathCtrl.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    if (_isRunning) {
      _breathCtrl.stop();
    } else {
      _breathCtrl.repeat(reverse: true);
    }
    setState(() => _isRunning = !_isRunning);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(GR.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: GR.lg),
              Text('Guided Breathing', style: AppTextStyles.h2(context)),
              SizedBox(height: GR.xs),
              Text('Breathe in as the circle expands, out as it contracts', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
              SizedBox(height: GR.xxl),
              AnimatedBuilder(
                animation: _breathCtrl,
                builder: (context, child) {
                  final scale = 0.6 + (_breathCtrl.value * 0.8);
                  return Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00BFA5).withValues(alpha: 0.08 + _breathCtrl.value * 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00BFA5).withValues(alpha: 0.2 + _breathCtrl.value * 0.4),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00BFA5).withValues(alpha: 0.15 + _breathCtrl.value * 0.25),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _isRunning ? (_breathCtrl.status == AnimationStatus.forward ? 'Inhale' : 'Exhale') : 'Tap Start',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00BFA5).withValues(alpha: 0.6 + _breathCtrl.value * 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: GR.xxl),
              GestureDetector(
                onTap: _toggleBreathing,
                child: Container(
                  width: double.infinity,
                  height: GR.buttonMd,
                  decoration: BoxDecoration(
                    color: _isRunning ? const Color(0xFFFF6B6B) : const Color(0xFF00BFA5),
                    borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                  ),
                  child: Center(
                    child: Text(
                      _isRunning ? 'Stop' : 'Start Breathing',
                      style: AppTextStyles.button(context, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sleep Tips Bottom Sheet ───────────────────────────────────────
class _SleepTipsSheet extends StatelessWidget {
  final List<Map<String, dynamic>> _tips = [
    {'icon': Icons.schedule_rounded, 'title': 'Consistent Schedule', 'desc': 'Go to bed and wake up at the same time'},
    {'icon': Icons.bedtime_rounded, 'title': 'Wind Down', 'desc': 'No screens 30 minutes before bed'},
    {'icon': Icons.coffee_rounded, 'title': 'Limit Caffeine', 'desc': 'Avoid after 2 PM for better rest'},
    {'icon': Icons.thermostat_rounded, 'title': 'Cool Room', 'desc': 'Keep bedroom at 65-68°F (18-20°C)'},
    {'icon': Icons.dark_mode_rounded, 'title': 'Dark Environment', 'desc': 'Use blackout curtains or eye mask'},
  ];

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: tc.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(GR.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2))),
              SizedBox(height: GR.lg),
              Text('Sleep Better', style: AppTextStyles.h2(context)),
              SizedBox(height: GR.xs),
              Text('Small changes for better rest', style: AppTextStyles.bodySmall(context, color: tc.textSecondary)),
              SizedBox(height: GR.lg),
              ..._tips.asMap().entries.map((entry) {
                final i = entry.key;
                final tip = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: GR.sm),
                  child: Container(
                    padding: EdgeInsets.all(GR.md + 2),
                    decoration: BoxDecoration(
                      color: tc.cardBg,
                      borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                      border: Border.all(color: tc.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: GR.lg + 2,
                          height: GR.lg + 2,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9575CD).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                          ),
                          child: Icon(tip['icon'] as IconData, size: 18, color: const Color(0xFF9575CD)),
                        ),
                        SizedBox(width: GR.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tip['title'] as String, style: AppTextStyles.body(context, weight: FontWeight.w600)),
                              SizedBox(height: GR.xs - 2),
                              Text(tip['desc'] as String, style: AppTextStyles.caption(context, color: tc.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: i * 100), duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, delay: Duration(milliseconds: i * 100), duration: 400.ms, curve: Curves.easeOutCubic);
              }),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
      ),
    );
  }
}
