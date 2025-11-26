import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_settings.dart' show UserSettings;

class UserSettingsModel extends UserSettings {
  const UserSettingsModel({
    required String name,
    String? photoPath,
    required bool isDarkMode,
    required double textSize,
    required bool useHighContrast,
  }) : super(
         name: name,
         photoPath: photoPath,
         isDarkMode: isDarkMode,
         textSize: textSize,
         useHighContrast: useHighContrast,
       );

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
      name: json['name'] as String? ?? 'Usuário',
      photoPath: json['photoPath'] as String?,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      textSize: (json['textSize'] as num?)?.toDouble() ?? 1.0,
      useHighContrast: json['useHighContrast'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'photoPath': photoPath,
    'isDarkMode': isDarkMode,
    'textSize': textSize,
    'useHighContrast': useHighContrast,
  };

  static Future<UserSettingsModel> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('user_settings');

      if (jsonStr == null || jsonStr.isEmpty) {
        return const UserSettingsModel(
          name: 'Usuário',
          photoPath: null,
          isDarkMode: false,
          textSize: 1.0,
          useHighContrast: false,
        );
      }

      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return UserSettingsModel.fromJson(json);
    } catch (e) {
      print('Erro ao carregar configurações: $e');
      return const UserSettingsModel(
        name: 'Usuário',
        photoPath: null,
        isDarkMode: false,
        textSize: 1.0,
        useHighContrast: false,
      );
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(toJson());
      await prefs.setString('user_settings', jsonString);
      print('Configurações salvas com sucesso');
    } catch (e) {
      print('Erro ao salvar configurações: $e');
      rethrow;
    }
  }
}
