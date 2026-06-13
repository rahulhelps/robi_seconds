import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
    primaryColor: const Color(0xFF024D87),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0E1112),
    primaryColor: const Color(0xFF024D87),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(elevation: 0, backgroundColor: Colors.transparent),
  );
}