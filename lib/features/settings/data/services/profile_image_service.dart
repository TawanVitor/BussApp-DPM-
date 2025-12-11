import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar imagens de perfil do usuário
/// 
/// Responsável por:
/// 1. Salvar imagem no diretório da aplicação
/// 2. Gerenciar caminho da imagem
/// 3. Limpar imagens antigas
class ProfileImageService {
  static const String _imageFileKey = 'profile_image_filename';
  
  /// Salva uma imagem no diretório da aplicação
  /// 
  /// Copia a imagem do caminho original para um local seguro
  /// dentro do diretório temporário do dispositivo
  static Future<String?> saveProfileImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      
      // Verifica se arquivo existe
      if (!sourceFile.existsSync()) {
        throw Exception('Arquivo de origem não encontrado: $sourcePath');
      }
      
      // Usa o diretório temporário como fallback
      final tempDir = Directory.systemTemp;
      final profileDir = Directory('${tempDir.path}/bussapp/profile_images');
      
      // Cria diretório se não existir
      if (!profileDir.existsSync()) {
        await profileDir.create(recursive: true);
      }
      
      // Remove imagem anterior se existir
      await _removeOldImage();
      
      // Cria novo arquivo com nome único
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final destFile = File('${profileDir.path}/$fileName');
      
      // Copia arquivo
      await sourceFile.copy(destFile.path);
      
      // Salva referência do arquivo nas preferências
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_imageFileKey, destFile.path);
      
      debugPrint('✓ Imagem salva em: ${destFile.path}');
      return destFile.path;
    } catch (e) {
      debugPrint('✗ Erro ao salvar imagem: $e');
      rethrow;
    }
  }
  
  /// Obtém o caminho da imagem de perfil salva
  static Future<String?> getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_imageFileKey);
      
      // Verifica se arquivo ainda existe
      if (imagePath != null) {
        final file = File(imagePath);
        if (file.existsSync()) {
          return imagePath;
        } else {
          // Remove referência se arquivo não existe
          await prefs.remove(_imageFileKey);
          return null;
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Erro ao obter imagem: $e');
      return null;
    }
  }
  
  /// Remove a imagem de perfil antiga
  static Future<void> _removeOldImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final oldImagePath = prefs.getString(_imageFileKey);
      
      if (oldImagePath != null) {
        final oldFile = File(oldImagePath);
        if (oldFile.existsSync()) {
          await oldFile.delete();
          debugPrint('✓ Imagem anterior removida');
        }
      }
    } catch (e) {
      debugPrint('Aviso ao remover imagem antiga: $e');
      // Não falha se não conseguir remover
    }
  }
  
  /// Remove a imagem de perfil e limpa as preferências
  static Future<void> deleteProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imagePath = prefs.getString(_imageFileKey);
      
      if (imagePath != null) {
        final file = File(imagePath);
        if (file.existsSync()) {
          await file.delete();
        }
      }
      
      await prefs.remove(_imageFileKey);
      debugPrint('✓ Imagem de perfil deletada');
    } catch (e) {
      debugPrint('Erro ao deletar imagem: $e');
    }
  }
}
