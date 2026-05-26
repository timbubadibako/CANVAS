import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    
    // Explicitly define text theme with weights matching the "Bulky" look
    final textTheme = GoogleFonts.openSansTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: Colors.white),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: Colors.white),
      titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: Colors.white),
      bodyLarge: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: GoogleFonts.openSans(fontWeight: FontWeight.w500, color: AppColors.slateText),
      bodySmall: GoogleFonts.openSans(fontWeight: FontWeight.w500, color: AppColors.slateMuted),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, letterSpacing: 1.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepSlate,
      textTheme: textTheme,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.studioIndigo,
        secondary: AppColors.royalViolet,
        surface: AppColors.slateCard,
        error: AppColors.deepRose,
      ),
      cardTheme: CardThemeData(
        color: AppColors.slateCard.withValues(alpha: 0.7),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.studioIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    
    final textTheme = GoogleFonts.openSansTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, color: AppColors.lightText),
      titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppColors.lightText),
      titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w800, color: AppColors.lightText),
      bodyLarge: GoogleFonts.openSans(fontWeight: FontWeight.w600, color: AppColors.lightText),
      bodyMedium: GoogleFonts.openSans(fontWeight: FontWeight.w500, color: AppColors.lightText),
      bodySmall: GoogleFonts.openSans(fontWeight: FontWeight.w500, color: AppColors.lightMuted),
      labelLarge: GoogleFonts.poppins(fontWeight: FontWeight.w900, letterSpacing: 1.2),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: AppColors.studioIndigo,
        secondary: AppColors.royalViolet,
        surface: AppColors.lightCard,
        error: AppColors.deepRose,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard.withValues(alpha: 0.8),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
          side: BorderSide(color: Colors.indigo.withValues(alpha: 0.05)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.studioIndigo,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
