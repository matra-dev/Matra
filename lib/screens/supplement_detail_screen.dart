import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/supplement_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_colors.dart';
import '../utils/app_date_utils.dart' as app_date;
import '../utils/haptics.dart';
import 'supplement_form_screen.dart';

class SupplementDetailScreen extends ConsumerStatefulWidget {
  final Supplement supplement;

  const SupplementDetailScreen({super.key, required this.supplement});

  @override
  ConsumerState<SupplementDetailScreen> createState() => _SupplementDetailScreenState();
}

class _SupplementDetailScreenState extends ConsumerState<SupplementDetailScreen>
    with TickerProviderStateMixin {
  int _totalDoses = 0;
  List<_DayData> _weeklyData = [];
  bool _loadingStats = true;

  late final AnimationController _chartController;
  late final AnimationController _pageController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadStats();
    _pageController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final allLogs = await ref.read(localStorageProvider).getDoseLogs();
      final logs = allLogs.where((l) => l.supplementId == widget.supplement.id).toList();
      final now = DateTime.now();
      final days = <_DayData>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr = app_date.DateUtils.formatDate(date.toIso8601String().split('T')[0]);
        final count = logs.where((l) => l.date == dateStr).length;
        days.add(_DayData(
          dayLabel: ['M', 'T', 'W', 'T', 'F', 'S', 'S'][6 - i],
          fullDate: dateStr,
          count: count,
          isToday: i == 0,
        ));
      }

      setState(() {
        _totalDoses = logs.length;
        _weeklyData = days;
        _loadingStats = false;
      });

      _chartController.forward(from: 0);
    } catch (e) {
      setState(() => _loadingStats = false);
    }
  }

  Future<void> _deleteSupplement() async {
    Haptics.heavy();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Supplement?'),
        content: Text('Are you sure you want to delete "${widget.supplement.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(supplementsProvider.notifier).deleteSupplement(widget.supplement.id);
      if (mounted) {
        Navigator.pop(context);
        Haptics.success();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supplement = widget.supplement;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFFFAFAFA),
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1A1A1A)),
            ),
            leadingWidth: 56,
          ),

          // Header
          SliverToBoxAdapter(
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.medication_rounded,
                      size: 28,
                      color: Color(0xFF4A90D9),
                    ),
                  )
                      .animate(controller: _pageController)
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 14),
                  Text(
                    supplement.name,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate(controller: _pageController)
                      .fadeIn(delay: 100.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0, delay: 100.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 4),
                  Text(
                    supplement.dosageText,
                    style: const TextStyle(
                      fontFamily: 'Artific',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFAAAAAA),
                    ),
                  )
                      .animate(controller: _pageController)
                      .fadeIn(delay: 180.ms, duration: 400.ms)
                      .slideY(begin: 0.15, end: 0, delay: 180.ms, duration: 400.ms, curve: Curves.easeOutCubic),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _AnimatedStatCard(
                        label: 'Days Active',
                        value: supplement.daysSinceStart,
                        icon: Icons.calendar_today_rounded,
                        color: const Color(0xFF4A90D9),
                        delay: 250,
                        pageController: _pageController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatCard(
                        label: 'Total Doses',
                        value: _totalDoses,
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF4CAF50),
                        delay: 350,
                        pageController: _pageController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _AnimatedStatCard(
                        label: 'Stock',
                        value: supplement.stockCount,
                        icon: Icons.inventory_2_rounded,
                        color: supplement.isLowStock ? const Color(0xFFF9A825) : const Color(0xFFFF9800),
                        delay: 450,
                        pageController: _pageController,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Linear Area Chart Card
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last 7 Days',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: _loadingStats
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : _weeklyData.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No data yet',
                                      style: TextStyle(
                                        fontFamily: 'Artific',
                                        fontSize: 13,
                                        color: Color(0xFFBBBBBB),
                                      ),
                                    ),
                                  )
                                : _AnimatedAreaChart(
                                    data: _weeklyData,
                                    chartController: _chartController,
                                  ),
                      ),
                    ],
                  ),
                )
                    .animate(controller: _pageController)
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, delay: 500.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _DetailRow(
                        icon: Icons.repeat_rounded,
                        label: 'Frequency',
                        value: '${supplement.frequency}x per day',
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 44, top: 12, bottom: 12),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      _DetailRow(
                        icon: Icons.schedule_rounded,
                        label: 'Time Slots',
                        value: supplement.timeSlots.join(', '),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 44, top: 12, bottom: 12),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),
                      _DetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Started',
                        value: app_date.DateUtils.formatDate(supplement.startDate),
                      ),
                      if (supplement.isLowStock) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFF9A825),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Only ${supplement.stockCount} doses remaining',
                                  style: const TextStyle(
                                    fontFamily: 'Artific',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFF9A825),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                    .animate(controller: _pageController)
                    .fadeIn(delay: 600.ms, duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, delay: 600.ms, duration: 500.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 20),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Haptics.medium();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SupplementFormScreen(supplement: supplement),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Edit',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: _deleteSupplement,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: AppColors.danger.withValues(alpha: 0.7), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontFamily: 'Artific',
                                  color: AppColors.danger.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    .animate(controller: _pageController)
                    .fadeIn(delay: 700.ms, duration: 400.ms)
                    .slideY(begin: 0.1, end: 0, delay: 700.ms, duration: 400.ms, curve: Curves.easeOutCubic),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated Stat Card ───
class _AnimatedStatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final int delay;
  final AnimationController pageController;

  const _AnimatedStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        final v = pageController.value;
        final d = delay / 1000;
        final p = ((v - d) * 3.0).clamp(0.0, 1.0);
        final e = 1 - (1 - p) * (1 - p);
        return Opacity(
          opacity: e,
          child: Transform.translate(offset: Offset(0, (1 - e) * 16), child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: value),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, val, _) {
                return Text(
                  '$val',
                  style: TextStyle(
                    fontFamily: 'Artific',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: -0.5,
                  ),
                );
              },
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Artific',
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayData {
  final String dayLabel;
  final String fullDate;
  final int count;
  final bool isToday;

  _DayData({
    required this.dayLabel,
    required this.fullDate,
    required this.count,
    required this.isToday,
  });
}

// ─── Animated Linear Area Chart with Gradient ───
class _AnimatedAreaChart extends StatelessWidget {
  final List<_DayData> data;
  final AnimationController chartController;

  const _AnimatedAreaChart({
    required this.data,
    required this.chartController,
  });

  @override
  Widget build(BuildContext context) {
    final maxY = data.map((d) => d.count).reduce((a, b) => a > b ? a : b).toDouble();
    final safeMaxY = maxY < 1 ? 2.0 : maxY + 0.5;

    return AnimatedBuilder(
      animation: chartController,
      builder: (context, child) {
        final progress = chartController.value;

        return LineChart(
          LineChartData(
            minX: 0,
            maxX: (data.length - 1).toDouble(),
            minY: 0,
            maxY: safeMaxY,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: safeMaxY > 2 ? (safeMaxY / 2).ceil().toDouble() : 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: const Color(0xFFF0F0F0),
                  strokeWidth: 1,
                  dashArray: [4, 4],
                );
              },
            ),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= data.length) return const SizedBox.shrink();
                    final day = data[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        day.dayLabel,
                        style: TextStyle(
                          fontFamily: 'Artific',
                          fontSize: 12,
                          fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
                          color: day.isToday ? const Color(0xFF1A1A1A) : const Color(0xFFBBBBBB),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 10,
                tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                getTooltipColor: (_) => const Color(0xFF1A1A1A),
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final day = data[spot.x.toInt()];
                    return LineTooltipItem(
                      '${day.count} dose${day.count == 1 ? '' : 's'}',
                      const TextStyle(
                        fontFamily: 'Artific',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList();
                },
              ),
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    FlLine(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                    FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 5,
                          color: Colors.white,
                          strokeWidth: 2.5,
                          strokeColor: const Color(0xFF4CAF50),
                        );
                      },
                    ),
                  );
                }).toList();
              },
            ),
            lineBarsData: [
              LineChartBarData(
                spots: data.asMap().entries.map((e) {
                  final idx = e.key;
                  final day = e.value;
                  final animatedY = day.count * progress;
                  return FlSpot(idx.toDouble(), animatedY.toDouble());
                }).toList(),
                isCurved: true,
                curveSmoothness: 0.35,
                preventCurveOverShooting: true,
                barWidth: 3,
                color: const Color(0xFF4CAF50),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF4CAF50).withValues(alpha: 0.25 * progress),
                      const Color(0xFF4CAF50).withValues(alpha: 0.05 * progress),
                      const Color(0xFF4CAF50).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                dotData: FlDotData(
                  show: progress > 0.7,
                  getDotPainter: (spot, percent, bar, index) {
                    final day = data[index];
                    return FlDotCirclePainter(
                      radius: day.isToday ? 5 : 3.5,
                      color: Colors.white,
                      strokeWidth: day.isToday ? 2.5 : 2,
                      strokeColor: day.count > 0
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFDDDDDD),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF888888)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAAAAAA),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Artific',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
