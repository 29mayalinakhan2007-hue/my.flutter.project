import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography pairing for the app: a geometric, characterful
/// display face for temperature/city, and a warmer, humanist face for
/// body copy and data labels — chosen so the numbers feel confident
/// without the rest of the UI feeling cold.
class AppTheme {
  static TextTheme textTheme(Color base) {
    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 88,
        fontWeight: FontWeight.w600,
        letterSpacing: -3,
        color: base,
        height: 1.0,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: base,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: base,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: base,
      ),
      labelSmall: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: base,
      ),
    );
  }

  static ThemeData light() {
    const seed = Color(0xFF2E86DE);
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: seed,
      scaffoldBackgroundColor: const Color(0xFF0F1720),
      textTheme: textTheme(const Color(0xFF17222B)),
      splashFactory: InkRipple.splashFactory,
    );
  }
}
