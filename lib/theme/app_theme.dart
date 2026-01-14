import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color ink = Color(0xFF0E0F12);
  static const Color inkSoft = Color(0xFF15171C);
  static const Color card = Color(0xFF1C1F26);
  static const Color cardSoft = Color(0xFF232731);
  static const Color line = Color(0xFF2C313D);
  static const Color textPrimary = Color(0xFFF4F4F6);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color accentTeal = Color(0xFF42D1B0);
  static const Color accentOrange = Color(0xFFF2A45A);
  static const Color accentRed = Color(0xFFEE6C6C);
  static const Color accentBlue = Color(0xFF6FA8FF);
  static const Color accentGold = Color(0xFFE6C26D);
  static const Color lightBackground = Color(0xFFF6F4F1);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0ECE7);
  static const Color lightMuted = Color(0xFF6B7280);
}

class AppTheme {
  static ThemeData get darkTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentTeal,
        secondary: AppColors.accentOrange,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.cardSoft,
        selectedColor: AppColors.accentTeal,
        labelStyle: const TextStyle(color: AppColors.textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.ink),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardSoft,
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.spaceGroteskTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentTeal,
        secondary: AppColors.accentOrange,
        surface: AppColors.lightSurface,
        onSurface: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      textTheme: textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightCard,
        selectedColor: AppColors.accentTeal,
        labelStyle: const TextStyle(color: Colors.black87),
        secondaryLabelStyle: const TextStyle(color: Colors.black),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        hintStyle: const TextStyle(color: AppColors.lightMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      useMaterial3: true,
    );
  }
}
