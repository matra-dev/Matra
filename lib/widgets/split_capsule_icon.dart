import 'package:flutter/material.dart';
import '../utils/haptics.dart';
import '../theme/app_text_styles.dart';

/// Clean pill checkbox — simple outline → checkmark
///
/// Unchecked: gray outlined pill
/// Checked: teal outlined pill with subtle fill + checkmark
class SplitCapsuleIcon extends StatefulWidget {
  final bool checked;
  final VoidCallback onTap;
  final double size;

  const SplitCapsuleIcon({
    super.key,
    required this.checked,
    required this.onTap,
    this.size = 40,
  });

  @override
  State<SplitCapsuleIcon> createState() => _SplitCapsuleIconState();
}

class _SplitCapsuleIconState extends State<SplitCapsuleIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.checked) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(SplitCapsuleIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _ctrl.animateTo(1.0, curve: Curves.easeOutCubic);
      } else {
        _ctrl.animateTo(0.0, curve: Curves.easeInCubic);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.toggle();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final p = _ctrl.value;
            final borderColor = Color.lerp(
              tc.textMuted.withValues(alpha: 0.4),
              tc.accent,
              p,
            )!;
            final fillColor = Color.lerp(
              Colors.transparent,
              tc.accent.withValues(alpha: 0.12),
              p,
            )!;
            final checkOpacity = p;

            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: 1.8,
                ),
              ),
              child: Center(
                child: Opacity(
                  opacity: checkOpacity,
                  child: Icon(
                    Icons.check_rounded,
                    size: widget.size * 0.45,
                    color: tc.accent,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
