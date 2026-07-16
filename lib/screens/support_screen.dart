import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

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
    _entranceCtrl.stop();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _showFontSizePicker() {
    Haptics.medium();
    final currentLevel = ref.read(fontSizeProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tc = ThemeColors.of(context);
        return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: GR.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(GR.lg),
                child: Text(
                  'Text Size',
                  style: AppTextStyles.h2(context),
                ),
              ),
              ...FontSizeLevel.values.map((level) {
                final isSelected = currentLevel == level;
                return GestureDetector(
                  onTap: () {
                    Haptics.selection();
                    ref.read(fontSizeProvider.notifier).setLevel(level);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.xs),
                    padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 3),
                    decoration: BoxDecoration(
                      color: isSelected ? tc.accentLight.withValues(alpha: 0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                      border: Border.all(
                        color: isSelected ? tc.accent : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                level.label,
                                style: AppTextStyles.body(
                                  context,
                                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? tc.accentDark : tc.textPrimary,
                                ),
                              ),
                              SizedBox(height: GR.xs),
                              Text(
                                _getFontSizeDescription(level),
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: tc.accent, size: GR.iconSm),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
        );
      },
    );
  }

  String _getFontSizeDescription(FontSizeLevel level) {
    switch (level) {
      case FontSizeLevel.small:
        return 'Smaller text, more content fits on screen';
      case FontSizeLevel.normal:
        return 'Standard text size, balanced readability';
      case FontSizeLevel.large:
        return 'Larger text, easier to read';
      case FontSizeLevel.huge:
        return 'Extra large text, maximum readability';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: GR.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: GR.sm),

                // Header
                Row(
                  children: [
                    Text(
                      'Support',
                      style: AppTextStyles.h1(context),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(Icons.add_rounded, size: GR.iconSm, color: tc.textPrimary),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl),

                // Text Size Setting Card
                _SupportCard(
                  title: 'Text Size',
                  description: 'Adjust the text size to make reading easier for you.',
                  icon: Icons.format_size_rounded,
                  iconBg: tc.blue.withValues(alpha: 0.1),
                  iconColor: tc.blue,
                  delay: 50,
                  controller: _entranceCtrl,
                  onTap: _showFontSizePicker,
                  trailing: Consumer(
                    builder: (context, ref, _) {
                      final level = ref.watch(fontSizeProvider);
                      return Text(
                        level.label,
                        style: AppTextStyles.caption(context, color: tc.accentDark),
                      );
                    },
                  ),
                ),

                SizedBox(height: GR.md),

                // Beta Access Card
                _SupportCard(
                  title: 'Get Beta Access',
                  description: 'Get early access to new features before they\'re released. Try updates first, share your feedback, and help shape the future of the app.',
                  icon: Icons.rocket_launch_rounded,
                  iconBg: tc.orange.withValues(alpha: 0.1),
                  iconColor: tc.orange,
                  delay: 100,
                  controller: _entranceCtrl,
                  onTap: () => Haptics.medium(),
                ),

                SizedBox(height: GR.md),

                // Divider
                Divider(height: 1, color: tc.border)
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                SizedBox(height: GR.md),

                // Matra Team Card
                _SupportCard(
                  title: 'Matra Team',
                  description: 'Need help or experienced an issue? We are here to support you. Reach out to our team for assistance.',
                  icon: Icons.support_agent_rounded,
                  iconBg: tc.accentLight.withValues(alpha: 0.4),
                  iconColor: tc.accentDark,
                  delay: 300,
                  controller: _entranceCtrl,
                  onTap: () => Haptics.medium(),
                ),

                SizedBox(height: GR.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int delay;
  final AnimationController controller;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SupportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.delay,
    required this.controller,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GoldenCard(
        padding: EdgeInsets.all(GR.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: GR.lg + 2,
              height: GR.lg + 2,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(GR.radiusMd),
              ),
              child: Icon(icon, size: GR.iconSm, color: iconColor),
            ),
            SizedBox(width: GR.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.h3(context, weight: FontWeight.w800),
                      ),
                      if (trailing != null) ...[
                        const Spacer(),
                        trailing!,
                      ],
                    ],
                  ),
                  SizedBox(height: GR.xs),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall(context, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(controller: controller)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
