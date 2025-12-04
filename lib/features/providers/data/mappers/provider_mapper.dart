import '../../domain/entities/provider.dart';
import '../models/provider_model.dart';

/// 🗺️ ProviderMapper - Conversor entre camadas de dados e domínio
///
/// **PADRÃO DIDÁTICO CRÍTICO:**
/// Este mapper é a chave para desacoplar a UI da persistência.
/// Toda conversão DTO <-> Domain passa por aqui.
///
/// **Por que?**
/// - A UI trabalha com entidades de domínio (Provider)
/// - A persistência trabalha com DTOs (ProviderModel)
/// - O mapper concentra a lógica de conversão em um único lugar
/// - Mudanças no DTO não afetam a UI
/// - Mudanças na UI não afetam a persistência
///
/// **Fluxo visual:**
///
/// ```
/// LEITURA (Persistência → UI):
/// ┌─────────────────┐
/// │  Supabase JSON  │ (ou SharedPreferences)
/// └────────┬────────┘
///          │ fromJson()
///          ↓
/// ┌─────────────────┐
/// │  ProviderModel  │ DTO (dados brutos)
/// │    (DTO)        │
/// └────────┬────────┘
///          │ toEntity()
///          ↓
/// ┌─────────────────┐
/// │  Provider       │ Entidade de domínio
/// │  (Domain)       │
/// └────────┬────────┘
///          │
///          ↓
///      [UI Layer]
///
///
/// ESCRITA (UI → Persistência):
/// ┌─────────────────┐
/// │  Provider       │ Entidade de domínio
/// │  (Domain)       │
/// └────────┬────────┘
///          │ toDto()
///          ↓
/// ┌─────────────────┐
/// │  ProviderModel  │ DTO (dados brutos)
/// │    (DTO)        │
/// └────────┬────────┘
///          │ toJson()
///          ↓
/// ┌─────────────────┐
/// │  Supabase JSON  │ Salvo na persistência
/// └─────────────────┘
/// ```
///
/// **Exemplo de uso em código:**
/// ```dart
/// // Leitura (JSON da API → Entidade)
/// final json = await supabase.from('providers').select().limit(1).single();
/// final model = ProviderModel.fromJson(json);
/// final entity = ProviderMapper.toEntity(model);  // ← Uso aqui
///
/// // Escrita (Entidade → JSON para salvar)
/// final entity = Provider(id: '123', name: 'João', ...);
/// final model = ProviderMapper.toDto(entity);  // ← Uso aqui
/// await dao.upsert(model);
/// ```
abstract class ProviderMapper {
  /// 🔄 Converte um DTO (ProviderModel) para uma entidade de domínio (Provider)
  ///
  /// **ENTRADA:** ProviderModel com campos em formato de persistência
  /// **SAÍDA:** Provider com campos prontos para lógica de negócio e UI
  ///
  /// ⚠️ IMPORTANTE DIDÁTICO:
  /// - Use esta função sempre que ler dados do Supabase ou cache
  /// - Garante que a UI sempre trabalhe com entidades de domínio válidas
  /// - Centraliza a conversão em um único ponto (fácil de debugar)
  ///
  /// **Transformações:**
  /// - createdAt: String (ISO 8601) → DateTime
  /// - updatedAt: String (ISO 8601) → DateTime
  /// - Todos os outros campos: cópia direta
  ///
  /// **Checklist de erros:**
  /// ❌ Usar ProviderModel diretamente na UI → Sempre converter com toEntity()
  /// ❌ Esquecer de converter DateTime → Será string, causará erro de tipo
  /// ❌ Passar null para campos required → Gera erro no runtime
  ///
  /// **Log esperado:**
  /// ```dart
  /// if (kDebugMode) {
  ///   print('[ProviderMapper.toEntity] Convertendo ProviderModel: ${model.id}');
  /// }
  /// ```
  static Provider toEntity(ProviderModel model) {
    // 📌 Conversão de DateTime: string ISO 8601 → DateTime Dart
    // Exemplo: "2025-01-10T10:30:00.000Z" → DateTime object
    final createdAtDateTime = DateTime.tryParse(model.createdAt) ?? DateTime.now();
    final updatedAtDateTime = DateTime.tryParse(model.updatedAt) ?? DateTime.now();

    return Provider(
      id: model.id,
      name: model.name,
      imageUri: model.imageUri,
      distanceKm: model.distanceKm,
      createdAt: createdAtDateTime,
      updatedAt: updatedAtDateTime,
      isActive: model.isActive,
    );
  }

  /// 🔄 Converte uma entidade de domínio (Provider) para um DTO (ProviderModel)
  ///
  /// **ENTRADA:** Provider com campos de domínio
  /// **SAÍDA:** ProviderModel pronto para persistência
  ///
  /// Use esta função quando:
  /// - Salvar um novo provider na UI
  /// - Editar um provider existente
  /// - Deletar um provider (precisa do DTO para DAO)
  ///
  /// **Transformações:**
  /// - createdAt: DateTime → String (ISO 8601)
  /// - updatedAt: DateTime → String (ISO 8601)
  /// - Todos os outros campos: cópia direta
  ///
  /// **Exemplo:**
  /// ```dart
  /// // Na UI, após o usuário editar um provider
  /// final updatedEntity = provider.copyWith(name: 'Novo Nome');
  /// final model = ProviderMapper.toDto(updatedEntity);
  /// await dao.upsert(model);  // Salva no cache
  /// ```
  ///
  /// **Log esperado:**
  /// ```dart
  /// if (kDebugMode) {
  ///   print('[ProviderMapper.toDto] Convertendo Provider: ${entity.id}');
  /// }
  /// ```
  static ProviderModel toDto(Provider entity) {
    // 📌 Conversão de DateTime: DateTime Dart → string ISO 8601
    // Exemplo: DateTime(2025, 1, 10, 10, 30) → "2025-01-10T10:30:00.000Z"
    final createdAtString = entity.createdAt.toIso8601String();
    final updatedAtString = entity.updatedAt.toIso8601String();

    return ProviderModel(
      id: entity.id,
      name: entity.name,
      imageUri: entity.imageUri,
      distanceKm: entity.distanceKm,
      createdAt: createdAtString,
      updatedAt: updatedAtString,
      isActive: entity.isActive,
    );
  }

  /// 🔄 Converte uma lista de DTOs para uma lista de entidades
  ///
  /// **Sintaxe:**
  /// ```dart
  /// final dtoList = [model1, model2, model3];
  /// final entityList = ProviderMapper.toDomainList(dtoList);
  /// ```
  ///
  /// Internamente usa `map()` + `toEntity()` para cada item.
  static List<Provider> toDomainList(List<ProviderModel> models) {
    return models.map(toEntity).toList();
  }

  /// 🔄 Converte uma lista de entidades para uma lista de DTOs
  ///
  /// **Sintaxe:**
  /// ```dart
  /// final entityList = [provider1, provider2, provider3];
  /// final dtoList = ProviderMapper.toDtoList(entityList);
  /// ```
  ///
  /// Internamente usa `map()` + `toDto()` para cada item.
  static List<ProviderModel> toDtoList(List<Provider> entities) {
    return entities.map(toDto).toList();
  }
}
