import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';

/// Custom time picker bottom sheet with wheel-style selection.
/// Works consistently on both iOS and Android with a native feel.
class TimePickerBottomSheet extends StatefulWidget {
  final TimeOfDay initialTime;

  const TimePickerBottomSheet({
    super.key,
    required this.initialTime,
  });

  @override
  State<TimePickerBottomSheet> createState() => _TimePickerBottomSheetState();
}

class _TimePickerBottomSheetState extends State<TimePickerBottomSheet> {
  late int _selectedHour;
  late int _selectedMinute;
  late bool _isAM;

  final FixedExtentScrollController _hourCtrl = FixedExtentScrollController();
  final FixedExtentScrollController _minuteCtrl = FixedExtentScrollController();
  final FixedExtentScrollController _periodCtrl = FixedExtentScrollController();

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hourOfPeriod;
    _selectedMinute = widget.initialTime.minute;
    _isAM = widget.initialTime.period == DayPeriod.am;

    // Jump to initial positions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hourCtrl.jumpToItem(_selectedHour - 1);
      _minuteCtrl.jumpToItem(_selectedMinute);
      _periodCtrl.jumpToItem(_isAM ? 0 : 1);
    });
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    _periodCtrl.dispose();
    super.dispose();
  }

  void _onDone() {
    Haptics.success();
    final hour = _isAM ? (_selectedHour == 12 ? 0 : _selectedHour) : (_selectedHour == 12 ? 12 : _selectedHour + 12);
    Navigator.of(context).pop(TimeOfDay(hour: hour, minute: _selectedMinute));
  }

  void _onCancel() {
    Haptics.light();
    Navigator.of(context).pop();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: tc.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(GR.lg, GR.md, GR.lg, GR.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _onCancel,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.body(context, color: tc.textSecondary),
                    ),
                  ),
                  Text(
                    'Select Time',
                    style: AppTextStyles.h3(context),
                  ),
                  GestureDetector(
                    onTap: _onDone,
                    child: Text(
                      'Done',
                      style: AppTextStyles.body(context, weight: FontWeight.w600, color: tc.accent),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: tc.border),

            // Time display
            Padding(
              padding: EdgeInsets.symmetric(vertical: GR.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hour
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                      border: Border.all(color: tc.border),
                    ),
                    child: Text(
                      _selectedHour.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: GR.sm),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: tc.textMuted,
                      ),
                    ),
                  ),
                  // Minute
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                      border: Border.all(color: tc.border),
                    ),
                    child: Text(
                      _selectedMinute.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: GR.md),
                  // AM/PM
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                      border: Border.all(color: tc.border),
                    ),
                    child: Text(
                      _isAM ? 'AM' : 'PM',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: tc.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Wheel pickers
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  // Hour wheel
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _hourCtrl,
                      itemExtent: 44,
                      diameterRatio: 1.2,
                      magnification: 1.1,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        Haptics.selection();
                        setState(() => _selectedHour = index + 1);
                      },
                      children: List.generate(12, (i) {
                        final hour = i + 1;
                        final isSelected = hour == _selectedHour;
                        return Center(
                          child: Text(
                            hour.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? tc.accent : tc.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // Minute wheel
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _minuteCtrl,
                      itemExtent: 44,
                      diameterRatio: 1.2,
                      magnification: 1.1,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        Haptics.selection();
                        setState(() => _selectedMinute = index);
                      },
                      children: List.generate(60, (i) {
                        final isSelected = i == _selectedMinute;
                        return Center(
                          child: Text(
                            i.toString().padLeft(2, '0'),
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? tc.accent : tc.textSecondary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // AM/PM wheel
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: _periodCtrl,
                      itemExtent: 44,
                      diameterRatio: 1.2,
                      magnification: 1.1,
                      useMagnifier: true,
                      onSelectedItemChanged: (index) {
                        Haptics.selection();
                        setState(() => _isAM = index == 0);
                      },
                      children: ['AM', 'PM'].map((period) {
                        final isSelected = (_isAM && period == 'AM') || (!_isAM && period == 'PM');
                        return Center(
                          child: Text(
                            period,
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: isSelected ? 22 : 18,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? tc.accent : tc.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: GR.xl),
          ],
        ),
      ),
    );
  }
}

/// Helper to show the time picker bottom sheet
Future<TimeOfDay?> showTimePickerBottomSheet({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => TimePickerBottomSheet(initialTime: initialTime),
  );
}
