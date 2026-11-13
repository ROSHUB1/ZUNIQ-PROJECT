import 'package:flutter/material.dart';

import 'mascot.dart';

/// Mascot with a gentle floating motion. Static when reduced motion is on.
class FloatingMascot extends StatefulWidget {
  const FloatingMascot(this.pose, {super.key, this.size = 160, this.amplitude = 6});
  final MascotPose pose;
  final double size;
  final double amplitude;

  @override
  State<FloatingMascot> createState() => _FloatingMascotState();
}

class _FloatingMascotState extends State<FloatingMascot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        child: Mascot(widget.pose, size: widget.size),
        builder: (context, child) => Transform.translate(
          offset: Offset(0, -widget.amplitude * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
      );
}
