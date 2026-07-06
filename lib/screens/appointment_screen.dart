import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  DateTime _selectedDate = DateTime(2026, 6, 26);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String? _selectedDoctor;

  final List<Map<String, String>> _doctors = [
    {'name': 'Dr. Sarah Chen', 'specialty': 'General Practitioner'},
    {'name': 'Dr. Michael Ross', 'specialty': 'Cardiologist'},
    {'name': 'Dr. Emily Watson', 'specialty': 'Nutritionist'},
    {'name': 'Dr. James Liu', 'specialty': 'Endocrinologist'},
  ];

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickDate() async {
    Haptics.light();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    Haptics.light();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.accentDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _showDoctorPicker() {
    final tc = ThemeColors.of(context);
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                  'Select Healthcare Professional',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary,
                  ),
                ),
              ),
              ..._doctors.map((doc) {
                return ListTile(
                  leading: Container(
                    width: GR.lg + 2,
                    height: GR.lg + 2,
                    decoration: BoxDecoration(
                      color: tc.accentLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                    ),
                    child: Icon(Icons.person_rounded, color: tc.accentDark, size: 20),
                  ),
                  title: Text(
                    doc['name']!,
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontWeight: FontWeight.w700,
                      color: tc.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    doc['specialty']!,
                    style: TextStyle(
                      fontFamily: 'Artific',
                      color: tc.textSecondary,
                    ),
                  ),
                  trailing: _selectedDoctor == doc['name']
                      ? Icon(Icons.check_circle_rounded, color: tc.accent)
                      : null,
                  onTap: () {
                    Haptics.success();
                    setState(() => _selectedDoctor = doc['name']);
                    Navigator.pop(context);
                  },
                );
              }),
              SizedBox(height: GR.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAppointment() {
    final tc = ThemeColors.of(context);
    Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Appointment saved successfully!',
          style: TextStyle(fontFamily: 'Artific'),
        ),
        backgroundColor: tc.accentDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GR.radiusMd)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final isFormValid = _selectedDoctor != null;

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
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: tc.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'New Appointment',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: tc.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(width: 50),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl),

                // Date & Time Fields
                GoldenCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _FieldRow(
                        label: 'Date',
                        value: _formatDate(_selectedDate),
                        onTap: _pickDate,
                        delay: 100,
                        controller: _entranceCtrl,
                      ),
                      Divider(height: 1, indent: GR.lg, color: tc.border),
                      _FieldRow(
                        label: 'Time',
                        value: _formatTime(_selectedTime),
                        onTap: _pickTime,
                        delay: 200,
                        controller: _entranceCtrl,
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 100.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.lg),

                // Doctor Selector
                GestureDetector(
                  onTap: _showDoctorPicker,
                  child: GoldenCard(
                    padding: EdgeInsets.all(GR.lg),
                    border: Border.all(
                      color: _selectedDoctor == null ? tc.border : tc.accentLight,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _selectedDoctor == null
                              ? Text(
                                  'Select healthcare professional ...',
                                  style: TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: tc.accentDark,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDoctor!,
                                      style: TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: tc.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: GR.xs),
                                    Text(
                                      _doctors.firstWhere((d) => d['name'] == _selectedDoctor)['specialty']!,
                                      style: TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 14,
                                        color: tc.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: tc.textMuted),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xl),

                // Reminders Section
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: tc.textPrimary,
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.md),

                Text(
                  'Two default reminders have been automatically set for your appointment: one for 6 PM the day before, and the other 2 hours before the appointment.',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: tc.textSecondary,
                    height: 1.6,
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.xxl),

                // Save Button
                GestureDetector(
                  onTap: isFormValid ? _saveAppointment : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: GR.buttonMd,
                    decoration: BoxDecoration(
                      color: isFormValid ? tc.accentDark : tc.borderLight,
                      borderRadius: BorderRadius.circular(GR.radiusMd),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isFormValid ? Colors.white : tc.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                SizedBox(height: GR.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final int delay;
  final AnimationController controller;

  const _FieldRow({
    required this.label,
    required this.value,
    required this.onTap,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md + 3),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: tc.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: tc.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
