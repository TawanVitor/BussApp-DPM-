import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bussv1/features/settings/domain/entities/user_settings.dart';
import 'package:bussv1/features/settings/data/models/user_settings_model.dart';
import 'package:bussv1/features/settings/data/services/profile_image_service.dart';
import 'package:bussv1/features/settings/presentation/widgets/user_profile_card.dart';
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
  void didUpdateWidget(SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza o nome se mudar
    if (oldWidget.settings.name != widget.settings.name) {
      _nameController.text = widget.settings.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// Constrói o avatar de perfil com validação
  Widget _buildProfileAvatar(double radius) {
    final photoPath = widget.settings.photoPath;
    
    // Se não tem foto, mostra ícone padrão
    if (photoPath == null || photoPath.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
        child: Icon(
          Icons.person,
          size: radius * 1.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }

    // Verifica se o arquivo existe
    final file = File(photoPath);
    if (!file.existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.broken_image,
          size: radius * 1.5,
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    // Tenta carregar a imagem
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(51),
      backgroundImage: FileImage(file),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Erro ao carregar imagem: $exception');
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (image != null) {
        // Salva a imagem no diretório seguro da app
        final savedImagePath = await ProfileImageService.saveProfileImage(image.path);
        
        if (savedImagePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erro ao salvar imagem')),
            );
          }
          return;
        }

        // Cria novo objeto de settings com a imagem
        final newSettings = UserSettingsModel(
          name: _nameController.text.isNotEmpty 
              ? _nameController.text 
              : widget.settings.name,
          photoPath: savedImagePath,
          isDarkMode: widget.settings.isDarkMode,
          textSize: widget.settings.textSize,
          useHighContrast: widget.settings.useHighContrast,
        );
        
        // Salva as configurações
        await newSettings.save();
        
        // Notifica a mudança
        widget.onSettingsChanged(newSettings);
        
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Foto de perfil atualizada com sucesso!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao selecionar imagem: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveName(String newName) async {
    try {
      if (newName.trim().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Digite um nome válido'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final trimmedName = newName.trim();
      
      final newSettings = UserSettingsModel(
        name: trimmedName,
        photoPath: widget.settings.photoPath,
        isDarkMode: widget.settings.isDarkMode,
        textSize: widget.settings.textSize,
        useHighContrast: widget.settings.useHighContrast,
      );
      
      await newSettings.save();
      widget.onSettingsChanged(newSettings);
      
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Nome salvo: $trimmedName'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        debugPrint('✓ Nome atualizado: $trimmedName');
      }
    } catch (e) {
      debugPrint('Erro ao atualizar nome: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar nome: $e')),
        );
      }
    }
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
                  _buildProfileAvatar(50),
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
                  hintText: 'Digite seu nome',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _saveName(_nameController.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
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
        padding: const EdgeInsets.all(16),
        children: [
          UserProfileCard(
            settings: widget.settings,
            onEditProfile: () => _showProfileDialog(context),
          ),
          const SizedBox(height: 16),
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
