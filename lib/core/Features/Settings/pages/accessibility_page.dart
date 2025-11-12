import 'package:flutter/material.dart';
import '../../../Models/user_settings.dart';

class AccessibilityPage extends StatelessWidget {
  final UserSettings settings;
  final Function(UserSettings) onSettingsChanged;

  const AccessibilityPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessibilidade'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Tamanho do texto'),
            subtitle: Slider(
              value: settings.textSize,
              min: 0.8,
              max: 1.4,
              divisions: 3,
              label: '${(settings.textSize * 100).round()}%',
              onChanged: (value) {
                onSettingsChanged(
                  UserSettings(
                    name: settings.name,
                    photoPath: settings.photoPath,
                    isDarkMode: settings.isDarkMode,
                    textSize: value,
                    useHighContrast: settings.useHighContrast,
                  ),
                );
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Alto contraste'),
            subtitle: const Text('Aumenta o contraste das cores'),
            value: settings.useHighContrast,
            onChanged: (value) {
              onSettingsChanged(
                UserSettings(
                  name: settings.name,
                  photoPath: settings.photoPath,
                  isDarkMode: settings.isDarkMode,
                  textSize: settings.textSize,
                  useHighContrast: value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}