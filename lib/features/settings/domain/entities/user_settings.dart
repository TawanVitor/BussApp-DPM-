class UserSettings {
  final String name;
  final String? photoPath;
  final bool isDarkMode;
  final double textSize;
  final bool useHighContrast;

  const UserSettings({
    required this.name,
    this.photoPath,
    required this.isDarkMode,
    required this.textSize,
    required this.useHighContrast,
  });

  UserSettings copyWith({
    String? name,
    String? photoPath,
    bool? isDarkMode,
    double? textSize,
    bool? useHighContrast,
  }) {
    return UserSettings(
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      textSize: textSize ?? this.textSize,
      useHighContrast: useHighContrast ?? this.useHighContrast,
    );
  }
}
