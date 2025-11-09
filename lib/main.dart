import 'package:flutter/material.dart';
import 'core/Features/Onboarding/pages/onboarding_flow.dart';
import 'core/theme/app_theme.dart';


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
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: OnboardingFlow(onThemeToggle: _toggleTheme, themeMode: _themeMode),
    );
  }
}
