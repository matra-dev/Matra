import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';
import '../utils/haptics.dart';
import 'supplement_detail_screen.dart';
import 'supplement_form_screen.dart';

class MySupplementsScreen extends ConsumerStatefulWidget {
  const MySupplementsScreen({super.key});

  @override
  ConsumerState<MySupplementsScreen> createState() => _MySupplementsScreenState();
}

class _MySupplementsScreenState extends ConsumerState<MySupplementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supplementsAsync = ref.watch(supplementsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: supplementsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, stack) => Center(child: Text('Error: $err')),
          data: (supplements) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Stack',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -0.8,
                                ),
                              ).animate().fadeIn(duration: 500.ms).slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${supplements.length} supplement${supplements.length == 1 ? '' : 's'} in your stack',
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF999999),
                                ),
                              ).animate(delay: 80.ms).fadeIn(duration: 500.ms).slideY(
                                begin: 0.15,
                                end: 0,
                                duration: 500.ms,
                                curve: Curves.easeOutCubic,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Haptics.medium();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SupplementFormScreen()),
                            );
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ).animate(delay: 150.ms).fadeIn(duration: 400.ms).scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                          curve: Curves.easeOutBack,
                        ),
                      ],
                    ),
                  ),
                ),

                // Divider
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                  ),
                ),

                // Supplement list with smooth staggered animation
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final supplement = supplements[index];
                        return _AnimatedSupplementCard(
                          supplement: supplement,
                          index: index,
                          listController: _listController,
                          onTap: () {
                            Haptics.light();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SupplementDetailScreen(supplement: supplement),
                              ),
                            );
                          },
                        );
                      },
                      childCount: supplements.length,
                    ),
                  ),
                ),

                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedSupplementCard extends StatelessWidget {
  final Supplement supplement;
  final int index;
  final AnimationController listController;
  final VoidCallback onTap;

  const _AnimatedSupplementCard({
    required this.supplement,
    required this.index,
    required this.listController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = supplement.isLowStock;
    final itemDelay = Duration(milliseconds: 200 + (index * 80));

    return AnimatedBuilder(
      animation: listController,
      builder: (context, child) {
        final animationValue = listController.value;
        final delaySeconds = itemDelay.inMilliseconds / 1000;
        final rawProgress = (animationValue - delaySeconds) * 3.0;
        final itemProgress = rawProgress.clamp(0.0, 1.0);
        final easedProgress = 1 - (1 - itemProgress) * (1 - itemProgress);

        return Opacity(
          opacity: easedProgress,
          child: Transform.translate(
            offset: Offset(0, (1 - easedProgress) * 20),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
          ),
          child: Row(
            children: [
              // Icon with subtle background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.medication_outlined,
                  size: 22,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(width: 16),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplement.name,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          supplement.dosageText,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Color(0xFFCCCCCC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${supplement.frequency}x/day',
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Low stock badge
              if (isLow)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFE082), width: 1),
                  ),
                  child: Text(
                    '${supplement.stockCount} left',
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF9A825),
                    ),
                  ),
                ),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
