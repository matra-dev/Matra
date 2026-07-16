import '../widgets/dot_matrix_loading.dart';import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/supplement_model.dart';
import '../providers/app_provider.dart';
import '../utils/haptics.dart';
import '../utils/app_date_utils.dart' as app_date;
import '../theme/app_text_styles.dart';

class SupplementFormScreen extends ConsumerStatefulWidget {
  final Supplement? supplement;

  const SupplementFormScreen({super.key, this.supplement});

  @override
  ConsumerState<SupplementFormScreen> createState() => _SupplementFormScreenState();
}

class _SupplementFormScreenState extends ConsumerState<SupplementFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _stockController = TextEditingController();

  String _dosageUnit = 'mg';
  List<String> _timeSlots = [];
  bool _isSubmitting = false;

  final List<String> _dosageUnits = ['mg', 'mcg', 'IU', 'g', 'ml'];

  late final AnimationController _pageController;

  bool get _isEdit => widget.supplement != null;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (_isEdit) {
      final s = widget.supplement!;
      _nameController.text = s.name;
      _dosageController.text = s.dosageAmount.toString();
      _dosageUnit = s.dosageUnit;
      _frequencyController.text = s.frequency.toString();
      _stockController.text = s.stockCount.toString();
      _timeSlots = List<String>.from(s.timeSlots);
    } else {
      _frequencyController.text = '1';
      _stockController.text = '30';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.forward();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _stockController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      Haptics.error();
      return;
    }

    if (_timeSlots.isEmpty) {
      Haptics.error();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one time slot'),
          backgroundColor: ThemeColors.of(context).red,
        ),
      );
      return;
    }

    Haptics.success();
    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        await ref.read(supplementsProvider.notifier).updateSupplement(
              widget.supplement!.id,
              {
                'name': _nameController.text.trim(),
                'dosage_amount': double.parse(_dosageController.text),
                'dosage_unit': _dosageUnit,
                'frequency': int.parse(_frequencyController.text),
                'stock_count': int.parse(_stockController.text),
                'time_slots': _timeSlots,
              },
            );
      } else {
        final newSupplement = Supplement(
          id: const Uuid().v4(),
          name: _nameController.text.trim(),
          dosageAmount: double.parse(_dosageController.text),
          dosageUnit: _dosageUnit,
          frequency: int.parse(_frequencyController.text),
          stockCount: int.parse(_stockController.text),
          timeSlots: _timeSlots,
          startDate: app_date.DateUtils.getTodayDateString(),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        );
        await ref.read(supplementsProvider.notifier).addSupplement(newSupplement);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: ThemeColors.of(context).red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close_rounded, size: 24, color: tc.textPrimary),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _isEdit ? 'Edit Supplement' : 'Add Supplement',
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: tc.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Name
                    _buildLabel('Name'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'Vitamin C',
                      prefixIcon: Icons.medication_rounded,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      delay: 100,
                    ),

                    const SizedBox(height: 20),

                    // Dosage
                    _buildLabel('Dosage'),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            controller: _dosageController,
                            hint: '1000.0',
                            prefixIcon: Icons.scale_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final n = double.tryParse(v);
                              if (n == null || n <= 0) return 'Invalid';
                              return null;
                            },
                            delay: 200,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildDosageDropdown(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Times/Day + In Stock
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Times/Day'),
                              _buildTextField(
                                controller: _frequencyController,
                                hint: '2',
                                prefixIcon: Icons.repeat_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 1) return 'Invalid';
                                  return null;
                                },
                                delay: 300,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('In Stock'),
                              _buildTextField(
                                controller: _stockController,
                                hint: '30',
                                prefixIcon: Icons.inventory_2_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  final n = int.tryParse(v);
                                  if (n == null || n < 0) return 'Invalid';
                                  return null;
                                },
                                delay: 350,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Time Slots
                    _buildLabel('Time Slots'),
                    const SizedBox(height: 10),
                    _TimeSlotRow(
                      selectedSlots: _timeSlots,
                      onToggle: (slot) {
                        Haptics.selection();
                        setState(() {
                          if (_timeSlots.contains(slot)) {
                            _timeSlots.remove(slot);
                          } else {
                            _timeSlots.add(slot);
                          }
                        });
                      },
                    )
                        .animate(controller: _pageController)
                        .fadeIn(delay: 400.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 32),

                    // Save button
                    GestureDetector(
                      onTap: _isSubmitting ? null : _submit,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: tc.textPrimary,
                          borderRadius: BorderRadius.circular(26),
                        ),
                        child: _isSubmitting
                            ? Center(
                                child: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: DotMatrixLoading(
                                    dotSize: 4,
                                    color: tc.cardBg,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isEdit ? Icons.save_rounded : Icons.add_rounded,
                                    color: tc.cardBg,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isEdit ? 'Save Changes' : 'Add to Stack',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      color: tc.cardBg,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    )
                        .animate(controller: _pageController)
                        .fadeIn(delay: 500.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Artific',
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ThemeColors.of(context).textMuted,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    required int delay,
  }) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final v = _pageController.value;
        final d = delay / 1000;
        final p = ((v - d) * 3.0).clamp(0.0, 1.0);
        final e = 1 - (1 - p) * (1 - p);
        return Opacity(
          opacity: e,
          child: Transform.translate(offset: Offset(0, (1 - e) * 12), child: child),
        );
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: ThemeColors.of(context).surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: hint == 'Vitamin C' ? TextCapitalization.words : TextCapitalization.none,
          style: TextStyle(
            fontFamily: 'Artific',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: ThemeColors.of(context).textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Artific',
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: ThemeColors.of(context).textMuted,
            ),
            prefixIcon: Icon(prefixIcon, size: 20, color: ThemeColors.of(context).textSecondary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildDosageDropdown() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        final v = _pageController.value;
        final p = ((v - 0.25) * 3.0).clamp(0.0, 1.0);
        final e = 1 - (1 - p) * (1 - p);
        return Opacity(
          opacity: e,
          child: Transform.translate(offset: Offset(0, (1 - e) * 12), child: child),
        );
      },
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: ThemeColors.of(context).surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _dosageUnit,
            isExpanded: true,
            icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ThemeColors.of(context).textSecondary),
            borderRadius: BorderRadius.circular(16),
            style: TextStyle(
              fontFamily: 'Artific',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ThemeColors.of(context).textPrimary,
            ),
            items: _dosageUnits.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                Haptics.selection();
                setState(() => _dosageUnit = value);
              }
            },
          ),
        ),
      ),
    );
  }
}

// ─── Time Slot Row (matches screenshot) ───
class _TimeSlotRow extends StatelessWidget {
  final List<String> selectedSlots;
  final ValueChanged<String> onToggle;

  const _TimeSlotRow({
    required this.selectedSlots,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final slots = [
      _SlotData(
        label: 'Morning',
        icon: Icons.wb_sunny_rounded,
        activeColor: tc.orange,
        activeBg: tc.orangeLight,
      ),
      _SlotData(
        label: 'Afternoon',
        icon: Icons.wb_cloudy_rounded,
        activeColor: tc.blue,
        activeBg: tc.blueLight,
      ),
      _SlotData(
        label: 'Evening',
        icon: Icons.nights_stay_rounded,
        activeColor: tc.purple,
        activeBg: tc.purpleLight,
      ),
    ];

    return Row(
      children: slots.map((slot) {
        final isSelected = selectedSlots.contains(slot.label);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onToggle(slot.label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected ? slot.activeColor : tc.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      slot.icon,
                      size: 16,
                      color: isSelected ? tc.cardBg : tc.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slot.label,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? tc.cardBg : tc.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SlotData {
  final String label;
  final IconData icon;
  final Color activeColor;
  final Color activeBg;

  _SlotData({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.activeBg,
  });
}
