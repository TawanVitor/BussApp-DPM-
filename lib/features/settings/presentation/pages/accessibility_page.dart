import 'package:flutter/material.dart';
import 'package:bussv1/features/settings/domain/entities/user_settings.dart';
import 'package:bussv1/features/settings/data/models/user_settings_model.dart';

class AccessibilityPage extends StatefulWidget {
  final UserSettings settings;
  final Function(UserSettings) onSettingsChanged;

  const AccessibilityPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  late double _textSize;
  late bool _useHighContrast;

  @override
  void initState() {
    super.initState();
    _textSize = widget.settings.textSize;
    _useHighContrast = widget.settings.useHighContrast;
  }

  void _updateSettings() {
    final newSettings = UserSettingsModel(
      name: widget.settings.name,
      photoPath: widget.settings.photoPath,
      isDarkMode: widget.settings.isDarkMode,
      textSize: _textSize,
      useHighContrast: _useHighContrast,
    );
    widget.onSettingsChanged(newSettings as UserSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: const Text('Tamanho do texto'),
            subtitle: Slider(
              value: _textSize,
              min: 0.8,
              max: 1.4,
              divisions: 3,
              label: '${(_textSize * 100).round()}%',
              onChanged: (value) {
                setState(() => _textSize = value);
                _updateSettings();
              },
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Alto contraste'),
            subtitle: const Text('Aumenta o contraste das cores'),
            value: _useHighContrast,
            onChanged: (value) {
              setState(() => _useHighContrast = value);
              _updateSettings();
            },
          ),
        ],
      ),
    );
  }
}
