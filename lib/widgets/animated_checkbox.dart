import 'package:flutter/material.dart';
import '../utils/haptics.dart';

class AnimatedCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const AnimatedCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.toggle();
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: progress > 0.5
                  ? const Color(0xFF4CAF50).withValues(alpha: progress)
                  : Colors.transparent,
              border: Border.all(
                color: progress > 0.5
                    ? const Color(0xFF4CAF50).withValues(alpha: progress)
                    : const Color(0xFFDDDDDD),
                width: 2,
              ),
            ),
            child: progress > 0.3
                ? Icon(
                    Icons.check_rounded,
                    color: Colors.white.withValues(alpha: (progress - 0.3) / 0.7),
                    size: widget.size * 0.55,
                  )
                : null,
          );
        },
      ),
    );
  }
}
