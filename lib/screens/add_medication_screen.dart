import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;
  late final AnimationController _dotsCtrl;
  final _nameController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  int _currentStep = 0;

  // Step 1: Search
  final List<Map<String, dynamic>> _medications = [
    {'name': 'Vitamin D3', 'dosage': '2000 IU'},
    {'name': 'Omega-3 Fish Oil', 'dosage': '1000 mg'},
    {'name': 'Magnesium', 'dosage': '400 mg'},
    {'name': 'Vitamin B12', 'dosage': '1000 mcg'},
    {'name': 'Zinc', 'dosage': '25 mg'},
    {'name': 'Probiotics', 'dosage': '50B CFU'},
    {'name': 'Iron', 'dosage': '18 mg'},
    {'name': 'Calcium', 'dosage': '600 mg'},
    {'name': 'Melatonin', 'dosage': '3 mg'},
  ];

  // Step 2: Schedule type
  int _scheduleType = 0; // 0=Interval, 1=Multiple, 2=SpecificDays, 3=Cyclic
  bool _intervalHours = true; // true=Every X hours, false=Every X days
  int _intervalValue = 6;
  int _multipleTimes = 3;
  final List<bool> _selectedDays = [false, true, false, true, false, true, false]; // Sun-Sat
  int _intakeDays = 21;
  int _pauseDays = 7;

  // Slider haptic tracking
  int _prevIntervalValue = 6;
  int _prevMultipleTimes = 3;
  int _prevIntakeDays = 21;
  int _prevPauseDays = 7;
  int _prevStockCount = 30;
  int _prevThreshold = 10;
  int _stockCount = 30;
  int _threshold = 10;
  bool _remindRefill = true;
  String _startTime = '08:00';
  String _endTime = '20:00';
  int _dose = 1;
  bool _criticalAlerts = true;

  @override
  void initState() {
    super.initState();
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

  void _nextStep() {
    Haptics.medium();
    if (_currentStep < 2) {
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
      setState(() => _currentStep--);
      _entranceCtrl.reset();
      _dotsCtrl.reset();
      _startAnimations();
    } else {
      Navigator.pop(context);
    }
  }

  void _saveMedication() {
    Haptics.success();
    Navigator.pop(context);
  }

  void _selectMedication(Map<String, dynamic> med) {
    _nameController.text = med['name'] as String;
    _nextStep();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _dotsCtrl.dispose();
    _searchFocus.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.isEmpty) return [];
    return _medications
        .where((m) => m['name'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
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
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: AppColors.textPrimary),
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
                          color: isActive ? AppColors.accent : AppColors.border,
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
                onTap: _currentStep == 0 && _nameController.text.isEmpty ? null : _nextStep,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: GR.buttonMd,
                  decoration: BoxDecoration(
                    color: _currentStep == 0 && _nameController.text.isEmpty
                        ? AppColors.border
                        : AppColors.textPrimary,
                    borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                  ),
                  child: Center(
                    child: Text(
                      _currentStep == 2 ? 'Save' : 'Next',
                      style: AppTextStyles.button(context),
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
                    style: AppTextStyles.bodySmall(context),
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
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(GR.radiusLg - 1),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  SizedBox(width: GR.md),
                  Icon(Icons.search_rounded, size: GR.iconSm + 2, color: AppColors.textMuted),
                  SizedBox(width: GR.sm + 2),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      focusNode: _searchFocus,
                      onChanged: (v) => setState(() => _query = v),
                      style: AppTextStyles.body(context),
                      decoration: InputDecoration(
                        hintText: 'Search for medication',
                        hintStyle: AppTextStyles.body(context, color: AppColors.textMuted),
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
                        child: Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
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
            if (_query.isEmpty) ...[
              Center(
                child: Column(
                  children: [
                    SizedBox(height: GR.xl),
                    _buildPillDotMatrix(),
                    SizedBox(height: GR.lg),
                    Text(
                      'Type the name of your\nmedication or supplement',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySmall(context, height: 1.5),
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
                            color: AppColors.accent,
                          ),
                        ),
                        SizedBox(width: GR.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                med['name'] as String,
                                style: AppTextStyles.body(context, weight: FontWeight.w600),
                              ),
                              SizedBox(height: GR.xs - 2),
                              Text(
                                med['dosage'] as String,
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: GR.iconSm + 2,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: Duration(milliseconds: 200 + i * 60), duration: 400.ms)
                    .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 200 + i * 60), duration: 400.ms, curve: Curves.easeOutCubic);
              }),

              if (_filtered.isEmpty)
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: GR.xxl),
                      Icon(Icons.search_off_rounded, size: GR.iconLg + 4, color: AppColors.textMuted),
                      SizedBox(height: GR.md),
                      Text(
                        'No results for "$_query"',
                        style: AppTextStyles.body(context, color: AppColors.textSecondary),
                      ),
                      SizedBox(height: GR.xs),
                      Text(
                        'Tap Next to add it anyway',
                        style: AppTextStyles.caption(context),
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

  // ─── STEP 2: Schedule Type ─────────────────────────────────────────────────
  Widget _buildScheduleStep() {
    final scheduleOptions = [
      {
        'title': 'Interval',
        'subtitle': 'e.g. once every second day, once every 6 hours, once every three months',
        'icon': Icons.timer_outlined,
      },
      {
        'title': 'Multiple times daily',
        'subtitle': 'e.g. 3 or more times a day',
        'icon': Icons.repeat_rounded,
      },
      {
        'title': 'Specific days of the week',
        'subtitle': 'e.g. Mon., Wed. & Fri.',
        'icon': Icons.calendar_today_rounded,
      },
      {
        'title': 'Cyclic mode',
        'subtitle': 'e.g. 21 intake days, 7 pause days',
        'icon': Icons.cyclone_rounded,
      },
    ];

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
                    style: AppTextStyles.caption(context, color: AppColors.textMuted),
                  ),
                  SizedBox(height: GR.xs),
                  Text(
                    'Which schedule works for you?',
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

            // Schedule options with toggles
            ...scheduleOptions.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final isSelected = _scheduleType == i;

              return GestureDetector(
                onTap: () {
                  Haptics.selection();
                  setState(() => _scheduleType = i);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: GR.sm + 2),
                  padding: EdgeInsets.all(GR.md + 3),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(GR.radiusMd + 2),
                    border: Border.all(
                      color: isSelected ? AppColors.accentLight : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
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
                                  opt['title'] as String,
                                  style: AppTextStyles.body(
                                    context,
                                    weight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: GR.xs - 2),
                                Text(
                                  opt['subtitle'] as String,
                                  style: AppTextStyles.bodySmall(context),
                                ),
                              ],
                            ),
                          ),
                          // Toggle switch
                          Container(
                            width: 48,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accent : AppColors.border,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              alignment: isSelected ? Alignment.centerRight : Alignment.centerLeft,
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

                      // Expanded sub-options
                      if (isSelected) ...[
                        SizedBox(height: GR.md),
                        const Divider(height: 1, color: AppColors.border),
                        SizedBox(height: GR.md),

                        if (i == 0) ...[
                          // Interval sub-options
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _intervalHours = true),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                                    decoration: BoxDecoration(
                                      color: _intervalHours ? AppColors.accentLight.withValues(alpha: 0.4) : AppColors.surface,
                                      borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_intervalHours) ...[
                                            Icon(Icons.check, size: 14, color: AppColors.accentDark),
                                            SizedBox(width: GR.xs),
                                          ],
                                          Text(
                                            'Every X hours',
                                            style: AppTextStyles.caption(
                                              context,
                                              weight: _intervalHours ? FontWeight.w700 : FontWeight.w500,
                                              color: _intervalHours ? AppColors.accentDark : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: GR.sm),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _intervalHours = false),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
                                    decoration: BoxDecoration(
                                      color: !_intervalHours ? AppColors.accentLight.withValues(alpha: 0.4) : AppColors.surface,
                                      borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (!_intervalHours) ...[
                                            Icon(Icons.check, size: 14, color: AppColors.accentDark),
                                            SizedBox(width: GR.xs),
                                          ],
                                          Text(
                                            'Every X days',
                                            style: AppTextStyles.caption(
                                              context,
                                              weight: !_intervalHours ? FontWeight.w700 : FontWeight.w500,
                                              color: !_intervalHours ? AppColors.accentDark : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.md),
                          Row(
                            children: [
                              Text(
                                'Remind every',
                                style: AppTextStyles.body(context, weight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBg,
                                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                ),
                                child: Text(
                                  '$_intervalValue',
                                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.accentDark),
                                ),
                              ),
                              SizedBox(width: GR.xs),
                              Text(
                                _intervalHours ? 'hours' : 'days',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.sm),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.accent,
                              overlayColor: AppColors.accent.withValues(alpha: 0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              value: _intervalValue.toDouble(),
                              min: 1,
                              max: _intervalHours ? 24 : 30,
                              onChanged: (v) {
                                final rounded = v.round();
                                if (rounded != _prevIntervalValue) {
                                  Haptics.selection();
                                  _prevIntervalValue = rounded;
                                }
                                setState(() => _intervalValue = rounded);
                              },
                            ),
                          ),
                        ],

                        if (i == 1) ...[
                          // Multiple times sub-option
                          Row(
                            children: [
                              Text(
                                'Intakes',
                                style: AppTextStyles.body(context, weight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBg,
                                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                ),
                                child: Text(
                                  '$_multipleTimes',
                                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.accentDark),
                                ),
                              ),
                              SizedBox(width: GR.xs),
                              Text(
                                'times daily',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.sm),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.accent,
                              overlayColor: AppColors.accent.withValues(alpha: 0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              value: _multipleTimes.toDouble(),
                              min: 2,
                              max: 6,
                              onChanged: (v) {
                                final rounded = v.round();
                                if (rounded != _prevMultipleTimes) {
                                  Haptics.selection();
                                  _prevMultipleTimes = rounded;
                                }
                                setState(() => _multipleTimes = rounded);
                              },
                            ),
                          ),
                        ],

                        if (i == 2) ...[
                          // Specific days - day picker
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].asMap().entries.map((dayEntry) {
                              final dayIdx = dayEntry.key;
                              final dayLabel = dayEntry.value;
                              final isDaySelected = _selectedDays[dayIdx];
                              return GestureDetector(
                                onTap: () => setState(() => _selectedDays[dayIdx] = !isDaySelected),
                                child: Container(
                                  width: 38,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: isDaySelected ? AppColors.accentLight.withValues(alpha: 0.4) : AppColors.surface,
                                    borderRadius: BorderRadius.circular(GR.radiusSm + 4),
                                    border: Border.all(
                                      color: isDaySelected ? AppColors.accentLight : Colors.transparent,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (isDaySelected)
                                        Icon(Icons.check, size: 14, color: AppColors.accentDark),
                                      SizedBox(height: isDaySelected ? GR.xs - 2 : 0),
                                      Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontFamily: 'Artific',
                                          fontSize: 11,
                                          fontWeight: isDaySelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isDaySelected ? AppColors.accentDark : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        if (i == 3) ...[
                          // Cyclic mode sub-options
                          Row(
                            children: [
                              Text(
                                'Intake days',
                                style: AppTextStyles.body(context, weight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accentBg,
                                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                ),
                                child: Text(
                                  '$_intakeDays',
                                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.accentDark),
                                ),
                              ),
                              SizedBox(width: GR.xs),
                              Text(
                                'days',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.sm),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.accent,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.accent,
                              overlayColor: AppColors.accent.withValues(alpha: 0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              value: _intakeDays.toDouble(),
                              min: 1,
                              max: 30,
                              onChanged: (v) {
                                final rounded = v.round();
                                if (rounded != _prevIntakeDays) {
                                  Haptics.selection();
                                  _prevIntakeDays = rounded;
                                }
                                setState(() => _intakeDays = rounded);
                              },
                            ),
                          ),
                          SizedBox(height: GR.sm),
                          Row(
                            children: [
                              Text(
                                'Pause days',
                                style: AppTextStyles.body(context, weight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                                decoration: BoxDecoration(
                                  color: AppColors.orangeLight.withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                                ),
                                child: Text(
                                  '$_pauseDays',
                                  style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.orange),
                                ),
                              ),
                              SizedBox(width: GR.xs),
                              Text(
                                'days',
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                          SizedBox(height: GR.sm),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.orange,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.orange,
                              overlayColor: AppColors.orange.withValues(alpha: 0.1),
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                            ),
                            child: Slider(
                              value: _pauseDays.toDouble(),
                              min: 1,
                              max: 14,
                              onChanged: (v) {
                                final rounded = v.round();
                                if (rounded != _prevPauseDays) {
                                  Haptics.selection();
                                  _prevPauseDays = rounded;
                                }
                                setState(() => _pauseDays = rounded);
                              },
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              )
                  .animate(controller: _entranceCtrl)
                  .fadeIn(delay: Duration(milliseconds: 100 + i * 80), duration: 400.ms)
                  .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: 100 + i * 80), duration: 400.ms, curve: Curves.easeOutCubic);
            }),

            SizedBox(height: GR.xxl),
          ],
        ),
      ),
    );
  }

  // ─── STEP 3: Details (Stock + Time + Dose) ───────────────────────────────
  Widget _buildDetailsStep() {
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
                    _nameController.text,
                    style: AppTextStyles.caption(context, color: AppColors.textMuted),
                  ),
                  SizedBox(height: GR.xs),
                  Text(
                    'When would you like to be reminded?',
                    style: AppTextStyles.h2(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: GR.xs + 2),
                  Text(
                    _getScheduleSummary(),
                    style: AppTextStyles.bodySmall(context),
                  ),
                ],
              ),
            )
                .animate(controller: _entranceCtrl)
                .fadeIn(delay: 0.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0, delay: 0.ms, duration: 600.ms, curve: Curves.easeOutCubic),

            SizedBox(height: GR.xl + 2),

            // Time + Dose card
            GoldenCard(
              padding: EdgeInsets.all(GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: GR.iconSm - 2, color: AppColors.textMuted),
                      SizedBox(width: GR.xs + 2),
                      Text(
                        'REMINDER TIME',
                        style: AppTextStyles.caption(context),
                      ),
                    ],
                  ),
                  SizedBox(height: GR.md),
                  _buildTimeRow('Starting at', _startTime, (v) => setState(() => _startTime = v)),
                  const Divider(height: 1, color: AppColors.border),
                  _buildTimeRow('Ending at', _endTime, (v) => setState(() => _endTime = v)),
                  const Divider(height: 1, color: AppColors.border),
                  Row(
                    children: [
                      Text(
                        'Dose',
                        style: AppTextStyles.body(context, weight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        ),
                        child: Text(
                          '$_dose capsule(s)',
                          style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.accentDark),
                        ),
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

            // Stock card with dot matrix
            GoldenCard(
              padding: EdgeInsets.all(GR.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: GR.iconSm - 2, color: AppColors.textMuted),
                      SizedBox(width: GR.xs + 2),
                      Text(
                        'CURRENT INVENTORY',
                        style: AppTextStyles.caption(context),
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
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentBg,
                          borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                        ),
                        child: Text(
                          '$_stockCount capsule(s)',
                          style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.accentDark),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: GR.lg),
                  _buildStockDotMatrix(),
                  SizedBox(height: GR.lg),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.accent,
                      inactiveTrackColor: AppColors.border,
                      thumbColor: AppColors.accent,
                      overlayColor: AppColors.accent.withValues(alpha: 0.1),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: _stockCount.toDouble(),
                      min: 0,
                      max: 100,
                      onChanged: (v) {
                        final rounded = v.round();
                        if (rounded != _prevStockCount) {
                          Haptics.selection();
                          _prevStockCount = rounded;
                        }
                        setState(() => _stockCount = rounded);
                      },
                    ),
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
                                style: AppTextStyles.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _remindRefill ? AppColors.accent : AppColors.border,
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
                      const Divider(height: 1, color: AppColors.border),
                      SizedBox(height: GR.md),
                      Row(
                        children: [
                          Text(
                            'Threshold',
                            style: AppTextStyles.body(context, weight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
                            decoration: BoxDecoration(
                              color: AppColors.orangeLight.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
                            ),
                            child: Text(
                              '$_threshold capsule(s)',
                              style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.orange),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: GR.sm),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.orange,
                          inactiveTrackColor: AppColors.border,
                          thumbColor: AppColors.orange,
                          overlayColor: AppColors.orange.withValues(alpha: 0.1),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _threshold.toDouble(),
                          min: 1,
                          max: 20,
                          onChanged: (v) {
                            final rounded = v.round();
                            if (rounded != _prevThreshold) {
                              Haptics.selection();
                              _prevThreshold = rounded;
                            }
                            setState(() => _threshold = rounded);
                          },
                        ),
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
                            style: AppTextStyles.bodySmall(context),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _criticalAlerts ? AppColors.accent : AppColors.border,
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
    switch (_scheduleType) {
      case 0:
        return 'Intake every $_intervalValue ${_intervalHours ? 'hours' : 'days'}';
      case 1:
        return 'Intake $_multipleTimes times daily';
      case 2:
        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final selected = <String>[];
        for (int i = 0; i < 7; i++) {
          if (_selectedDays[i]) selected.add(days[i]);
        }
        return 'Intake on ${selected.join(', ')}';
      case 3:
        return '$_intakeDays intake days, $_pauseDays pause days';
      default:
        return '';
    }
  }

  Widget _buildTimeRow(String label, String value, ValueChanged<String> onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: GR.sm + 2),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body(context, weight: FontWeight.w500),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: GR.sm + 4, vertical: GR.xs + 2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(GR.radiusSm + 2),
            ),
            child: Text(
              value,
              style: AppTextStyles.caption(context, weight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Pill Dot Matrix Visual ──────────────────────────────────────────────
  Widget _buildPillDotMatrix() {
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
                    ? Color.lerp(AppColors.accentLight, AppColors.accentDark, intensity)!
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

  // ─── Stock Dot Matrix Visual ─────────────────────────────────────────────
  Widget _buildStockDotMatrix() {
    const dotCount = 30;

    return AnimatedBuilder(
      animation: _dotsCtrl,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_dotsCtrl.value);
        final stockProgress = (_stockCount / 100).clamp(0.0, 1.0);
        final activeCount = (dotCount * stockProgress * progress).round();

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: List.generate(dotCount, (i) {
            final isActive = i < activeCount;
            final intensity = isActive ? (i / activeCount).clamp(0.3, 1.0) : 0.0;
            final color = isActive
                ? Color.lerp(AppColors.amber, AppColors.accentDark, intensity)!
                : const Color(0xFFE5E7EB);

            return Container(
              width: 5.5,
              height: 5.5,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.0, 0.0),
                  end: const Offset(1.0, 1.0),
                  delay: Duration(milliseconds: i * 15),
                  duration: 250.ms,
                  curve: Curves.easeOutBack,
                );
          }),
        );
      },
    );
  }
}
