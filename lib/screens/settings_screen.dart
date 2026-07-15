import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _remindersEnabled = true;
  bool _lowStockAlerts = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, GR.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: AppTextStyles.h2(context),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                    SizedBox(height: GR.xs),
                    Text(
                      'Customize your experience',
                      style: AppTextStyles.bodySmall(context),
                    ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Notifications',
                delay: 200,
                children: [
                  _buildToggleTile(
                    icon: Icons.notifications_outlined,
                    title: 'Daily Reminders',
                    subtitle: 'Get reminded to take your supplements',
                    value: _remindersEnabled,
                    onChanged: (v) {
                      Haptics.light();
                      setState(() => _remindersEnabled = v);
                    },
                  ),
                  if (_remindersEnabled)
                    _buildTimePickerTile(
                      title: 'Reminder Time',
                      time: _reminderTime,
                      onTap: () async {
                        Haptics.light();
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _reminderTime,
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                timePickerTheme: TimePickerThemeData(
                                  backgroundColor: tc.cardBg,
                                  dialBackgroundColor: tc.surface,
                                  dialTextColor: tc.textPrimary,
                                  hourMinuteTextColor: tc.textPrimary,
                                  dayPeriodTextColor: tc.textPrimary,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() => _reminderTime = picked);
                        }
                      },
                    ),
                  _buildToggleTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Low Stock Alerts',
                    subtitle: 'Warn when supplements run low',
                    value: _lowStockAlerts,
                    onChanged: (v) {
                      Haptics.light();
                      setState(() => _lowStockAlerts = v);
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Language',
                delay: 250,
                children: [
                  _buildLanguageTile(context),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Accessibility',
                delay: 275,
                children: [
                  _buildFontSizeTile(context),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Appearance',
                delay: 300,
                children: [
                  _buildToggleTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to dark theme',
                    value: isDark,
                    onChanged: (v) {
                      Haptics.light();
                      ref.read(darkModeProvider.notifier).setDarkMode(v);
                    },
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'About',
                delay: 400,
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    value: '1.0.0',
                  ),
                  _buildInfoTile(
                    icon: Icons.code_outlined,
                    title: 'Build',
                    value: '2024.12.1',
                  ),
                  _buildActionTile(
                    icon: Icons.description_outlined,
                    title: 'Privacy Policy',
                    onTap: () {
                      Haptics.light();
                      _showComingSoon(context);
                    },
                  ),
                  // Help & Support — static, no onTap
                  _buildInfoTile(
                    icon: Icons.support_agent_outlined,
                    title: 'Help & Support',
                    value: '',
                  ),
                ],
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required int delay,
  }) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(GR.lg, GR.lg, GR.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.caption(context),
          ).animate(delay: delay.ms).fadeIn(duration: 300.ms),
          SizedBox(height: GR.sm),
          Container(
            decoration: BoxDecoration(
              color: tc.cardBg,
              borderRadius: BorderRadius.circular(GR.radiusLg - 1),
              border: Border.all(color: tc.border),
            ),
            child: Column(
              children: _addDividers(children),
            ),
          ).animate(delay: (delay + 50).ms).fadeIn(duration: 400.ms).slideY(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    final tc = ThemeColors.of(context);
    final currentLocale = ref.watch(localeProvider);
    
    final languages = {
      'en': 'English',
      'es': 'Español',
      'hi': 'हिन्दी',
      'fr': 'Français',
    };
    
    final currentLanguage = languages[currentLocale.languageCode] ?? 'English';

    return GestureDetector(
      onTap: () => _showLanguagePicker(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
        child: Row(
          children: [
            Icon(Icons.language_rounded, size: GR.iconSm, color: tc.textSecondary),
            SizedBox(width: GR.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: AppTextStyles.body(context, weight: FontWeight.w500),
                  ),
                  SizedBox(height: GR.xs - 2),
                  Text(
                    currentLanguage,
                    style: AppTextStyles.caption(context, color: tc.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: tc.textMuted),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    Haptics.medium();
    final tc = ThemeColors.of(context);
    final currentLocale = ref.read(localeProvider);
    
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'fr', 'name': 'French', 'native': 'Français'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: GR.md),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(GR.lg),
                child: Text('Select Language', style: AppTextStyles.h3(context)),
              ),
              ...languages.map((lang) {
                final isSelected = lang['code'] == currentLocale.languageCode;
                return GestureDetector(
                  onTap: () {
                    Haptics.success();
                    ref.read(localeProvider.notifier).setLocale(lang['code']!);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                    decoration: BoxDecoration(
                      color: isSelected ? tc.accent.withValues(alpha: 0.08) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['native']!,
                                style: AppTextStyles.body(
                                  context,
                                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                lang['name']!,
                                style: AppTextStyles.caption(context, color: tc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_rounded, size: 18, color: tc.accent),
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: GR.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeTile(BuildContext context) {
    final tc = ThemeColors.of(context);
    final currentLevel = ref.watch(fontSizeProvider);
    
    final levels = [
      {'level': FontSizeLevel.small, 'label': 'Small', 'sample': 'Aa'},
      {'level': FontSizeLevel.normal, 'label': 'Normal', 'sample': 'Aa'},
      {'level': FontSizeLevel.large, 'label': 'Large', 'sample': 'Aa'},
      {'level': FontSizeLevel.huge, 'label': 'Huge', 'sample': 'Aa'},
    ];

    return GestureDetector(
      onTap: () => _showFontSizePicker(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
        child: Row(
          children: [
            Icon(Icons.format_size_rounded, size: GR.iconSm, color: tc.textSecondary),
            SizedBox(width: GR.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Text Size',
                    style: AppTextStyles.body(context, weight: FontWeight.w500),
                  ),
                  SizedBox(height: GR.xs - 2),
                  Text(
                    currentLevel.label,
                    style: AppTextStyles.caption(context, color: tc.textSecondary),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: levels.map((l) {
                final isSelected = l['level'] == currentLevel;
                final level = l['level'] as FontSizeLevel;
                return Container(
                  width: 28,
                  height: 28,
                  margin: EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? tc.accent.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? tc.accent : tc.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      l['sample']! as String,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 10 * level.scale,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? tc.accent : tc.textMuted,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(width: GR.xs),
            Icon(Icons.chevron_right_rounded, size: 20, color: tc.textMuted),
          ],
        ),
      ),
    );
  }

  void _showFontSizePicker(BuildContext context) {
    Haptics.medium();
    final tc = ThemeColors.of(context);
    final currentLevel = ref.read(fontSizeProvider);
    
    final levels = [
      {'level': FontSizeLevel.small, 'label': 'Small', 'desc': 'Compact text for more content', 'sample': 'Aa'},
      {'level': FontSizeLevel.normal, 'label': 'Normal', 'desc': 'Standard readable size', 'sample': 'Aa'},
      {'level': FontSizeLevel.large, 'label': 'Large', 'desc': 'Easier to read', 'sample': 'Aa'},
      {'level': FontSizeLevel.huge, 'label': 'Huge', 'desc': 'Maximum readability', 'sample': 'Aa'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: GR.md),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(GR.lg),
                child: Text('Text Size', style: AppTextStyles.h3(context)),
              ),
              ...levels.map((l) {
                final level = l['level'] as FontSizeLevel;
                final isSelected = level == currentLevel;
                final label = l['label'] as String;
                final desc = l['desc'] as String;
                return GestureDetector(
                  onTap: () {
                    Haptics.success();
                    ref.read(fontSizeProvider.notifier).setLevel(level);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                    decoration: BoxDecoration(
                      color: isSelected ? tc.accent.withValues(alpha: 0.08) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: AppTextStyles.body(
                                  context,
                                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                desc,
                                style: AppTextStyles.caption(context, color: tc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected ? tc.accent.withValues(alpha: 0.15) : tc.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? tc.accent : tc.border,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Aa',
                              style: TextStyle(
                                fontFamily: 'Artific',
                                fontSize: 14 * level.scale,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? tc.accent : tc.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        if (isSelected) ...[
                          SizedBox(width: GR.sm),
                          Icon(Icons.check_rounded, size: 18, color: tc.accent),
                        ],
                      ],
                    ),
                  ),
                );
              }),
              SizedBox(height: GR.xl),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _addDividers(List<Widget> children) {
    final tc = ThemeColors.of(context);
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(Divider(height: 1, indent: 56, color: tc.divider));
      }
    }
    return result;
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
      child: Row(
        children: [
          Container(
            width: GR.lg + 2,
            height: GR.lg + 2,
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
            ),
            child: Icon(icon, size: GR.iconSm - 2, color: tc.textSecondary),
          ),
          SizedBox(width: GR.md - 2),
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
                  style: AppTextStyles.bodySmall(context),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: tc.textPrimary,
            activeTrackColor: tc.border,
            inactiveThumbColor: tc.cardBg,
            inactiveTrackColor: tc.borderLight,
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final tc = ThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
        child: Row(
          children: [
            SizedBox(width: GR.lg + 2 + GR.md - 2),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body(context),
              ),
            ),
            Text(
              time.format(context),
              style: AppTextStyles.body(context, weight: FontWeight.w600, color: tc.textSecondary),
            ),
            SizedBox(width: GR.xs - 2),
            Icon(Icons.chevron_right, size: 18, color: tc.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    final tc = ThemeColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
      child: Row(
        children: [
          Container(
            width: GR.lg + 2,
            height: GR.lg + 2,
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
            ),
            child: Icon(icon, size: GR.iconSm - 2, color: tc.textSecondary),
          ),
          SizedBox(width: GR.md - 2),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body(context),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: AppTextStyles.bodySmall(context),
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final tc = ThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 2),
        child: Row(
          children: [
            Container(
              width: GR.lg + 2,
              height: GR.lg + 2,
              decoration: BoxDecoration(
                color: tc.surface,
                borderRadius: BorderRadius.circular(GR.radiusSm + 2),
              ),
              child: Icon(icon, size: GR.iconSm - 2, color: tc.textSecondary),
            ),
            SizedBox(width: GR.md - 2),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body(context),
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: tc.textMuted),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    final tc = ThemeColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: tc.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GR.radiusLg)),
        title: Text(
          'Coming Soon',
          style: AppTextStyles.h2(context),
        ),
        content: Text(
          'This feature will be available in a future update.',
          style: AppTextStyles.bodySmall(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: AppTextStyles.body(context, weight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
