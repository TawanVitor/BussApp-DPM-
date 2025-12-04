/// 📦 Provider Domain Entity
///
/// Representa um provedor de serviços (ex: motorista, mecânico, etc.)
/// Esta é a entidade de DOMÍNIO, usada em toda a lógica de negócio e UI.
///
/// ⚠️ IMPORTANTE: Não use ProviderDto (DTO) diretamente na UI.
/// Sempre converta DTO -> Provider na fronteira de persistência usando ProviderMapper.
///
/// Exemplo de uso:
/// ```dart
/// final provider = Provider(
///   id: '123',
///   name: 'João Silva',
///   imageUri: 'https://example.com/profile.jpg',
///   distanceKm: 5.2,
/// );
/// ```
class Provider {
  /// Identificador único do provedor (UUID)
  final String id;

  /// Nome do provedor
  final String name;

  /// URI da imagem de perfil/logo
  final String? imageUri;

  /// Distância em km até o provedor (calculada em tempo real)
  final double distanceKm;

  /// Data de criação do registro
  final DateTime createdAt;

  /// Data da última atualização
  final DateTime updatedAt;

  /// Status do provedor (ativo/inativo)
  final bool isActive;

  /// Construtor da entidade Provider
  ///
  /// Todos os campos são required para garantir integridade dos dados.
  /// Use [ProviderMapper.toEntity] para construir a partir de um DTO.
  const Provider({
    required this.id,
    required this.name,
    required this.imageUri,
    required this.distanceKm,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  /// 🔄 Copia a entidade com alguns campos opcionalmente alterados
  ///
  /// Útil para atualizar um provider mantendo os outros campos.
  /// Exemplo: `provider.copyWith(name: 'Novo Nome')`
  Provider copyWith({
    String? id,
    String? name,
    String? imageUri,
    double? distanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUri: imageUri ?? this.imageUri,
      distanceKm: distanceKm ?? this.distanceKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  /// ✅ Verifica igualdade entre providers (por ID)
  ///
  /// Dois providers são iguais se têm o mesmo ID.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Provider && runtimeType == other.runtimeType && id == other.id;

  /// Hash code baseado no ID
  @override
  int get hashCode => id.hashCode;

  /// Representação em string para debug
  @override
  String toString() {
    return 'Provider('
        'id: $id, '
        'name: $name, '
        'distanceKm: $distanceKm, '
        'isActive: $isActive'
        ')';
  }
}
