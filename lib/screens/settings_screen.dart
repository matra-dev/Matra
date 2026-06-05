import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _remindersEnabled = true;
  bool _lowStockAlerts = true;
  bool _darkMode = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                    const SizedBox(height: 4),
                    const Text(
                      'Customize your StackSense experience',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF999999),
                      ),
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
                                timePickerTheme: const TimePickerThemeData(
                                  backgroundColor: Colors.white,
                                  dialBackgroundColor: Color(0xFFF5F5F5),
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
                    value: _darkMode,
                    onChanged: (v) {
                      Haptics.light();
                      setState(() => _darkMode = v);
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
                  _buildActionTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Haptics.light();
                      _showComingSoon(context);
                    },
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Artific',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF999999),
              letterSpacing: 1.2,
            ),
          ).animate(delay: delay.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
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
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const Divider(height: 1, indent: 56, color: Color(0xFFEEEEEE)));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            activeTrackColor: const Color(0xFFCCCCCC),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFDDDDDD),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 44),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Text(
              time.format(context),
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Artific',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF999999),
            ),
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: const Color(0xFF666666)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Coming Soon',
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        content: const Text(
          'This feature will be available in a future update.',
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
