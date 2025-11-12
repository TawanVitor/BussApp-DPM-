import 'package:flutter/material.dart';
import 'core/Features/Onboarding/pages/onboarding_flow.dart';
import 'core/Models/user_settings.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await UserSettings.load();
  runApp(BussApp(initialSettings: settings));
}

class BussApp extends StatefulWidget {
  final UserSettings initialSettings;

  const BussApp({super.key, required this.initialSettings});

  @override
  State<BussApp> createState() => _BussAppState();
}

class _BussAppState extends State<BussApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late UserSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
  }

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

  void _updateSettings(UserSettings newSettings) async {
    setState(() => _settings = newSettings);
    await newSettings.save();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buss',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: _themeMode,
      home: OnboardingFlow(
        onThemeToggle: _toggleTheme,
        themeMode: _themeMode,
        settings: _settings,
        onSettingsChanged: _updateSettings,
      ),
    );
  }
}
