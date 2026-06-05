import 'package:flutter/material.dart';

class LowStockBadge extends StatelessWidget {
  final int stockCount;
  final int frequency;

  const LowStockBadge({
    super.key,
    required this.stockCount,
    required this.frequency,
  });

  bool get isLow => stockCount <= frequency * 3;

  @override
  Widget build(BuildContext context) {
    if (!isLow) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFE0B2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 11,
            color: Color(0xFFF57C00),
          ),
          const SizedBox(width: 4),
          Text(
            '$stockCount left',
            style: const TextStyle(
              color: Color(0xFFEF6C00),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Artific',
            ),
          ),
        ],
      ),
    );
  }
}
