import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryPink = Color(0xFFFF1493);
  static const Color backgroundBlack = Color(0xFF171717);
  static const Color surfaceDark = Color(0xFF444444);
  static const Color textWhite = Color(0xFFEDEDED);
  static const Color textGrey = Colors.grey;

  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: backgroundBlack,
      primaryColor: primaryPink,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: textWhite, displayColor: textWhite),
    );
  }
}
