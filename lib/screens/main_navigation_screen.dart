import 'package:flutter/material.dart';
import '../utils/haptics.dart';
import '../theme/golden_ratio.dart';
import 'today_screen.dart';
import 'insights_screen.dart';
import 'treatment_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    InsightsScreen(),
    TreatmentScreen(),
    SettingsScreen(),
  ];

  final List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.check_circle_outlined,
      activeIcon: Icons.check_circle_rounded,
      label: 'Today',
    ),
    _NavItemData(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Insights',
    ),
    _NavItemData(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication_rounded,
      label: 'Treatment',
    ),
    _NavItemData(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  void _onTap(int index) {
    if (index != _currentIndex) {
      Haptics.light();
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          AnimatedSwitcher(
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
              key: ValueKey<int>(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(GR.xl + 26, 0, GR.xl + 20, GR.md + 2),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(_items.length, (index) {
                        final item = _items[index];
                        final isSelected = _currentIndex == index;

                        return GestureDetector(
                          onTap: () => _onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                            margin: EdgeInsets.symmetric(
                              horizontal: isSelected ? 4 : 2,
                              vertical: 8,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: isSelected ? 14 : 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, animation) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    key: ValueKey(isSelected),
                                    size: 22,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textMuted,
                                  ),
                                ),
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 350),
                                  curve: Curves.easeOutCubic,
                                  child: isSelected
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 6),
                                          child: Text(
                                            item.label,
                                            style: const TextStyle(
                                              fontFamily: 'Artific',
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
