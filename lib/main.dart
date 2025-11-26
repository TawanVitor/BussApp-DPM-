import 'package:flutter/material.dart';
import 'package:bussv1/core/theme/app_theme.dart';
import 'package:bussv1/features/onboarding/presentation/pages/onboarding_flow.dart';
import 'package:bussv1/features/settings/data/models/user_settings_model.dart';

// ignore: unused_import
import 'package:bussv1/features/bus_schedules/data/datasources/seed_data.dart';
import 'features/settings/domain/entities/user_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await UserSettingsModel.load();
  
  // Adicionar dados de exemplo se necessário
  await BusSchedulesSeedData.seedIfEmpty();
  
  runApp(BussApp(initialSettings: settings));
}
class BussApp extends StatefulWidget {
  final UserSettingsModel initialSettings;

  const BussApp({super.key, required this.initialSettings});

  @override
  State<BussApp> createState() => _BussAppState();
}

class _BussAppState extends State<BussApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late UserSettingsModel _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initialSettings;
    _initThemeMode();
  }

  void _initThemeMode() {
    setState(() {
      _themeMode = _settings.isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
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

  Future<void> _updateSettings(UserSettings newSettings) async {
    try {
      setState(() => _settings = newSettings as UserSettingsModel);
      await _settings.save();
      print('Configurações atualizadas com sucesso');
    } catch (e) {
      print('Erro ao atualizar configurações: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    }
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
