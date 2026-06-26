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
