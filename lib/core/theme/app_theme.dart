import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4338CA);
  static const secondary = Color(0xFF84CC16);
  static const background = Color(0xFFF8FAFC);
  static const darkBackground = Color(0xFF181A20);
  static const surface = Colors.white;
  static const darkSurface = Color(0xFF23263A);
  static const onBackground = Color(0xFF475569);
  
  // Alto Contraste
  static const highContrastPrimary = Color(0xFF000000);
  static const highContrastSecondary = Color(0xFFFFFFFF);
  static const highContrastAccent = Color(0xFF0000FF);
}

class AppTheme {
  static ThemeData lightTheme({bool useHighContrast = false}) {
    if (useHighContrast) {
      return ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0000FF), // Azul royal
          secondary: Color(0xFF000000),
          background: Color(0xFFFFFFFF),
          onBackground: Color(0xFF000000),
          surface: Color(0xFFFFFFFF),
          onSurface: Color(0xFF000000),
          error: Color(0xFFFF0000),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0000FF),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF0000FF),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          titleSmall: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF000000)),
          bodyMedium: TextStyle(color: Color(0xFF000000)),
          bodySmall: TextStyle(color: Color(0xFF000000)),
          labelLarge: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
          labelMedium: TextStyle(color: Color(0xFF000000)),
          labelSmall: TextStyle(color: Color(0xFF000000)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF000000), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF000000), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF0000FF), width: 3),
          ),
          labelStyle: TextStyle(color: Color(0xFF000000), fontWeight: FontWeight.bold),
        ),
      );
    }
    
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

  static ThemeData darkTheme({bool useHighContrast = false}) {
    if (useHighContrast) {
      return ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFFF00), // Amarelo brilhante para contraste em preto
          secondary: Color(0xFFFFFFFF),
          background: Color(0xFF000000),
          onBackground: Color(0xFFFFFFFF),
          surface: Color(0xFF1A1A1A),
          onSurface: Color(0xFFFFFFFF),
          error: Color(0xFFFF0000),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFFF00),
          foregroundColor: Color(0xFF000000),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          titleSmall: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
          bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
          bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
          labelLarge: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
          labelMedium: TextStyle(color: Color(0xFFFFFFFF)),
          labelSmall: TextStyle(color: Color(0xFFFFFFFF)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFFFFF), width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFFFF00), width: 3),
          ),
          labelStyle: TextStyle(color: Color(0xFFFFFFFF), fontWeight: FontWeight.bold),
        ),
      );
    }
    
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
