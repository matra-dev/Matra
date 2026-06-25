import 'package:flutter/material.dart';
import '../utils/haptics.dart';
import '../theme/golden_ratio.dart';
import 'today_screen.dart';
import 'progress_screen.dart';
import 'support_screen.dart';
import 'treatment_screen.dart';
import 'appointment_screen.dart';
import 'add_medication_screen.dart';
import 'measurement_list_screen.dart';
import 'metric_detail_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    TodayScreen(),
    ProgressScreen(),
    MetricDetailScreen(),
    SupportScreen(),
    TreatmentScreen(),
    AppointmentScreen(),
    AddMedicationScreen(),
    MeasurementListScreen(),
  ];

  final List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.check_circle_outlined,
      activeIcon: Icons.check_circle_rounded,
      label: 'Today',
    ),
    _NavItemData(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Progress',
    ),
    _NavItemData(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Insights',
    ),
    _NavItemData(
      icon: Icons.medical_services_outlined,
      activeIcon: Icons.medical_services_rounded,
      label: 'Support',
    ),
    _NavItemData(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication_rounded,
      label: 'Treatment',
    ),
    _NavItemData(
      icon: Icons.calendar_today_outlined,
      activeIcon: Icons.calendar_today_rounded,
      label: 'Appt',
    ),
    _NavItemData(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle_rounded,
      label: 'Add Med',
    ),
    _NavItemData(
      icon: Icons.format_list_bulleted_outlined,
      activeIcon: Icons.format_list_bulleted_rounded,
      label: 'Measures',
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
                padding: EdgeInsets.fromLTRB(GR.base * 2, 0, GR.base * 2, GR.sm),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(GR.radiusLg),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 24,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(GR.radiusLg),
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(GR.radiusMd),
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
                                    size: GR.iconSm,
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
                                              const EdgeInsets.only(left: 4),
                                          child: Text(
                                            item.label,
                                            style: TextStyle(
                                              fontFamily: 'Artific',
                                              fontSize: GR.textXs,
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
