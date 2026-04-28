import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary       = Color(0xFFE41E24);
  static const Color accent        = Color(0xFF003D7A);
  static const Color background    = Color(0xFFF8FAFC);
  static const Color card          = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border        = Color(0xFFE5E7EB);
  static const Color success       = Color(0xFF10B981);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color error         = Color(0xFFEF4444);
  static const Color starColor     = Color(0xFFFBBF24);
  static const Color darkBg        = Color(0xFF111827);
  static const Color darkCard      = Color(0xFF1F2937);
  static const Color darkBorder    = Color(0xFF374151);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark  => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final base   = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: b,
        primary: primary, onPrimary: Colors.white,
        secondary: accent, onSecondary: Colors.white,
        error: error, onError: Colors.white,
        surface: isDark ? darkCard : card,
        onSurface: isDark ? Colors.white : textPrimary,
      ),
      scaffoldBackgroundColor: isDark ? darkBg : background,
      cardColor: isDark ? darkCard : card,
      dividerColor: isDark ? darkBorder : border,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: isDark ? Colors.white : textPrimary,
        displayColor: isDark ? Colors.white : textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? darkCard : card,
        foregroundColor: isDark ? Colors.white : textPrimary,
        elevation: 0, centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? darkCard : card,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? darkCard : card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? darkBorder : border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? darkBorder : border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}