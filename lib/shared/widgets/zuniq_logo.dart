import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class ZuniqSymbol extends StatelessWidget {
  const ZuniqSymbol({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) =>
      SvgPicture.asset('assets/brand/zuniq_symbol.svg', height: size, semanticsLabel: 'ZUNIQ');
}

class ZuniqWordmark extends StatelessWidget {
  const ZuniqWordmark({super.key, this.size = 28});
  final double size;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ZuniqSymbol(size: size),
          SizedBox(width: size * 0.3),
          Text(
            'ZUNIQ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: size * 0.82,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
}
