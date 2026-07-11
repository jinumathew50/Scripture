import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: const Color(0xFF1976D2),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1976D2),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: GoogleFonts.merriweatherTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, height: 1.6),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFF42A5F5),
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF212121),
      onBackground: Color(0xFF212121),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: const Color(0xFF90CAF9),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Color(0xFF90CAF9),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: GoogleFonts.merriweatherTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFE0E0E0)),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF90CAF9),
      secondary: Color(0xFF64B5F6),
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      onPrimary: Color(0xFF121212),
      onSecondary: Color(0xFF121212),
      onSurface: Color(0xFFE0E0E0),
      onBackground: Color(0xFFE0E0E0),
    ),
  );

  // Sepia Theme (Custom)
  static ThemeData sepiaTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primarySwatch: Colors.brown,
    primaryColor: const Color(0xFF8D6E63),
    scaffoldBackgroundColor: const Color(0xFFF4ECD8),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8D6E63),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFFFFF8E1),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: GoogleFonts.merriweatherTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF5D4037)),
        bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF5D4037)),
      ),
    ),
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF8D6E63),
      secondary: Color(0xFFBCAAA4),
      surface: Color(0xFFFFF8E1),
      background: Color(0xFFF4ECD8),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF5D4037),
      onBackground: Color(0xFF5D4037),
    ),
  );
}
