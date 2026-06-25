import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/app_provider.dart';
import '../models/supplement_model.dart';
import '../utils/haptics.dart';
import 'supplement_detail_screen.dart';
import 'supplement_form_screen.dart';

enum _FilterTab { all, active, lowStock }

class MySupplementsScreen extends ConsumerStatefulWidget {
  const MySupplementsScreen({super.key});

  @override
  ConsumerState<MySupplementsScreen> createState() => _MySupplementsScreenState();
}

class _MySupplementsScreenState extends ConsumerState<MySupplementsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _listController;
  _FilterTab _selectedTab = _FilterTab.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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

  List<Supplement> _filterSupplements(List<Supplement> supplements) {
    var filtered = supplements;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) => s.name.toLowerCase().contains(query)).toList();
    }
    switch (_selectedTab) {
      case _FilterTab.active:
        return filtered.where((s) => s.stockCount > 0).toList();
      case _FilterTab.lowStock:
        return filtered.where((s) => s.isLowStock).toList();
      case _FilterTab.all:
        return filtered;
    }
  }

  void _onTabChanged(_FilterTab tab) {
    if (tab == _selectedTab) return;
    Haptics.selection();
    setState(() {
      _selectedTab = tab;
      _listController.reset();
      _listController.forward();
    });
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
          data: (allSupplements) {
            final supplements = _filterSupplements(allSupplements);
            final activeCount = allSupplements.where((s) => s.stockCount > 0).length;
            final lowStockCount = allSupplements.where((s) => s.isLowStock).length;

            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Therapy',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A1A),
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Manage your medications',
                                    style: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF999999),
                                    ),
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
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 500.ms).slideY(
                          begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutCubic,
                        ),

                        const SizedBox(height: 20),

                        // Search
                        Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 14),
                              const Icon(Icons.search_rounded, size: 18, color: Color(0xFFAAAAAA)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                      _listController.reset();
                                      _listController.forward();
                                    });
                                  },
                                  style: const TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Search medications...',
                                    hintStyle: TextStyle(
                                      fontFamily: 'Artific',
                                      fontSize: 14,
                                      color: Color(0xFFBBBBBB),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _listController.reset();
                                      _listController.forward();
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Icon(Icons.close_rounded, size: 16, color: Color(0xFFAAAAAA)),
                                  ),
                                ),
                              const SizedBox(width: 6),
                            ],
                          ),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(
                          begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic,
                        ),

                        const SizedBox(height: 16),

                        // Filter tabs
                        Row(
                          children: [
                            _FilterChip(
                              label: 'All',
                              count: allSupplements.length,
                              isSelected: _selectedTab == _FilterTab.all,
                              onTap: () => _onTabChanged(_FilterTab.all),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Active',
                              count: activeCount,
                              isSelected: _selectedTab == _FilterTab.active,
                              onTap: () => _onTabChanged(_FilterTab.active),
                            ),
                            const SizedBox(width: 8),
                            _FilterChip(
                              label: 'Low Stock',
                              count: lowStockCount,
                              isSelected: _selectedTab == _FilterTab.lowStock,
                              onTap: () => _onTabChanged(_FilterTab.lowStock),
                              accentColor: const Color(0xFFF9A825),
                            ),
                          ],
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(
                          begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic,
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ],
                    ),
                  ),
                ),

                // List
                if (supplements.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.medication_outlined,
                            size: 40,
                            color: const Color(0xFFDDDDDD),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty ? 'No matches' : 'No medications',
                            style: const TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF999999),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final supplement = supplements[index];
                          return _MedCard(
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

// ─── Filter Chip ───
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? (accentColor ?? Colors.black) : Colors.white;
    final textColor = isSelected ? Colors.white : const Color(0xFF666666);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? null : Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Artific',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Compact Medication Card ───
class _MedCard extends StatelessWidget {
  final Supplement supplement;
  final int index;
  final AnimationController listController;
  final VoidCallback onTap;

  const _MedCard({
    required this.supplement,
    required this.index,
    required this.listController,
    required this.onTap,
  });

  Color get _pillColor {
    final colors = [
      const Color(0xFF4CAF50),
      const Color(0xFF2196F3),
      const Color(0xFFFF9800),
      const Color(0xFF9C27B0),
      const Color(0xFFF44336),
      const Color(0xFF00BCD4),
      const Color(0xFF795548),
      const Color(0xFF607D8B),
    ];
    return colors[supplement.name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final isLow = supplement.isLowStock;
    final isOut = supplement.stockCount <= 0;
    final itemDelay = Duration(milliseconds: 200 + (index * 70));
    final color = _pillColor;

    return AnimatedBuilder(
      animation: listController,
      builder: (context, child) {
        final v = listController.value;
        final d = itemDelay.inMilliseconds / 1000;
        final p = ((v - d) * 3.0).clamp(0.0, 1.0);
        final e = 1 - (1 - p) * (1 - p);
        return Opacity(
          opacity: e,
          child: Transform.translate(offset: Offset(0, (1 - e) * 20), child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLow ? const Color(0xFFFFE082) : const Color(0xFFEEEEEE),
              width: isLow ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pill icon — compact 40px
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isOut ? const Color(0xFFEEEEEE) : color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  size: 20,
                  color: isOut ? const Color(0xFFBBBBBB) : color,
                ),
              ),
              const SizedBox(width: 12),

              // Text — golden ratio hierarchy: 15px name / 12px meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name — largest, boldest
                    Text(
                      supplement.name,
                      style: TextStyle(
                        fontFamily: 'Artific',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isOut ? const Color(0xFFBBBBBB) : const Color(0xFF1A1A1A),
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    // Meta row — smaller, lighter
                    Row(
                      children: [
                        Text(
                          supplement.dosageText,
                          style: TextStyle(
                            fontFamily: 'Artific',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isOut ? const Color(0xFFCCCCCC) : const Color(0xFF888888),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isOut ? const Color(0xFFDDDDDD) : const Color(0xFFCCCCCC),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Time slots as compact text
                        Expanded(
                          child: Text(
                            supplement.timeSlots.join(' · '),
                            style: TextStyle(
                              fontFamily: 'Artific',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isOut ? const Color(0xFFCCCCCC) : const Color(0xFF888888),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Right side: stock indicator + chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stock count
                  Text(
                    isOut ? '0' : '${supplement.stockCount}',
                    style: TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isOut
                          ? const Color(0xFFCCCCCC)
                          : isLow
                              ? const Color(0xFFF9A825)
                              : const Color(0xFF4CAF50),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Mini stock bar
                  SizedBox(
                    width: 32,
                    height: 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: Container(
                        color: const Color(0xFFEEEEEE),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: isOut
                              ? 0
                              : (supplement.stockCount / 30).clamp(0.0, 1.0),
                          child: Container(
                            color: isOut
                                ? const Color(0xFFCCCCCC)
                                : isLow
                                    ? const Color(0xFFF9A825)
                                    : const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFFCCCCCC),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
