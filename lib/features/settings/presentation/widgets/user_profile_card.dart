import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/user_settings.dart';

/// Widget para exibir as informações do usuário no perfil
class UserProfileCard extends StatelessWidget {
  final UserSettings settings;
  final VoidCallback? onEditProfile;

  const UserProfileCard({
    Key? key,
    required this.settings,
    this.onEditProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEditProfile,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.primary.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Imagem de perfil
              _buildProfileImage(),
              const SizedBox(height: 16),
              
              // Nome do usuário
              Text(
                settings.name.isNotEmpty ? settings.name : 'Usuário',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Descrição
              Text(
                'Clique para editar perfil',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),
              const SizedBox(height: 16),
              
              // Ícone de edição
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói a imagem de perfil com tratamento de erro
  Widget _buildProfileImage() {
    final photoPath = settings.photoPath;
    
    // Se não tem foto, mostra ícone padrão
    if (photoPath == null || photoPath.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(51),
        ),
        child: Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
        ),
      );
    }

    // Verifica se arquivo existe
    final file = File(photoPath);
    if (!file.existsSync()) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(51),
        ),
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.white70,
        ),
      );
    }

    // Mostra a imagem se arquivo existe
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        backgroundImage: FileImage(file),
        backgroundColor: Colors.white.withAlpha(51),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Erro ao carregar imagem de perfil: $exception');
        },
      ),
    );
  }
}
