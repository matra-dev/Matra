import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../models/supplement_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/haptics.dart';
import '../utils/app_date_utils.dart' as app_date;
import '../widgets/time_slot_chip.dart';

class SupplementFormScreen extends ConsumerStatefulWidget {
  final Supplement? supplement;

  const SupplementFormScreen({super.key, this.supplement});

  @override
  ConsumerState<SupplementFormScreen> createState() => _SupplementFormScreenState();
}

class _SupplementFormScreenState extends ConsumerState<SupplementFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _frequencyController = TextEditingController();
  final _stockController = TextEditingController();

  String _dosageUnit = 'mg';
  List<String> _timeSlots = [];
  bool _isSubmitting = false;

  final List<String> _dosageUnits = ['mg', 'mcg', 'IU', 'g', 'ml'];

  bool get _isEdit => widget.supplement != null;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _stockController.dispose();
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
        const SnackBar(content: Text('Please select at least one time slot'), backgroundColor: AppColors.danger),
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
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text(
          _isEdit ? 'Edit Supplement' : 'Add to Stack',
          style: const TextStyle(fontFamily: 'Artific', fontSize: 17, fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionTitle('Name'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Vitamin D3',
                  prefixIcon: Icon(Icons.medication_rounded, size: 20),
                ),
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(fontFamily: 'Artific', fontSize: 14),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a name';
                  return null;
                },
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              _buildSectionTitle('Dosage'),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _dosageController,
                      decoration: const InputDecoration(
                        hintText: 'Amount',
                        prefixIcon: Icon(Icons.scale_rounded, size: 20),
                      ),
                      style: const TextStyle(fontFamily: 'Artific', fontSize: 14),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Required';
                        final num = double.tryParse(value);
                        if (num == null || num <= 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _dosageUnit,
                          isExpanded: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: BorderRadius.circular(16),
                          style: const TextStyle(fontFamily: 'Artific', fontSize: 14, color: Colors.black),
                          items: _dosageUnits.map((unit) {
                            return DropdownMenuItem(value: unit, child: Text(unit));
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
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Times/Day'),
                        TextFormField(
                          controller: _frequencyController,
                          decoration: const InputDecoration(
                            hintText: '1',
                            prefixIcon: Icon(Icons.repeat_rounded, size: 20),
                          ),
                          style: const TextStyle(fontFamily: 'Artific', fontSize: 14),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final num = int.tryParse(value);
                            if (num == null || num < 1) return 'Invalid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('In Stock'),
                        TextFormField(
                          controller: _stockController,
                          decoration: const InputDecoration(
                            hintText: '30',
                            prefixIcon: Icon(Icons.inventory_2_rounded, size: 20),
                          ),
                          style: const TextStyle(fontFamily: 'Artific', fontSize: 14),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            final num = int.tryParse(value);
                            if (num == null || num < 0) return 'Invalid';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

              const SizedBox(height: 20),

              _buildSectionTitle('Time Slots'),
              TimeSlotSelector(
                selectedSlots: _timeSlots,
                onChanged: (slots) {
                  Haptics.selection();
                  setState(() => _timeSlots = slots);
                },
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: _isSubmitting ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isEdit ? Icons.save_rounded : Icons.add_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isEdit ? 'Save Changes' : 'Add to Stack',
                              style: const TextStyle(
                                fontFamily: 'Artific',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Artific',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF999999),
        ),
      ),
    );
  }
}
