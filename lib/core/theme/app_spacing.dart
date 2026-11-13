import 'package:flutter/material.dart';

/// Four-point spacing scale and shape tokens.
class AppSpacing {
  AppSpacing._();
  static const double s4 = 4, s8 = 8, s12 = 12, s16 = 16, s20 = 20, s24 = 24, s32 = 32, s40 = 40, s48 = 48;
  static const double screenH = 20;
  static const double maxContentWidth = 720;
}

class AppRadius {
  AppRadius._();
  static const double button = 12, buttonSmall = 10, input = 12, card = 16, feature = 20, sheet = 24;
}

class AppShadows {
  AppShadows._();
  static const card = [BoxShadow(color: Color(0x14172438), blurRadius: 18, offset: Offset(0, 8))];
  static const hero = [BoxShadow(color: Color(0x4D287FE8), blurRadius: 28, offset: Offset(0, 14))];
}

/// Animation durations (zero when the user prefers reduced motion).
class AppMotion {
  AppMotion._();
  static Duration small(BuildContext c) => _d(c, 160);
  static Duration page(BuildContext c) => _d(c, 250);
  static Duration _d(BuildContext c, int ms) =>
      MediaQuery.disableAnimationsOf(c) ? Duration.zero : Duration(milliseconds: ms);
}
