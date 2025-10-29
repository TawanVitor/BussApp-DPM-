import 'package:flutter/material.dart';
import 'Pages/onboarding_flow.dart';

void main() {
  runApp(const BussApp());
}

class BussApp extends StatefulWidget {
  const BussApp({super.key});

  @override
  State<BussApp> createState() => _BussAppState();
}

class _BussAppState extends State<BussApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else if (_themeMode == ThemeMode.dark) {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.dark;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buss',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFF4338CA),
          onPrimary: Colors.white,
          secondary: const Color(0xFF84CC16),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFFF8FAFC),
          onBackground: const Color(0xFF475569),
          surface: Colors.white,
          onSurface: const Color(0xFF475569),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4338CA),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF84CC16),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.dark,
          primary: const Color(0xFF4338CA),
          onPrimary: Colors.white,
          secondary: const Color(0xFF84CC16),
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
          background: const Color(0xFF181A20),
          onBackground: Colors.white,
          surface: const Color(0xFF23263A),
          onSurface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4338CA),
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF84CC16),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: OnboardingFlow(
        onThemeToggle: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}
