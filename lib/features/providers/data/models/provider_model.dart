/// 🔌 Provider Data Transfer Object (DTO)
///
/// Representa o formato de armazenamento de providers na persistência (SharedPreferences e Supabase).
/// Este é o contrato de dados com a camada de persistência.
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - DTO é diferente da entidade Provider (domain entity).
/// - Use ProviderModel apenas na camada de dados.
/// - Na UI, sempre converta para Provider usando ProviderMapper.toEntity().
/// - Para persistir, converta Provider para ProviderModel usando ProviderMapper.toDto().
///
/// **Exemplo de fluxo:**
/// ```
/// Supabase JSON → fromJson → ProviderModel (DTO)
///                              ↓
///                         ProviderMapper.toEntity()
///                              ↓
///                         Provider (Domain Entity)
///                              ↓
///                           Mostrar na UI
/// ```
///
/// Conversão reversa para persistência:
/// ```
/// Provider (Domain Entity)
///         ↓
///   ProviderMapper.toDto()
///         ↓
///   ProviderModel (DTO)
///         ↓
///   toJson() → SharedPreferences ou Supabase
/// ```
class ProviderModel {
  /// Identificador único (UUID)
  final String id;

  /// Nome do provedor
  final String name;

  /// URL da imagem (armazenada como string)
  final String? imageUri;

  /// Distância em km
  final double distanceKm;

  /// Data de criação (ISO 8601 string)
  final String createdAt;

  /// Data da última atualização (ISO 8601 string)
  final String updatedAt;

  /// Status ativo/inativo
  final bool isActive;

  /// Construtor do DTO
  const ProviderModel({
    required this.id,
    required this.name,
    required this.imageUri,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// 🔄 Cria um ProviderModel a partir de um Map (ex: JSON do Supabase)
  ///
  /// **Exemplo de JSON esperado:**
  /// ```json
  /// {
  ///   "id": "prov-123",
  ///   "name": "João Silva",
  ///   "image_uri": "https://example.com/profile.jpg",
  ///   "distance_km": 5.2,
  ///   "created_at": "2025-01-10T10:30:00.000Z",
  ///   "updated_at": "2025-01-10T10:30:00.000Z",
  ///   "is_active": true
  /// }
  /// ```
  ///
  /// ⚠️ Note: Usa snake_case do servidor, converte para camelCase local
  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      imageUri: json['image_uri'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// 📤 Converte o DTO para um Map (JSON)
  ///
  /// Usa snake_case para manter compatibilidade com Supabase.
  /// Retorna:
  /// ```dart
  /// {
  ///   "id": "prov-123",
  ///   "name": "João Silva",
  ///   "image_uri": "https://...",
  ///   ...
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_uri': imageUri,
      'distance_km': distanceKm,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'is_active': isActive,
    };
  }

  /// 🔄 Copia o DTO com alguns campos opcionalmente alterados
  ProviderModel copyWith({
    String? id,
    String? name,
    String? imageUri,
    double? distanceKm,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
  }) {
    return ProviderModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUri: imageUri ?? this.imageUri,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// ✅ Igualdade por ID
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProviderModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProviderModel(id: $id, name: $name, isActive: $isActive)';
}
