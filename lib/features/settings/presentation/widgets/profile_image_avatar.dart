import 'dart:io';
import 'package:flutter/material.dart';

/// Widget para exibir imagem de perfil com fallback e tratamento de erro
class ProfileImageAvatar extends StatelessWidget {
  final String? imagePath;
  final double radius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ProfileImageAvatar({
    Key? key,
    required this.imagePath,
    this.radius = 50,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Se não tem caminho, mostra ícone padrão
    if (imagePath == null || imagePath!.isEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ??
              Theme.of(context).colorScheme.primary.withAlpha(51),
          child: Icon(
            Icons.person,
            size: radius * 1.5,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    // Verifica se arquivo existe
    final file = File(imagePath!);
    
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ??
            Theme.of(context).colorScheme.primary.withAlpha(51),
        backgroundImage: file.existsSync()
            ? FileImage(file) as ImageProvider
            : null,
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint(
            'Erro ao carregar imagem de perfil: $exception\n'
            'Caminho: $imagePath',
          );
        },
        child: !file.existsSync()
            ? Icon(
                Icons.broken_image,
                size: radius * 1.5,
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
    );
  }
}
