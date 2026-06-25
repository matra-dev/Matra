import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';

// ─── Light Mode Palette ──────────────────────────────────────────────────────
const _bg = Color(0xFFFAFAFA);
const _cardBg = Color(0xFFFFFFFF);
const _cardBorder = Color(0xFFE8E8E8);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF6B7280);
const _textMuted = Color(0xFF9CA3AF);
const _accent = Color(0xFF00BFA5);
const _accentLight = Color(0xFFB8E0D2);
const _accentDark = Color(0xFF00897B);
const _orange = Color(0xFFFFA726);
const _blue = Color(0xFF448AFF);
const _purple = Color(0xFF7E57C2);
const _red = Color(0xFFEF5350);

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
              primary: _accentDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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
              primary: _accentDark,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: _textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _showDoctorPicker() {
    Haptics.medium();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Select Healthcare Professional',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
              ),
              ..._doctors.map((doc) {
                return ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _accentLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_rounded, color: _accentDark),
                  ),
                  title: Text(
                    doc['name']!,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    doc['specialty']!,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      color: _textSecondary,
                    ),
                  ),
                  trailing: _selectedDoctor == doc['name']
                      ? const Icon(Icons.check_circle_rounded, color: _accent)
                      : null,
                  onTap: () {
                    Haptics.success();
                    setState(() => _selectedDoctor = doc['name']);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAppointment() {
    Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Appointment saved successfully!',
          style: TextStyle(fontFamily: 'Artific'),
        ),
        backgroundColor: _accentDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFormValid = _selectedDoctor != null;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // ── Header ───────────────────────────────────────────
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'New Appointment',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 50),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                // ── Date & Time Fields ───────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _cardBorder),
                  ),
                  child: Column(
                    children: [
                      _FieldRow(
                        label: 'Date',
                        value: _formatDate(_selectedDate),
                        onTap: _pickDate,
                        delay: 100,
                        controller: _entranceCtrl,
                      ),
                      const Divider(height: 1, indent: 20, color: _cardBorder),
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

                const SizedBox(height: 24),

                // ── Doctor Selector ──────────────────────────────────
                GestureDetector(
                  onTap: _showDoctorPicker,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _selectedDoctor == null ? _cardBorder : _accentLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _selectedDoctor == null
                              ? const Text(
                                  'Select healthcare professional ...',
                                  style: TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: _accentDark,
                                  ),
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedDoctor!,
                                      style: const TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: _textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _doctors.firstWhere((d) => d['name'] == _selectedDoctor)['specialty']!,
                                      style: const TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 13,
                                        color: _textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _textMuted,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 300.ms, duration: 600.ms)
                    .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),

                // ── Reminders Section ────────────────────────────────
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 400.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 10),

                Text(
                  'Two default reminders have been automatically set for your appointment: one for 6 PM the day before, and the other 2 hours before the appointment.',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _textSecondary,
                    height: 1.6,
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 40),

                // ── Save Button ──────────────────────────────────────
                GestureDetector(
                  onTap: isFormValid ? _saveAppointment : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isFormValid ? _accentDark : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isFormValid ? Colors.white : _textMuted,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Field Row ───────────────────────────────────────────────────────────────
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
