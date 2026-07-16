import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';
import '../providers/app_provider.dart';
import '../services/local_storage_service.dart';
import '../widgets/dot_matrix_loading.dart';
import 'main_navigation_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen>
    with TickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  
  String _countryCode = '+91';
  bool _isLoading = false;
  bool _otpSent = false;
  int _resendSeconds = 0;
  String? _errorMessage;
  String? _demoOtp;

  late final AnimationController _rotateController;
  late final AnimationController _pulseController;
  late final AnimationController _entranceCtrl;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'flag': '\uD83C\uDDFA\uD83C\uDDF8', 'name': 'United States'},
    {'code': '+44', 'flag': '\uD83C\uDDEC\uD83C\uDDE7', 'name': 'United Kingdom'},
    {'code': '+91', 'flag': '\uD83C\uDDEE\uD83C\uDDF3', 'name': 'India'},
    {'code': '+61', 'flag': '\uD83C\uDDE6\uD83C\uDDFA', 'name': 'Australia'},
    {'code': '+86', 'flag': '\uD83C\uDDE8\uD83C\uDDF3', 'name': 'China'},
    {'code': '+81', 'flag': '\uD83C\uDDEF\uD83C\uDDF5', 'name': 'Japan'},
    {'code': '+49', 'flag': '\uD83C\uDDE9\uD83C\uDDEA', 'name': 'Germany'},
    {'code': '+33', 'flag': '\uD83C\uDDEB\uD83C\uDDF7', 'name': 'France'},
    {'code': '+7', 'flag': '\uD83C\uDDF7\uD83C\uDDFA', 'name': 'Russia'},
    {'code': '+65', 'flag': '\uD83C\uDDF8\uD83C\uDDEC', 'name': 'Singapore'},
    {'code': '+971', 'flag': '\uD83C\uDDE6\uD83C\uDDEA', 'name': 'UAE'},
    {'code': '+92', 'flag': '\uD83C\uDDF5\uD83C\uDDF8', 'name': 'Pakistan'},
    {'code': '+880', 'flag': '\uD83C\uDDE7\uD83C\uDDE9', 'name': 'Bangladesh'},
    {'code': '+94', 'flag': '\uD83C\uDDF1\uD83C\uDDF0', 'name': 'Sri Lanka'},
    {'code': '+66', 'flag': '\uD83C\uDDF9\uD83C\uDDED', 'name': 'Thailand'},
  ];

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _rotateController.stop();
    _pulseController.stop();
    _entranceCtrl.stop();
    _rotateController.dispose();
    _pulseController.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendSeconds = 60);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendSeconds--);
      return _resendSeconds > 0;
    });
  }

  Future<void> _sendOTP() async {
    Haptics.medium();
    final phone = _phoneCtrl.text.trim();
    
    if (phone.isEmpty || phone.length < 6) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.invalidPhone);
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.dio.post('/auth/send-otp', data: {
        'phone': phone,
        'country_code': _countryCode,
      });

      if (response.data['success'] == true) {
        setState(() {
          _otpSent = true;
          _demoOtp = 'Check console';
        });
        _startResendTimer();
        Haptics.success();
      } else {
        setState(() => _errorMessage = response.data['message'] ?? 'Failed to send OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.networkError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOTP() async {
    Haptics.medium();
    final otp = _otpCtrls.map((c) => c.text).join();
    final phone = _phoneCtrl.text.trim();
    
    if (otp.length != 6) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.invalidOTP);
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      final response = await api.dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'country_code': _countryCode,
        'otp': otp,
        'name': _nameCtrl.text.trim(),
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        final token = data['token'] as String;
        
        await LocalStorageService().setToken(token);
        ref.read(authStateProvider.notifier).setAuthenticated(true);
        
        Haptics.success();
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        }
      } else {
        setState(() => _errorMessage = response.data['message'] ?? 'Invalid OTP');
      }
    } catch (e) {
      setState(() => _errorMessage = AppLocalizations.of(context)!.verificationFailed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showCountryPicker() {
    Haptics.light();
    final tc = ThemeColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: tc.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(GR.radiusLg + 8)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(top: GR.md),
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(color: tc.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(GR.lg),
                child: Text(
                  AppLocalizations.of(context)!.selectCountry,
                  style: AppTextStyles.h3(context),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final country = _countryCodes[index];
                    final isSelected = country['code'] == _countryCode;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _countryCode = country['code']!);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.lg, vertical: GR.md),
                        decoration: BoxDecoration(
                          color: isSelected ? tc.accent.withValues(alpha: 0.08) : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                            SizedBox(width: GR.md),
                            Expanded(
                              child: Text(
                                country['name']!,
                                style: AppTextStyles.body(
                                  context,
                                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                            ),
                            Text(
                              country['code']!,
                              style: AppTextStyles.body(
                                context,
                                color: isSelected ? tc.accent : tc.textSecondary,
                                weight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                            if (isSelected) ...[
                              SizedBox(width: GR.sm),
                              Icon(Icons.check_rounded, size: 18, color: tc.accent),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: GR.xl),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    // ignore: unused_local_variable

    return Scaffold(
      backgroundColor: tc.bg,
      body: Stack(
        children: [
          // Orbital background — matches landing screen
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _rotateController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _OrbitalPainter(
                    progress: _rotateController.value,
                    color: tc.accent.withValues(alpha: 0.04),
                  ),
                );
              },
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: GR.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: GR.sm),
                    
                    // Back button
                    GestureDetector(
                      onTap: () {
                        Haptics.light();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: GR.lg + 2,
                        height: GR.lg + 2,
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 1),
                          border: Border.all(color: tc.border),
                        ),
                        child: Icon(Icons.arrow_back_rounded, size: GR.iconSm, color: tc.textPrimary),
                      ),
                    ),

                    SizedBox(height: GR.xl + GR.md),

                    // Hero icon — matches landing screen
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseController.value * 0.04);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: tc.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(GR.radiusLg + 8),
                              ),
                              child: Icon(
                                _otpSent ? Icons.lock_outline_rounded : Icons.phone_android_rounded,
                                size: 36,
                                color: tc.accent,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 0.ms, duration: 600.ms)
                        .scale(
                          begin: const Offset(0.5, 0.5),
                          end: const Offset(1.0, 1.0),
                          delay: 0.ms,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),

                    SizedBox(height: GR.xl),

                    // Title
                    Text(
                      _otpSent ? l10n.enterOTPTitle : l10n.phoneLoginTitle,
                      style: AppTextStyles.h1(context),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 100.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 600.ms, curve: Curves.easeOutCubic),
                    
                    SizedBox(height: GR.sm),
                    
                    Text(
                      _otpSent
                          ? l10n.otpSentTo('$_countryCode ${_phoneCtrl.text}')
                          : l10n.phoneLoginSubtitle,
                      style: AppTextStyles.body(context, color: tc.textSecondary),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 150.ms, duration: 600.ms)
                        .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 600.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.xl + GR.md),

                    // Phone input
                    if (!_otpSent) ...[
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _showCountryPicker,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: GR.md, vertical: GR.md + 4),
                              decoration: BoxDecoration(
                                color: tc.cardBg,
                                borderRadius: BorderRadius.circular(GR.radiusMd),
                                border: Border.all(color: tc.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _countryCode,
                                    style: AppTextStyles.body(context, weight: FontWeight.w600),
                                  ),
                                  SizedBox(width: GR.xs),
                                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: tc.textSecondary),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: GR.sm),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: GR.md),
                              decoration: BoxDecoration(
                                color: tc.cardBg,
                                borderRadius: BorderRadius.circular(GR.radiusMd),
                                border: Border.all(color: tc.border),
                              ),
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.done,
                                style: AppTextStyles.body(context),
                                decoration: InputDecoration(
                                  hintText: l10n.mobileNumber,
                                  hintStyle: AppTextStyles.body(context, color: tc.textMuted),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: GR.md + 4),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                onSubmitted: (_) => _sendOTP(),
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                      SizedBox(height: GR.lg),

                      Container(
                        padding: EdgeInsets.symmetric(horizontal: GR.md),
                        decoration: BoxDecoration(
                          color: tc.cardBg,
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.border),
                        ),
                        child: TextField(
                          controller: _nameCtrl,
                          textInputAction: TextInputAction.done,
                          style: AppTextStyles.body(context),
                          decoration: InputDecoration(
                            hintText: l10n.yourNameOptional,
                            hintStyle: AppTextStyles.body(context, color: tc.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: GR.md + 4),
                          ),
                        ),
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(delay: 300.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 500.ms, curve: Curves.easeOutCubic),
                    ] else ...[
                      // OTP input — 6 individual boxes with auto-focus
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return _OtpBox(
                            controller: _otpCtrls[index],
                            focusNode: _otpFocusNodes[index],
                            index: index,
                            onChanged: (value) => _onOtpDigitChanged(index, value),
                            onBackspace: () => _onOtpBackspace(index),
                          );
                        }),
                      )
                          .animate(controller: _entranceCtrl)
                          .fadeIn(delay: 200.ms, duration: 500.ms)
                          .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                      SizedBox(height: GR.lg),

                      Center(
                        child: _resendSeconds > 0
                            ? Text(
                                l10n.resendCode(_resendSeconds),
                                style: AppTextStyles.bodySmall(context, color: tc.textMuted),
                              )
                            : GestureDetector(
                                onTap: _sendOTP,
                                child: Text(
                                  l10n.resendOTP,
                                  style: AppTextStyles.bodySmall(
                                    context,
                                    color: tc.accent,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ],

                    SizedBox(height: GR.lg),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: EdgeInsets.all(GR.md),
                        decoration: BoxDecoration(
                          color: tc.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.error.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 16, color: tc.error),
                            SizedBox(width: GR.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: AppTextStyles.caption(context, color: tc.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: GR.lg),
                    ],

                    // Demo mode notice
                    if (_demoOtp != null && _otpSent) ...[
                      Container(
                        padding: EdgeInsets.all(GR.md),
                        decoration: BoxDecoration(
                          color: tc.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          border: Border.all(color: tc.accent.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 16, color: tc.accent),
                            SizedBox(width: GR.sm),
                            Expanded(
                              child: Text(
                                l10n.demoModeNotice,
                                style: AppTextStyles.caption(context, color: tc.accentDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: GR.lg),
                    ],

                    // Action button
                    GestureDetector(
                      onTap: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isLoading ? tc.border : tc.accent,
                          borderRadius: BorderRadius.circular(GR.radiusMd + 3),
                        ),
                        child: Center(
                          child: _isLoading
                              ? const DotMatrixLoading(color: Colors.white)
                              : Text(
                                  _otpSent ? l10n.verifyOTP : l10n.sendOTP,
                                  style: AppTextStyles.body(
                                    context,
                                    weight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 400.ms, duration: 500.ms)
                        .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                    SizedBox(height: GR.lg),

                    if (_otpSent)
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Haptics.light();
                            setState(() {
                              _otpSent = false;
                              for (final c in _otpCtrls) {
                                c.clear();
                              }
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            l10n.changePhone,
                            style: AppTextStyles.bodySmall(
                              context,
                              color: tc.textMuted,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: GR.xxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Move to next box
      if (index < 5) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
      }
      // Check if all filled
      final otp = _otpCtrls.map((c) => c.text).join();
      if (otp.length == 6) {
        Haptics.light();
        _verifyOTP();
      }
    }
  }

  void _onOtpBackspace(int index) {
    if (_otpCtrls[index].text.isEmpty && index > 0) {
      _otpCtrls[index - 1].clear();
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
    }
  }
}

// ─── OTP Box Widget ──────────────────────────────────────────────────────────

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int index;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.index,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: tc.cardBg,
        borderRadius: BorderRadius.circular(GR.radiusMd),
        border: Border.all(
          color: _isFocused ? tc.accent : tc.border,
          width: _isFocused ? 2 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.h2(context),
          decoration: const InputDecoration(
            border: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.isEmpty) {
              widget.onBackspace();
            } else {
              widget.onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

// ─── Orbital Background Painter — matches landing screen exactly ─────────────
class _OrbitalPainter extends CustomPainter {
  final double progress;
  final Color color;

  _OrbitalPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 3);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 3; i++) {
      final radius = 80.0 + i * 60;
      final offset = progress * math.pi * 2 * (i % 2 == 0 ? 1 : -1);
      canvas.drawCircle(
        center + Offset(math.cos(offset) * 10, math.sin(offset) * 10),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitalPainter old) => old.progress != progress;
}
