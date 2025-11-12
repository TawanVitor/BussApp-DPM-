import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  String name;
  String? photoPath;
  bool isDarkMode;
  double textSize;
  bool useHighContrast;

  UserSettings({
    this.name = 'Usuário',
    this.photoPath,
    this.isDarkMode = false,
    this.textSize = 1.0,
    this.useHighContrast = false,
  });

  static const _storageKey = 'user_settings';

  Map<String, dynamic> toJson() => {
        'name': name,
        'photoPath': photoPath,
        'isDarkMode': isDarkMode,
        'textSize': textSize,
        'useHighContrast': useHighContrast,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        name: json['name'] as String? ?? 'Usuário',
        photoPath: json['photoPath'] as String?,
        isDarkMode: json['isDarkMode'] as bool? ?? false,
        textSize: json['textSize'] as double? ?? 1.0,
        useHighContrast: json['useHighContrast'] as bool? ?? false,
      );

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(toJson()));
  }

  static Future<UserSettings> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) return UserSettings();
      return UserSettings.fromJson(json.decode(jsonStr));
    } catch (e) {
      return UserSettings();
    }
  }
}