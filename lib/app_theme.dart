// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NexTradeColors {
  // Primary Palette - Deep Space Dark
  static const Color background = Color(0xFF050A0F);
  static const Color surface = Color(0xFF0D1520);
  static const Color surfaceElevated = Color(0xFF111D2C);
  static const Color surfaceHighlight = Color(0xFF162234);

  // Accent - Electric Cyan/Teal
  static const Color primary = Color(0xFF00E5CC);
  static const Color primaryDim = Color(0xFF00B5A0);
  static const Color primaryGlow = Color(0x3300E5CC);

  // Secondary - Amber Gold
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryDim = Color(0xFFD97706);

  // Semantic
  static const Color profit = Color(0xFF00E5A0);
  static const Color loss = Color(0xFFFF4D6A);
  static const Color profitBg = Color(0x1500E5A0);
  static const Color lossBg = Color(0x15FF4D6A);
  static const Color neutral = Color(0xFF94A3B8);
  static const Color warning = Color(0xFFF59E0B);

  // Text
  static const Color textPrimary = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color textMuted = Color(0xFF4A6070);
  static const Color textAccent = Color(0xFF00E5CC);

  // Borders
  static const Color border = Color(0xFF1A2D40);
  static const Color borderLight = Color(0xFF243547);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5CC), Color(0xFF0066FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient profitGradient = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B5CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lossGradient = LinearGradient(
    colors: [Color(0xFFFF4D6A), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0D1520), Color(0xFF111D2C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050A0F), Color(0xFF080F1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: NexTradeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: NexTradeColors.primary,
        secondary: NexTradeColors.secondary,
        surface: NexTradeColors.surface,
        onPrimary: NexTradeColors.background,
        onSecondary: NexTradeColors.background,
        onSurface: NexTradeColors.textPrimary,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme().copyWith(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: NexTradeColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: NexTradeColors.textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: NexTradeColors.surface,
        selectedItemColor: NexTradeColors.primary,
        unselectedItemColor: NexTradeColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: NexTradeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NexTradeColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NexTradeColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NexTradeColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: NexTradeColors.loss),
        ),
        hintStyle: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textMuted,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.spaceGrotesk(
          color: NexTradeColors.textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: NexTradeColors.primary,
          foregroundColor: NexTradeColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: NexTradeColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: NexTradeColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: NexTradeColors.border,
        thickness: 1,
      ),
    );
  }
}