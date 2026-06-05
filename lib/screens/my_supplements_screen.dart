import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';
import '../utils/haptics.dart';
import 'supplement_detail_screen.dart';
import 'supplement_form_screen.dart';

class MySupplementsScreen extends ConsumerWidget {
  const MySupplementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'My Stack',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                  letterSpacing: -0.5,
                                ),
                              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                              const SizedBox(height: 4),
                              Text(
                                '${supplements.length} supplement${supplements.length == 1 ? '' : 's'}',
                                style: const TextStyle(
                                  fontFamily: 'Artific',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF999999),
                                ),
                              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, curve: Curves.easeOutCubic),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final supplement = supplements[index];
                        return _SupplementCard(
                          supplement: supplement,
                          index: index,
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

class _SupplementCard extends StatelessWidget {
  final Supplement supplement;
  final int index;
  final VoidCallback onTap;

  const _SupplementCard({
    required this.supplement,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = supplement.isLowStock;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medication_outlined,
                size: 20,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplement.name,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${supplement.dosageText} · ${supplement.frequency}x/day',
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF999999),
                    ),
                  ),
                ],
              ),
            ),
            if (isLow)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFFE082), width: 1),
                ),
                child: Text(
                  '${supplement.stockCount} left',
                  style: const TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF9A825),
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    ).animate(delay: (100 + index * 60).ms).fadeIn(duration: 400.ms).slideY(
      begin: 0.15,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }
}
