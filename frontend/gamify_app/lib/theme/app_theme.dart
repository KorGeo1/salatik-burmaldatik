import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFFE8002D);
  static const Color primaryDark = Color(0xFFB8001F);
  static const Color primaryLight = Color(0xFFFF1744);
  static const Color background = Color(0xFFF2F3F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Gamification Colors
  static const Color gold = Color(0xFFFFB800);
  static const Color silver = Color(0xFF9E9E9E);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color xpBlue = Color(0xFF2979FF);
  static const Color questGreen = Color(0xFF00C853);
  static const Color legendaryPurple = Color(0xFF7C4DFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFFB0B7C3);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        textTheme: GoogleFonts.manropeTextTheme().copyWith(
          displayLarge: GoogleFonts.manrope(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textPrimary,
          ),
          displayMedium: GoogleFonts.manrope(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: textPrimary,
          ),
          bodyMedium: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            textStyle: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          hintStyle: GoogleFonts.manrope(
            color: textHint,
            fontSize: 15,
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      );
}