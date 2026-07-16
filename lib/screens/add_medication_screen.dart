import '../widgets/time_picker_bottom_sheet.dart';import '../widgets/dot_matrix_loading.dart';import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import '../services/medication_search_service.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;
  final _nameController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  int _currentStep = 0;
  bool _isSearching = false;
  List<Map<String, dynamic>> _apiResults = [];

  // Step 1: Search - use local medication database
  final List<Map<String, dynamic>> _medications = MedicationSearchService.localMedications;

  // Step 2: Schedule
  final List<String> _selectedTimes = ['08:00', '13:00', '20:00'];

  // Step 3: Details
  int _stockCount = 30;
  int _threshold = 10;
  bool _remindRefill = true;
  int _dose = 1;
  String _selectedUnit = 'capsules';
  bool _criticalAlerts = true;
  bool _showDoseEditor = false;

  final _medicationSearchService = MedicationSearchService();

  @override
  void initState() {
    super.initState();
    _medicationSearchService.initialize();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _entranceCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _dotsCtrl.forward();
  }

  bool _isNextEnabled() {
    if (_currentStep == 0) {
      // Step 1: need a medication name, and if dose editor is shown, it's ready
      return _nameController.text.isNotEmpty;
    }
    // Steps 2 and 3 are always enabled
    return true;
  }

  void _nextStep() {
    Haptics.medium();
    if (_currentStep < 2) {
      // Stop animations before state change to prevent ticker leaks
      _entranceCtrl.stop();
      _dotsCtrl.stop();
      setState(() => _currentStep++);
      _entranceCtrl.reset();
      _dotsCtrl.reset();
      _startAnimations();
    } else {
      _saveMedication();
    }
  }

  void _prevStep() {
    Haptics.light();
    if (_currentStep > 0) {
      // Stop animations before state change to prevent ticker leaks
      _entranceCtrl.stop();
      _dotsCtrl.stop();
      setState(() => _currentStep--);
      _entranceCtrl.reset();
      _dotsCtrl.reset();
      _startAnimations();
    } else {
      Navigator.pop(context);
    }
  }

  /// Convert HH:MM times to Morning/Afternoon/Evening slots based on hour
  List<String> _timesToSlots(List<String> times) {
    final slots = <String>{};
    for (final time in times) {
      final hour = int.tryParse(time.split(':')[0]) ?? 0;
      if (hour >= 5 && hour < 12) {
        slots.add('Morning');
      } else if (hour >= 12 && hour < 17) {
        slots.add('Afternoon');
      } else {
        slots.add('Evening');
      }
    }
    return slots.toList();
  }

  void _saveMedication() async {
    Haptics.success();
    
    // Parse dosage from the selected medication
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    
    // Find the selected medication to get default dosage
    final selectedMed = _medications.firstWhere(
      (m) => m['name'] == name,
      orElse: () => {'name': name, 'dosage': '1 mg'},
    );
    
    // Parse dosage amount and unit
    final dosageStr = selectedMed['dosage']?.toString() ?? '1 mg';
    final dosageMatch = RegExp(r'([\d./]+)\s*(mg|mcg|IU|g|ml|CFU|capsule|tablet|spray|drop| tsp| cup| bottle| serving| units)').firstMatch(dosageStr);
    
    double dosageAmount = 1;
    String dosageUnit = 'mg';
    
    if (dosageMatch != null) {
      final amountStr = dosageMatch.group(1) ?? '1';
      // Handle fractions like "1/4"
      if (amountStr.contains('/')) {
        final parts = amountStr.split('/');
        if (parts.length == 2) {
          dosageAmount = double.tryParse(parts[0]) ?? 1 / (double.tryParse(parts[1]) ?? 1);
        }
      } else {
        dosageAmount = double.tryParse(amountStr) ?? 1;
      }
      dosageUnit = dosageMatch.group(2) ?? 'mg';
    }
    
    // Normalize dosage unit for backend compatibility
    final normalizedUnit = _normalizeDosageUnit(dosageUnit);
    
    // Convert HH:MM times to Morning/Afternoon/Evening slots
    final timeSlots = _timesToSlots(_selectedTimes);
    
    // Create the supplement
    final supplement = Supplement(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      dosageAmount: dosageAmount,
      dosageUnit: normalizedUnit,
      frequency: _dose,
      stockCount: _stockCount,
      timeSlots: timeSlots,
      startDate: DateTime.now().toIso8601String().split('T')[0],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    
    // Add via provider (API-first with local fallback)
    await ref.read(supplementsProvider.notifier).addSupplement(supplement);
    
    if (mounted) {
      Navigator.pop(context);
    }
  }

  /// Normalize dosage unit to match backend pattern
  String _normalizeDosageUnit(String unit) {
    final lower = unit.toLowerCase().trim();
    // Map common variants to standard units
    if (lower.contains('cap') || lower.contains('pill')) return 'capsules';
    if (lower.contains('tablet')) return 'tablet';
    if (lower.contains('softgel')) return 'softgels';
    if (lower.contains('drop')) return 'drops';
    if (lower.contains('scoop')) return 'scoops';
    if (lower.contains('serving')) return 'serving';
    if (lower.contains('unit')) return 'units';
    if (lower.contains('cup')) return 'cup';
    if (lower.contains('tsp')) return 'tsp';
    if (lower.contains('spray')) return 'spray';
    if (lower.contains('bottle')) return 'bottle';
    if (lower.contains('packet')) return 'packet';
    if (lower.contains('patch')) return 'patch';
    if (lower.contains('puff')) return 'puff';
    // Standard units
    if (lower == 'mg' || lower == 'mcg' || lower == 'iu' || lower == 'g' || lower == 'ml') {
      return lower;
    }
    return lower;
  }

  Future<void> _searchApi(String query) async {
    if (query.isEmpty || query.length < 2) {
      setState(() => _apiResults = []);
      return;
    }
    
    setState(() => _isSearching = true);
    
    try {
      final results = await _medicationSearchService.searchMedications(query);
      if (mounted) {
        setState(() {
          _apiResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _addTime() async {
    final now = TimeOfDay.now();
    final picked = await showTimePickerBottomSheet(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      if (!_selectedTimes.contains(formatted)) {
        setState(() {
          _selectedTimes.add(formatted);
          _selectedTimes.sort();
        });
      }
    }
  }

  void _removeTime(String time) {
    setState(() => _selectedTimes.remove(time));
  }

  void _changeStock(int delta) {
    final newVal = _stockCount + delta;
    if (newVal < 0 || newVal > 200) return;
    Haptics.selection();
    setState(() => _stockCount = newVal);
  }

  void _changeThreshold(int delta) {
    final newVal = _threshold + delta;
    if (newVal < 1 || newVal > 50) return;
    Haptics.selection();
    setState(() => _threshold = newVal);
  }

  void _changeDose(int delta) {
    final newVal = _dose + delta;
    if (newVal < 1 || newVal > 20) return;
    Haptics.selection();
    setState(() => _dose = newVal);
  }

  void _showCustomUnitDialog() {
    Haptics.medium();
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final tc = ThemeColors.of(context);
        return AlertDialog(
          backgroundColor: tc.cardBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(GR.radiusLg)),
          title: Text(
            'Custom Unit',
            style: AppTextStyles.h3(context),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: 'e.g., sprays, patches',
              hintStyle: AppTextStyles.bodySmall(context, color: tc.textMuted),
              filled: true,
              fillColor: tc.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(GR.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.body(context, color: tc.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Haptics.success();
                  setState(() => _selectedUnit = controller.text.trim());
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: AppTextStyles.body(context, weight: FontWeight.w700, color: tc.accentDark),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectMedication(Map<String, dynamic> med) {
    _nameController.text = med['name'] as String;
    
    // Try to parse dosage from the medication
    final dosageStr = med['dosage']?.toString() ?? '';
    if (dosageStr.isNotEmpty) {
      final match = RegExp(r'(\d+)\s*(mg|mcg|IU|g|ml|CFU)').firstMatch(dosageStr);
      if (match != null) {
        _dose = int.tryParse(match.group(1)!) ?? 1;
      }
    }
    
    setState(() => _showDoseEditor = true);
  }

  @override
  void dispose() {
    // Stop animations before disposing to prevent _dependents.isEmpty assertion
    _entranceCtrl.stop();
    _dotsCtrl.stop();
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    _searchFocus.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return [];
    
    // Combine local and API results
    final localResults = _medications
        .where((m) => m['name'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
    
    // Merge API results, avoiding duplicates
    final allResults = [...localResults];
    for (final apiResult in _apiResults) {
      final exists = allResults.any((m) => 
        m['name'].toString().toLowerCase() == apiResult['name'].toString().toLowerCase()
      );
      if (!exists) {
        allResults.add(apiResult);
      }
    }
    
    return allResults.take(15).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Dots ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(GR.lg, GR.sm, GR.lg, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _prevStep,
                    child: Container(
                      width: GR.lg + 2,
                      height: GR.lg + 2,
                      decoration: BoxDecoration(
                        color: tc.cardBg,
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: tc.border),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: tc.textPrimary),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(3, (i) {
                      final isActive = i <= _currentStep;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        width: i == _currentStep ? 24 : 8,
                        height: 8,
                        margin: EdgeInsets.symmetric(horizontal: GR.xs),
                        decoration: BoxDecoration(
                          color: isActive ? tc.accent : tc.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  SizedBox(width: GR.lg + 2),
                ],
              ),
            ),

            // ── Step Content ─────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.3, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    ),
                  );
                },
                child: _buildStep(),
              ),
            ),

            // ── Bottom Button ────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(GR.lg, 0, GR.lg, GR.lg + 4),
              child: GestureDetector(
                onTap: _isNextEnabled() ? _nextStep : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: GR.buttonMd,
                  decoration: BoxDecoration(
                    color: _isNextEnabled()
                        ? tc.textPrimary
                        : tc.border,
                    borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                  ),
                  child: Center(
                    child: Text(
                      _currentStep == 2 ? 'Save' : 'Next',
                      style: AppTextStyles.button(context, color: tc.cardBg),
                    ),
                  ),
                ),
              )
                  .animate(controller: _entranceCtrl)
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_currentStep) {
      case 0:
        return _buildSearchStep();
      case 1:
        return _buildScheduleStep();
      case 2:
        return _buildDetailsStep();
      default:
        return _buildSearchStep();
    }
  }

  // ─── STEP 1: Search ────────────────────────────────────────────────────────
  Widget _buildSearchStep() {
    final tc = ThemeColors.of(context);
    return Padding(
      key: const ValueKey(0),
      padding: EdgeInsets.symmetric(horizontal: GR.lg),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: GR.xl),

            // Title
            Center(
              child: Column(
                children: [
                  Text(
                    'Add Medication',
                    style: AppTextStyles.h1(context),
                  ),
                  SizedBox(height: GR.xs + 2),
                  Text(
                    'Search or type the name',
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xl + 2),

            // Search bar
            Container(
              height: GR.buttonMd,
              decoration: BoxDecoration(
                color: tc.cardBg,
                borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                border: Border.all(color: tc.border),
              ),
              child: Row(
                children: [
                  SizedBox(width: GR.md),
                  Icon(Icons.search_rounded, size: GR.iconSm + 2, color: tc.textMuted),
                  SizedBox(width: GR.sm + 2),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      focusNode: _searchFocus,
                      onChanged: (v) {
                        setState(() => _query = v);
                        // Debounced API search
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_query == v && mounted) {
                            _searchApi(v);
                          }
                        });
                      },
                      style: AppTextStyles.body(context),
                      decoration: InputDecoration(
                        hintText: 'Search for medication',
                        hintStyle: AppTextStyles.body(context, color: tc.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_query.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        setState(() {
                          _query = '';
                          _nameController.clear();
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.all(GR.md),
                        child: Icon(Icons.close_rounded, size: 18, color: tc.textMuted),
                      ),
                    ),
                  SizedBox(width: GR.sm),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 150.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Results or empty state
            if (_showDoseEditor) ...[
              SizedBox(height: GR.lg),
              Container(
                padding: EdgeInsets.all(GR.lg),
                decoration: BoxDecoration(
                  color: tc.cardBg,
                  borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                  border: Border.all(color: tc.accentLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text,
                      style: AppTextStyles.body(context, weight: FontWeight.w700),
                    ),
                    SizedBox(height: GR.md),
                    Row(
                      children: [
                        Text(
                          'Dose',
                          style: AppTextStyles.body(context, weight: FontWeight.w500),
                        ),
                        const Spacer(),
                        _buildStepper(
                          value: _dose,
                          onDecrement: () => _changeDose(-1),
                          onIncrement: () => _changeDose(1),
                          label: '$_dose',
                          accentColor: tc.accent,
                          bgColor: tc.accentBg,
                          textColor: tc.accentDark,
                        ),
                      ],
                    ),
                    SizedBox(height: GR.md),
                    Text(
                      'Unit',
                      style: AppTextStyles.body(context, weight: FontWeight.w500),
                    ),
                    SizedBox(height: GR.sm),
                    Wrap(
                      spacing: GR.sm,
                      runSpacing: GR.sm,
                      children: [...['capsules', 'IU', 'mcg', 'mg', 'drops', 'scoops', 'tablets', 'softgels'], 'others'].map((unit) {
                        final isSelected = _selectedUnit == unit;
                        return GestureDetector(
                          onTap: () {
                            Haptics.selection();
                            if (unit == 'others') {
                              _showCustomUnitDialog();
                            } else {
                              setState(() => _selectedUnit = unit);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                            decoration: BoxDecoration(
                              color: isSelected ? tc.accentLight.withValues(alpha: 0.4) : tc.surface,
                              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                              border: Border.all(
                                color: isSelected ? tc.accentLight : tc.border,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              unit == 'others' ? 'others' : unit,
                              style: AppTextStyles.body(
                                context,
                                weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? tc.accentDark : tc.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              )
                  .animate(controller: _entranceCtrl)
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),
              // Next button is ONLY at the bottom of the screen, not here
            ] else if (_query.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    SizedBox(height: GR.xl),
                    _buildPillDotMatrix(),
                    SizedBox(height: GR.lg),
                    Text(
                      'Type the name of your\nmedication or supplement',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body(context, height: 1.5),
                    ),
                  ],
                ),
              )
                  .animate(controller: _entranceCtrl)
                  .fadeIn(delay: 300.ms, duration: 600.ms)
                  .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 600.ms, curve: Curves.easeOutCubic),
            ] else ...[
              ..._filtered.asMap().entries.map((entry) {
                final i = entry.key;
                final med = entry.value;
                final isApiResult = med['source'] == 'OpenFDA';
                return GestureDetector(
                  onTap: () => _selectMedication(med),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: GR.sm + 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(
                            Icons.medication_rounded,
                            size: 26,
                            color: tc.accent,
                          ),
                        ),
                        SizedBox(width: GR.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      med['name'] as String,
                                      style: AppTextStyles.body(context, weight: FontWeight.w600),
                                    ),
                                  ),
                                  if (isApiResult)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: GR.xs + 2, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: tc.accent.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(GR.radiusSm),
                                      ),
                                      child: Text(
                                        'FDA',
                                        style: AppTextStyles.caption(context, color: tc.accent, weight: FontWeight.w600),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                med['dosage'] as String? ?? '',
                                style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: GR.iconSm + 2,
                          color: tc.accent,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: Duration(milliseconds: 200 + i * 60), duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 200 + i * 60), duration: 400.ms, curve: Curves.easeOutCubic);
              }),

              if (_isSearching)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: GR.lg),
                    child: DotMatrixLoading(
                      dotSize: 5,
                      color: tc.accent,
                    ),
                  ),
                ),

              if (_filtered.isEmpty && !_isSearching)
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: GR.xxl),
                      Icon(Icons.search_off_rounded, size: GR.iconLg + 4, color: tc.textMuted),
                      SizedBox(height: GR.md),
                      Text(
                        'No results for "$_query"',
                        style: AppTextStyles.body(context, color: tc.textSecondary),
                      ),
                      SizedBox(height: GR.xs),
                      Text(
                        'Tap Next to add it anyway',
                        style: AppTextStyles.body(context, weight: FontWeight.w500, color: tc.accent),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 200.ms, duration: 400.ms),
            ],

            SizedBox(height: GR.xxl),
          ],
        ),
      ),
    );
  }

  // ─── STEP 2: Schedule (Simple Time Picker) ─────────────────────────────────
  Widget _buildScheduleStep() {
    final tc = ThemeColors.of(context);
    return Padding(
      key: const ValueKey(1),
      padding: EdgeInsets.symmetric(horizontal: GR.lg),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: GR.xl),

            // Medication name + title
            Center(
              child: Column(
                children: [
                  Text(
                    _nameController.text,
                    style: AppTextStyles.body(context, color: tc.textMuted),
                  ),
                  SizedBox(height: GR.xs),
                  Text(
                    'When would you like to be reminded?',
                    style: AppTextStyles.h2(context),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xl + 2),

            // Time chips
            Wrap(
              spacing: GR.sm,
              runSpacing: GR.sm,
              children: [
                ..._selectedTimes.map((time) {
                  return GestureDetector(
                    onTap: () => _removeTime(time),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                      decoration: BoxDecoration(
                        color: tc.accentLight.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        border: Border.all(color: tc.accentLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            time,
                            style: AppTextStyles.body(context, weight: FontWeight.w700, color: tc.accentDark),
                          ),
                          SizedBox(width: GR.xs),
                          Icon(Icons.close_rounded, size: 16, color: tc.accentDark),
                        ],
                      ),
                    ),
                  );
                }),
                GestureDetector(
                  onTap: _addTime,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                    decoration: BoxDecoration(
                      color: tc.surface,
                      borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                      border: Border.all(color: tc.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 18, color: tc.textSecondary),
                        SizedBox(width: GR.xs),
                        Text(
                          'Add Time',
                          style: AppTextStyles.body(context, weight: FontWeight.w500, color: tc.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xxl),
          ],
        ),
      ),
    );
  }

  // ─── STEP 3: Details (Stock + Dose) ──────────────────────────────────────
  Widget _buildDetailsStep() {
    final tc = ThemeColors.of(context);
    return Padding(
      key: const ValueKey(2),
      padding: EdgeInsets.symmetric(horizontal: GR.lg),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: GR.xl),

            Center(
              child: Column(
                children: [
                  Text(
                    'Medication & Settings',
                    style: AppTextStyles.body(context, color: tc.textMuted),
                  ),
                  SizedBox(height: GR.xs),
                  Text(
                    _nameController.text,
                    style: AppTextStyles.h2(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GR.xs + 2),
                  Text(
                    _getScheduleSummary(),
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xl + 2),

            // Stock card with compact stepper (moved up)
            GoldenCard(
              padding: EdgeInsets.all(GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: GR.iconSm - 2, color: tc.textMuted),
                      SizedBox(width: GR.xs + 2),
                      Text(
                        'CURRENT INVENTORY',
                        style: AppTextStyles.body(context),
                      ),
                    ],
                  ),
                  SizedBox(height: GR.md),
                  Row(
                    children: [
                      Text(
                        'Amount',
                        style: AppTextStyles.body(context, weight: FontWeight.w500),
                      ),
                      const Spacer(),
                      _buildStepper(
                        value: _stockCount,
                        onDecrement: () => _changeStock(-1),
                        onIncrement: () => _changeStock(1),
                        label: '$_stockCount $_selectedUnit',
                        accentColor: tc.accent,
                        bgColor: tc.accentBg,
                        textColor: tc.accentDark,
                      ),
                    ],
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 100.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Dose card (moved down)
            GoldenCard(
              padding: EdgeInsets.all(GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medication_rounded, size: GR.iconSm - 2, color: tc.textMuted),
                      SizedBox(width: GR.xs + 2),
                      Text(
                        'DOSE',
                        style: AppTextStyles.body(context),
                      ),
                    ],
                  ),
                  SizedBox(height: GR.md),
                  Row(
                    children: [
                      Text(
                        'Amount',
                        style: AppTextStyles.body(context, weight: FontWeight.w500),
                      ),
                      const Spacer(),
                      _buildStepper(
                        value: _dose,
                        onDecrement: () => _changeDose(-1),
                        onIncrement: () => _changeDose(1),
                        label: '$_dose',
                        accentColor: tc.accent,
                        bgColor: tc.accentBg,
                        textColor: tc.accentDark,
                      ),
                    ],
                  ),
                  SizedBox(height: GR.md),
                  Text(
                    'Unit',
                    style: AppTextStyles.body(context, weight: FontWeight.w500),
                  ),
                  SizedBox(height: GR.sm),
                  Wrap(
                    spacing: GR.sm,
                    runSpacing: GR.sm,
                    children: ['capsules', 'IU', 'mcg', 'mg', 'drops', 'scoops', 'tablets', 'softgels'].map((unit) {
                      final isSelected = _selectedUnit == unit;
                      return GestureDetector(
                        onTap: () {
                          Haptics.selection();
                          setState(() => _selectedUnit = unit);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.sm + 2),
                          decoration: BoxDecoration(
                            color: isSelected ? tc.accentLight.withValues(alpha: 0.4) : tc.surface,
                            borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                            border: Border.all(
                              color: isSelected ? tc.accentLight : tc.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            unit,
                            style: AppTextStyles.body(
                              context,
                              weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? tc.accentDark : tc.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Refill reminder toggle
            GestureDetector(
              onTap: () => setState(() => _remindRefill = !_remindRefill),
              child: GoldenCard(
                padding: EdgeInsets.all(GR.md + 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Remind me to refill',
                                style: AppTextStyles.body(context, weight: FontWeight.w500),
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                'When stock runs low',
                                style: AppTextStyles.body(context),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _remindRefill ? tc.accent : tc.border,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOutCubic,
                            alignment: _remindRefill ? Alignment.centerRight : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_remindRefill) ...[
                      SizedBox(height: GR.md),
                      Divider(height: 1, color: tc.border),
                      SizedBox(height: GR.md),
                      Row(
                        children: [
                          Text(
                            'Threshold',
                            style: AppTextStyles.body(context, weight: FontWeight.w500),
                          ),
                          const Spacer(),
                          _buildStepper(
                            value: _threshold,
                            onDecrement: () => _changeThreshold(-1),
                            onIncrement: () => _changeThreshold(1),
                            label: '$_threshold $_selectedUnit',
                            accentColor: tc.orange,
                            bgColor: tc.orangeLight.withValues(alpha: 0.4),
                            textColor: tc.orange,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.lg),

            // Critical alerts toggle
            GestureDetector(
              onTap: () => setState(() => _criticalAlerts = !_criticalAlerts),
              child: GoldenCard(
                padding: EdgeInsets.all(GR.md + 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enable Critical Alerts',
                            style: AppTextStyles.body(context, weight: FontWeight.w500),
                          ),
                          SizedBox(height: GR.xs - 2),
                          Text(
                            'Even in Silent or DND mode',
                            style: AppTextStyles.body(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _criticalAlerts ? tc.accent : tc.border,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        alignment: _criticalAlerts ? Alignment.centerRight : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xxl + GR.xl),
          ],
        ),
      ),
    );
  }

  String _getScheduleSummary() {
    if (_selectedTimes.isEmpty) return 'No reminder times set';
    return 'Reminders at ${_selectedTimes.join(', ')}';
  }

  Widget _buildStepper({
    required int value,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required String label,
    required Color accentColor,
    required Color bgColor,
    required Color textColor,
  }) {
    final tc = ThemeColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDecrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: tc.surface,
              borderRadius: BorderRadius.circular(GR.radiusSm),
              border: Border.all(color: tc.border),
            ),
            child: Icon(Icons.remove_rounded, size: 18, color: tc.textSecondary),
          ),
        ),
        SizedBox(width: GR.md),
        Text(
          label,
          style: AppTextStyles.body(context, weight: FontWeight.w700, color: textColor),
        ),
        SizedBox(width: GR.md),
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(GR.radiusSm),
            ),
            child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ─── Pill Dot Matrix Visual ──────────────────────────────────────────────
  Widget _buildPillDotMatrix() {
    final tc = ThemeColors.of(context);
    const rows = 5;
    const cols = 7;

    return AnimatedBuilder(
      animation: _dotsCtrl,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_dotsCtrl.value);
        final activeDots = (rows * cols * progress).round();

        return Column(
          children: List.generate(rows, (row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(cols, (col) {
                final index = row * cols + col;
                final isActive = index < activeDots;
                final intensity = isActive ? (index / activeDots).clamp(0.3, 1.0) : 0.0;
                final color = isActive
                    ? Color.lerp(tc.accentLight, tc.accentDark, intensity)!
                    : const Color(0xFFE5E7EB);

                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                )
                    .animate()
                    .scale(
                      begin: const Offset(0.0, 0.0),
                      end: const Offset(1.0, 1.0),
                      delay: Duration(milliseconds: index * 12),
                      duration: 200.ms,
                      curve: Curves.easeOutBack,
                    );
              }),
            );
          }),
        );
      },
    );
  }
}
