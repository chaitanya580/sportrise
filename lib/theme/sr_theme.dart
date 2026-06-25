import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SRColors {
  // Brand
  static const navy      = Color(0xFF0D1B2A);
  static const navyLight = Color(0xFF132336);
  static const orange    = Color(0xFFFF6B2B);
  static const gold      = Color(0xFFFFB830);

  // Semantic
  static const success = Color(0xFF1E8449);
  static const error   = Color(0xFFC0392B);
  static const muted   = Color(0xFF8FA3B8);
  static const line    = Color(0x1AFFFFFF);

  // Level colors
  static const levelColors = [
    Color(0xFF8FA3B8), // L1 Rookie
    Color(0xFF27AE60), // L2 Contender
    Color(0xFF2980B9), // L3 Challenger
    Color(0xFF8E44AD), // L4 Competitor
    Color(0xFF2E86DE), // L5 Elite
    Color(0xFFE67E22), // L6 Champion
    Color(0xFFFFB830), // L7 National Prospect
  ];
}

class SRTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: SRColors.navy,
      colorScheme: const ColorScheme.dark(
        primary:   SRColors.orange,
        secondary: SRColors.gold,
        surface:   SRColors.navyLight,
        error:     SRColors.error,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
        headlineMedium: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        titleLarge:  GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge:   GoogleFonts.inter(fontSize: 15, color: Colors.white),
        bodyMedium:  GoogleFonts.inter(fontSize: 14, color: SRColors.muted),
        labelLarge:  GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x0DFFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SRColors.orange, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SRColors.error),
        ),
        labelStyle: GoogleFonts.inter(color: SRColors.muted, fontSize: 14),
        hintStyle:  GoogleFonts.inter(color: const Color(0xFF5D7A96), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SRColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: SRColors.navy,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: SRColors.navyLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1AFFFFFF)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SRColors.navyLight,
        selectedItemColor: SRColors.orange,
        unselectedItemColor: SRColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: SRColors.navyLight,
        contentTextStyle: GoogleFonts.inter(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
