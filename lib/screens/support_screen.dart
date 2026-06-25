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

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceCtrl;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
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

  @override
  Widget build(BuildContext context) {
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
                    const Text(
                      'Support',
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Haptics.light(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _cardBorder),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          size: 20,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 0.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, delay: 0.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 24),

                // ── Beta Access Card ─────────────────────────────────
                _SupportCard(
                  title: 'Get Beta Access',
                  description: 'Get early access to new features before they\'re released. Try updates first, share your feedback, and help shape the future of the app.',
                  icon: Icons.rocket_launch_rounded,
                  iconBg: _orange.withValues(alpha: 0.1),
                  iconColor: _orange,
                  delay: 100,
                  controller: _entranceCtrl,
                  onTap: () => Haptics.medium(),
                ),

                const SizedBox(height: 16),

                // ── Divider ──────────────────────────────────────────
                const Divider(height: 1, color: _cardBorder)
                    .animate(controller: _entranceCtrl)
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 16),

                // ── MyTherapy Team Card ──────────────────────────────
                _SupportCard(
                  title: 'Matra Team',
                  description: 'Need help or experienced an issue? We are here to support you. Reach out to our team for assistance.',
                  icon: Icons.support_agent_rounded,
                  iconBg: _accentLight.withValues(alpha: 0.4),
                  iconColor: _accentDark,
                  delay: 300,
                  controller: _entranceCtrl,
                  onTap: () => Haptics.medium(),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Support Card ────────────────────────────────────────────────────────────
class _SupportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int delay;
  final AnimationController controller;
  final VoidCallback onTap;

  const _SupportCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.delay,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: _textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate(controller: controller)
        .fadeIn(delay: Duration(milliseconds: delay), duration: 600.ms)
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay), duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
