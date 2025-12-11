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

  Future<void> _updateSettings() async {
    final newSettings = UserSettingsModel(
      name: widget.settings.name,
      photoPath: widget.settings.photoPath,
      isDarkMode: widget.settings.isDarkMode,
      textSize: _textSize,
      useHighContrast: _useHighContrast,
    );
    
    try {
      await newSettings.save();
      widget.onSettingsChanged(newSettings);
      
      if (mounted) {
        debugPrint('✓ Configurações de acessibilidade atualizadas');
      }
    } catch (e) {
      debugPrint('Erro ao salvar acessibilidade: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acessibilidade')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ========== Seção: Tamanho do Texto ==========
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tamanho do Texto',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajuste o tamanho da fonte em toda a aplicação',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _textSize,
                          min: 0.8,
                          max: 1.4,
                          divisions: 6,
                          label: '${(_textSize * 100).toStringAsFixed(0)}%',
                          onChanged: (value) {
                            setState(() => _textSize = value);
                            _updateSettings();
                          },
                        ),
                      ),
                      Text(
                        '${(_textSize * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Preview do texto
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Visualização do texto com tamanho ajustado',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14 * _textSize,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // ========== Seção: Alto Contraste ==========
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alto Contraste',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Usa cores vibrantes para melhor visibilidade',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _useHighContrast,
                        onChanged: (value) {
                          setState(() => _useHighContrast = value);
                          _updateSettings();
                          
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _useHighContrast
                                      ? '✓ Alto contraste ativado'
                                      : '✓ Alto contraste desativado',
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (_useHighContrast) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Alto contraste ativado. Reinicie a app para aplicar mudanças completas.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // ========== Info Acessibilidade ==========
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.accessibility,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Configurações de Acessibilidade',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Essas configurações são salvas automaticamente e sincronizadas em toda a aplicação.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
