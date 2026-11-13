import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Soft blue glow shapes behind content, echoing the ZUNIQ brand sheet.
class SoftBackground extends StatelessWidget {
  const SoftBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned(top: -110, right: -90, child: IgnorePointer(child: _Glow(280))),
          const Positioned(top: 300, left: -140, child: IgnorePointer(child: _Glow(260))),
          child,
        ],
      );
}

class _Glow extends StatelessWidget {
  const _Glow(this.size);
  final double size;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [AppColors.glow, Color(0x00287FE8)]),
        ),
      );
}
