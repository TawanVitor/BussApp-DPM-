import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bussv1/features/settings/domain/entities/user_settings.dart';
import 'package:bussv1/features/settings/data/models/user_settings_model.dart';
import 'accessibility_page.dart';
import 'package:bussv1/features/onboarding/presentation/pages/policy_viewer_screen.dart';

class SettingsPage extends StatefulWidget {
  final UserSettings settings;
  final Function(UserSettings) onSettingsChanged;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _imagePicker = ImagePicker();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.settings.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final newSettings = UserSettingsModel(
          name: _nameController.text,
          photoPath: image.path,
          isDarkMode: widget.settings.isDarkMode,
          textSize: widget.settings.textSize,
          useHighContrast: widget.settings.useHighContrast,
        );
        widget.onSettingsChanged(newSettings as UserSettings);
        await newSettings.save();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao selecionar imagem')),
        );
      }
    }
  }

  void _updateName(String value) async {
    final newSettings = UserSettingsModel(
      name: value,
      photoPath: widget.settings.photoPath,
      isDarkMode: widget.settings.isDarkMode,
      textSize: widget.settings.textSize,
      useHighContrast: widget.settings.useHighContrast,
    );
    widget.onSettingsChanged(newSettings as UserSettings);
    await newSettings.save();
  }

  Future<void> _showProfileDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: widget.settings.photoPath != null
                        ? FileImage(File(widget.settings.photoPath!))
                        : null,
                    child: widget.settings.photoPath == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      onPressed: _pickImage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
                onChanged: _updateName,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: widget.settings.photoPath != null
                      ? FileImage(File(widget.settings.photoPath!))
                      : null,
                  child: widget.settings.photoPath == null
                      ? const Icon(Icons.person, size: 50)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.settings.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            subtitle: const Text('Edite suas informações'),
            onTap: () => _showProfileDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.accessibility_new),
            title: const Text('Acessibilidade'),
            subtitle: const Text('Ajuste o tamanho do texto e contraste'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccessibilityPage(
                  settings: widget.settings,
                  onSettingsChanged: widget.onSettingsChanged,
                ),
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            title: const Text('Tema'),
            subtitle: Text(
              widget.themeMode == ThemeMode.dark
                  ? 'Tema escuro ativado'
                  : 'Tema claro ativado',
            ),
            onTap: widget.onThemeToggle,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Termos de Uso'),
            subtitle: const Text('Leia nossos termos'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PolicyViewerScreen(
                  title: 'Termos de Uso',
                  content: '''Termos de Uso do Aplicativo Buss

1. Descrição do Serviço
O Buss é um aplicativo móvel desenvolvido para auxiliar estudantes e usuários de transporte público a gerenciar suas rotas de ônibus.

2. Uso do Aplicativo
2.1. O aplicativo é destinado ao uso pessoal e não comercial.
2.2. Todas as informações cadastradas são armazenadas apenas localmente no dispositivo do usuário.

3. Privacidade e Proteção de Dados (LGPD)
3.1. O aplicativo segue a Lei Geral de Proteção de Dados (LGPD).
3.2. Nenhum dado é compartilhado com terceiros.
3.3. Todas as informações são armazenadas localmente.

4. Limitações de Responsabilidade
4.1. O aplicativo é fornecido "como está".
4.2. Não garantimos funcionamento ininterrupto.

5. Contato
Email: suporte@bussapp.com''',
                  themeMode: widget.themeMode,
                  onThemeToggle: widget.onThemeToggle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
