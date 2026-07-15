import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import '../services/local_storage_service.dart';
import 'phone_login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _entranceCtrl;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.medication_rounded,
      title: 'onboardingTrackTitle',
      description: 'onboardingTrackDesc',
      color: const Color(0xFF00BFA5),
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'onboardingRemindersTitle',
      description: 'onboardingRemindersDesc',
      color: const Color(0xFF00BFA5),
    ),
    _OnboardingPage(
      icon: Icons.trending_up_rounded,
      title: 'onboardingProgressTitle',
      description: 'onboardingProgressDesc',
      color: const Color(0xFF00BFA5),
    ),
    _OnboardingPage(
      icon: Icons.cloud_sync_rounded,
      title: 'onboardingSyncTitle',
      description: 'onboardingSyncDesc',
      color: const Color(0xFF00BFA5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    Haptics.light();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onSkip() {
    Haptics.light();
    _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await LocalStorageService().setOnboardingSeen();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(GR.lg),
                child: GestureDetector(
                  onTap: _onSkip,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodySmall(
                      context,
                      color: tc.textMuted,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  Haptics.selection();
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index], index);
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: EdgeInsets.fromLTRB(GR.lg, 0, GR.lg, GR.xxl),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        width: isActive ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: GR.xs),
                        decoration: BoxDecoration(
                          color: isActive ? tc.accent : tc.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: GR.xl),

                  // Next / Get Started button
                  GestureDetector(
                    onTap: _onNext,
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: tc.accent,
                        borderRadius: BorderRadius.circular(GR.radiusMd + 3),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? AppLocalizations.of(context)!.getStarted : AppLocalizations.of(context)!.next,
                              style: AppTextStyles.body(
                                context,
                                weight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (!isLast) ...[
                              SizedBox(width: GR.sm),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: GR.iconSm,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, int index) {
    final tc = ThemeColors.of(context);
    final isActive = index == _currentPage;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GR.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animated background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(GR.radiusLg + 8),
            ),
            child: Icon(
              page.icon,
              size: 56,
              color: page.color,
            ),
          )
              .animate(
                target: isActive ? 1 : 0,
              )
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
          SizedBox(height: GR.xl + GR.md),

          // Title
          Text(
            _resolveTitle(context, page.title),
            textAlign: TextAlign.center,
            style: AppTextStyles.h2(context),
          )
              .animate(
                target: isActive ? 1 : 0,
              )
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),
          SizedBox(height: GR.md),

          // Description
          Text(
            _resolveDesc(context, page.description),
            textAlign: TextAlign.center,
            style: AppTextStyles.body(
              context,
              color: tc.textSecondary,
            ),
          )
              .animate(
                target: isActive ? 1 : 0,
              )
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
  String _resolveTitle(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'onboardingTrackTitle':
        return l10n.onboardingTrackTitle;
      case 'onboardingRemindersTitle':
        return l10n.onboardingRemindersTitle;
      case 'onboardingProgressTitle':
        return l10n.onboardingProgressTitle;
      case 'onboardingSyncTitle':
        return l10n.onboardingSyncTitle;
      default:
        return key;
    }
  }

  String _resolveDesc(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context)!;
    switch (key) {
      case 'onboardingTrackDesc':
        return l10n.onboardingTrackDesc;
      case 'onboardingRemindersDesc':
        return l10n.onboardingRemindersDesc;
      case 'onboardingProgressDesc':
        return l10n.onboardingProgressDesc;
      case 'onboardingSyncDesc':
        return l10n.onboardingSyncDesc;
      default:
        return key;
    }
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
