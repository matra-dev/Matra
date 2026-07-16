import '../widgets/dot_matrix_loading.dart';import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/haptics.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceCtrl.forward();
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _entranceCtrl.stop();
    _entranceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final api = ApiService();
    api.initialize();

    try {
      if (_isLogin) {
        await api.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      } else {
        await api.register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        );
      }
      Haptics.success();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } on Exception catch (e) {
      Haptics.error();
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return Scaffold(
      backgroundColor: tc.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: GR.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo / Icon
                  Icon(
                    Icons.medication_rounded,
                    size: 56,
                    color: tc.accent,
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutBack),

                  SizedBox(height: GR.lg),

                  // Title
                  Text(
                    _isLogin ? 'Welcome back' : 'Get started',
                    style: AppTextStyles.h1(context),
                    textAlign: TextAlign.center,
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.xs),

                  Text(
                    _isLogin
                        ? 'Sign in to track your supplements'
                        : 'Create an account to get started',
                    style: AppTextStyles.bodySmall(context, color: tc.textSecondary),
                    textAlign: TextAlign.center,
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 200.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.xl + 4),

                  // Name field (register only)
                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline, color: tc.textMuted),
                        filled: true,
                        fillColor: tc.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          borderSide: BorderSide(color: tc.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          borderSide: BorderSide(color: tc.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                          borderSide: BorderSide(color: tc.accent, width: 1.5),
                        ),
                      ),
                      style: TextStyle(color: tc.textPrimary),
                    )
                        .animate(controller: _entranceCtrl)
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0, delay: 300.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                    SizedBox(height: GR.md),
                  ],

                  // Email field
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: tc.textMuted),
                      filled: true,
                      fillColor: tc.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.accent, width: 1.5),
                      ),
                    ),
                    style: TextStyle(color: tc.textPrimary),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email required';
                      if (!v.contains('@')) return 'Invalid email';
                      return null;
                    },
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 350.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 350.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.md),

                  // Password field
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline, color: tc.textMuted),
                      filled: true,
                      fillColor: tc.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        borderSide: BorderSide(color: tc.accent, width: 1.5),
                      ),
                    ),
                    style: TextStyle(color: tc.textPrimary),
                    validator: (v) {
                      if (v == null || v.length < 6) return 'Min 6 characters';
                      return null;
                    },
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 400.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.md),

                  // Error message
                  if (_error != null)
                    Container(
                      padding: EdgeInsets.all(GR.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(GR.radiusMd),
                        border: Border.all(color: const Color(0xFFEF4444)),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.bodySmall(context, color: const Color(0xFFDC2626)),
                      ),
                    )
                        .animate()
                        .fadeIn(duration: 200.ms)
                        .shake(duration: 300.ms),

                  if (_error != null) SizedBox(height: GR.md),

                  // Submit button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: tc.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GR.radiusMd),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: DotMatrixLoading(
                                dotSize: 4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isLogin ? 'Sign In' : 'Create Account',
                              style: AppTextStyles.button(context, color: Colors.white),
                            ),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 450.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                  SizedBox(height: GR.lg),

                  // Toggle login/register
                  TextButton(
                    onPressed: () {
                      Haptics.light();
                      setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      });
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                      style: AppTextStyles.bodySmall(context, color: tc.accentDark),
                    ),
                  )
                      .animate(controller: _entranceCtrl)
                      .fadeIn(delay: 500.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
