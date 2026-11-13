import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static TextStyle _f(double size, FontWeight w, double lineHeightPx,
          {Color color = AppColors.textPrimary, double letterSpacing = 0}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: w, height: lineHeightPx / size, color: color, letterSpacing: letterSpacing);

  // One family everywhere (Plus Jakarta Sans). Mapping: headlineLarge=Display, headlineMedium=H1,
  // headlineSmall=H2, titleLarge=H3, bodyLarge=Body, bodyMedium=Body small, bodySmall=Caption, labelLarge=Button.
  static TextTheme textTheme() {
    final base = GoogleFonts.plusJakartaSansTextTheme()
        .apply(bodyColor: AppColors.textPrimary, displayColor: AppColors.textPrimary);
    return base.copyWith(
      headlineLarge: _f(32, FontWeight.w800, 40, letterSpacing: -0.7),
      headlineMedium: _f(26, FontWeight.w800, 33, letterSpacing: -0.5),
      headlineSmall: _f(22, FontWeight.w700, 29, letterSpacing: -0.3),
      titleLarge: _f(18, FontWeight.w700, 25, letterSpacing: -0.2),
      titleMedium: _f(16, FontWeight.w600, 22),
      bodyLarge: _f(16, FontWeight.w400, 24),
      bodyMedium: _f(14, FontWeight.w400, 21),
      bodySmall: _f(12, FontWeight.w400, 18, color: AppColors.textSecondary),
      labelLarge: _f(15, FontWeight.w600, 20),
    );
  }

  static ThemeData light() {
    final text = textTheme();
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button));
    OutlineInputBorder inputBorder(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(color: c, width: w),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryDark,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: shape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: shape,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary, textStyle: text.labelLarge),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: text.bodyLarge?.copyWith(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: inputBorder(AppColors.border),
        enabledBorder: inputBorder(AppColors.border),
        focusedBorder: inputBorder(AppColors.primary, 1.5),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        elevation: 0,
        height: 68,
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
      ),
      dividerColor: AppColors.border,
    );
  }
}
