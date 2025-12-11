import 'package:flutter/material.dart';
import 'package:bussv1/features/settings/data/models/user_settings_model.dart';
import 'package:bussv1/features/settings/data/services/profile_image_service.dart';

/// Debug page para testar a funcionalidade de perfil
class SettingsDebugPage extends StatefulWidget {
  const SettingsDebugPage({Key? key}) : super(key: key);

  @override
  State<SettingsDebugPage> createState() => _SettingsDebugPageState();
}

class _SettingsDebugPageState extends State<SettingsDebugPage> {
  UserSettingsModel? _loadedSettings;
  String? _profileImagePath;
  String _debugLog = '';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      _addLog('Carregando configurações...');
      
      final settings = await UserSettingsModel.load();
      final imagePath = await ProfileImageService.getProfileImagePath();
      
      setState(() {
        _loadedSettings = settings;
        _profileImagePath = imagePath;
      });
      
      _addLog('✓ Configurações carregadas');
      _addLog('Nome: ${settings.name}');
      _addLog('Foto: ${imagePath ?? "Nenhuma"}');
      _addLog('Modo escuro: ${settings.isDarkMode}');
      _addLog('Tamanho texto: ${settings.textSize}');
      _addLog('Alto contraste: ${settings.useHighContrast}');
    } catch (e) {
      _addLog('✗ Erro: $e');
    }
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().split('.')[0];
      _debugLog += '\n[$timestamp] $message';
    });
    debugPrint(message);
  }

  Future<void> _testSaveSettings() async {
    try {
      _addLog('Testando salvar configurações...');
      
      final testSettings = UserSettingsModel(
        name: 'Usuário Teste ${DateTime.now().millisecond}',
        photoPath: _profileImagePath,
        isDarkMode: false,
        textSize: 1.0,
        useHighContrast: false,
      );
      
      await testSettings.save();
      _addLog('✓ Configurações salvas');
      
      // Recarrega para verificar
      await _loadSettings();
    } catch (e) {
      _addLog('✗ Erro ao salvar: $e');
    }
  }

  void _clearLog() {
    setState(() {
      _debugLog = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações carregadas
                  if (_loadedSettings != null) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Configurações Atuais',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Nome: ${_loadedSettings!.name}'),
                            Text('Foto: ${_profileImagePath != null ? "Salva" : "Nenhuma"}'),
                            Text('Modo Escuro: ${_loadedSettings!.isDarkMode}'),
                            Text('Tamanho Texto: ${_loadedSettings!.textSize}'),
                            Text('Alto Contraste: ${_loadedSettings!.useHighContrast}'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Log de debug
                  const Text(
                    'Log de Debug',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _debugLog.isEmpty
                          ? 'Nenhum log ainda'
                          : _debugLog,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botões de ação
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loadSettings,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Recarregar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _testSaveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Testar Salvar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _clearLog,
                    icon: const Icon(Icons.delete),
                    label: const Text('Limpar Log'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
