import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';

class TimeSlotChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const TimeSlotChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
                )
              : null,
          color: isSelected ? null : const Color(0xFFF0F4F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : const Color(0xFFD0E0D0),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIcon(),
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(0.97, 0.97),
            end: const Offset(1.01, 1.01),
            duration: 200.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  IconData _getIcon() {
    switch (label) {
      case 'Morning':
        return Icons.wb_sunny_rounded;
      case 'Afternoon':
        return Icons.wb_cloudy_rounded;
      case 'Evening':
        return Icons.nights_stay_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
}

class TimeSlotSelector extends StatefulWidget {
  final List<String> selectedSlots;
  final ValueChanged<List<String>> onChanged;

  const TimeSlotSelector({
    super.key,
    required this.selectedSlots,
    required this.onChanged,
  });

  @override
  State<TimeSlotSelector> createState() => _TimeSlotSelectorState();
}

class _TimeSlotSelectorState extends State<TimeSlotSelector> {
  final List<Map<String, dynamic>> _slots = [
    {'key': 'Morning', 'color': AppColors.morning},
    {'key': 'Afternoon', 'color': AppColors.afternoon},
    {'key': 'Evening', 'color': AppColors.evening},
  ];

  void _toggleSlot(String slot) {
    final updated = List<String>.from(widget.selectedSlots);
    if (updated.contains(slot)) {
      updated.remove(slot);
    } else {
      updated.add(slot);
    }
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _slots.map((slot) {
        return TimeSlotChip(
          label: slot['key'],
          isSelected: widget.selectedSlots.contains(slot['key']),
          onTap: () => _toggleSlot(slot['key']),
          color: slot['color'],
        );
      }).toList(),
    );
  }
}
