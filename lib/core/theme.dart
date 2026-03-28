import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryGold = Color(0xFFD4AE6D);
  static const Color backgroundBlack = Color(0xFF171717);
  static const Color textWhite = Color(0xFFEDEDED);

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundBlack,
      primaryColor: primaryGold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGold,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textWhite, displayColor: textWhite),
    );
  }
}
