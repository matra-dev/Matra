import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _remindersEnabled = true;
  bool _lowStockAlerts = true;
  bool _darkMode = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.8,
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(
                      begin: 0.2,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Customize your StackSense experience',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF999999),
                      ),
                    ).animate(delay: 80.ms).fadeIn(duration: 500.ms).slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                ),
              ),
            ),

            // Divider
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Divider(height: 1, color: Color(0xFFEEEEEE)),
              ),
            ),

            // Notifications Section
            SliverToBoxAdapter(
              child: _buildAnimatedSection(
                title: 'Notifications',
                index: 0,
                listController: _listController,
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
                                  hourMinuteShape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
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

            // Appearance Section
            SliverToBoxAdapter(
              child: _buildAnimatedSection(
                title: 'Appearance',
                index: 1,
                listController: _listController,
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

            // About Section
            SliverToBoxAdapter(
              child: _buildAnimatedSection(
                title: 'About',
                index: 2,
                listController: _listController,
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

  Widget _buildAnimatedSection({
    required String title,
    required List<Widget> children,
    required int index,
    required AnimationController listController,
  }) {
    final sectionDelay = Duration(milliseconds: 300 + (index * 150));

    return AnimatedBuilder(
      animation: listController,
      builder: (context, child) {
        final animationValue = listController.value;
        final delaySeconds = sectionDelay.inMilliseconds / 1000;
        final rawProgress = (animationValue - delaySeconds) * 2.5;
        final itemProgress = rawProgress.clamp(0.0, 1.0);
        final easedProgress = 1 - (1 - itemProgress) * (1 - itemProgress);

        return Opacity(
          opacity: easedProgress,
          child: Transform.translate(
            offset: Offset(0, (1 - easedProgress) * 16),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFAAAAAA),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
              ),
              child: Column(
                children: _addDividers(children),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _addDividers(List<Widget> children) {
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(const Padding(
          padding: EdgeInsets.only(left: 60),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ));
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.black,
            activeTrackColor: const Color(0xFF333333),
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
            const SizedBox(width: 50),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time.format(context),
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCCCCCC)),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF666666)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.2,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
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
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: const Color(0xFF666666)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCCCCCC)),
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
            fontFamily: 'PlusJakartaSans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
            letterSpacing: -0.3,
          ),
        ),
        content: const Text(
          'This feature will be available in a future update.',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
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
                fontFamily: 'PlusJakartaSans',
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
