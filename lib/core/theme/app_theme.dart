import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4338CA);
  static const secondary = Color(0xFF84CC16);
  static const background = Color(0xFFF8FAFC);
  static const darkBackground = Color(0xFF181A20);
  static const surface = Colors.white;
  static const darkSurface = Color(0xFF23263A);
  static const onBackground = Color(0xFF475569);
}

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4338CA),
        secondary: Color(0xFF84CC16),
        background: Colors.white,
        onBackground: Colors.black87,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4338CA),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF84CC16),
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4338CA),
        secondary: Color(0xFF84CC16),
        background: Color(0xFF121212),
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF4338CA),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF84CC16),
        foregroundColor: Colors.black,
      ),
    );
  }
}
