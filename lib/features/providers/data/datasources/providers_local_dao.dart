import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/provider.dart';
import '../models/provider_model.dart';
import '../mappers/provider_mapper.dart';
import 'i_providers_local_datasource.dart';

/// 💾 Interface para acesso a dados locais de Providers
///
/// Define o contrato para persistência local (cache).
/// Implementações podem usar SharedPreferences, SQLite, Hive, etc.
abstract class IProvidersLocalDao {
  /// 📥 Obtém todos os providers do cache
  Future<List<ProviderModel>> listAll();

  /// 🔍 Obtém um provider pelo ID
  Future<ProviderModel?> getById(String id);

  /// ➕ Insere um novo provider
  Future<void> insert(ProviderModel model);

  /// ✏️ Atualiza um provider existente
  Future<void> update(ProviderModel model);

  /// 🔄 Insere ou atualiza (upsert)
  Future<void> upsert(ProviderModel model);

  /// 📦 Insere ou atualiza múltiplos providers (bulk)
  Future<void> upsertAll(List<ProviderModel> models);

  /// 🗑️ Deleta um provider pelo ID
  Future<bool> delete(String id);

  /// 🧹 Limpa todo o cache
  Future<void> clear();
}

/// 📱 Implementação usando SharedPreferences
///
/// Armazena providers em JSON no cache do dispositivo.
///
/// **Estrutura no SharedPreferences:**
/// ```
/// Key: "providers_cache"
/// Value: JSON string com array de providers
/// ```
///
/// **Exemplo de dados armazenados:**
/// ```json
/// [
///   {
///     "id": "prov-123",
///     "name": "João Silva",
///     "image_uri": "https://...",
///     "distance_km": 5.2,
///     "created_at": "2025-01-10T10:30:00.000Z",
///     "updated_at": "2025-01-10T10:30:00.000Z",
///     "is_active": true
///   }
/// ]
/// ```
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Este DAO trabalha com DTOs (ProviderModel), não com entidades de domínio
/// - A conversão DTO <-> Domain é responsabilidade do Mapper
/// - Sempre converta com ProviderMapper na fronteira da UI
class ProvidersLocalDaoSharedPrefs implements IProvidersLocalDao {
  /// Chave para armazenar providers no SharedPreferences
  static const String _providersKey = 'providers_cache';

  /// Instância singleton do SharedPreferences
  late SharedPreferences _prefs;

  /// Inicializa o DAO (deve ser chamado antes de usar)
  ///
  /// **Exemplo:**
  /// ```dart
  /// final dao = ProvidersLocalDaoSharedPrefs();
  /// await dao.init();
  /// final providers = await dao.listAll();
  /// ```
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 📥 Obtém todos os providers do cache
  ///
  /// **Fluxo:**
  /// 1. Lê string JSON do SharedPreferences
  /// 2. Decodifica JSON → List<Map>
  /// 3. Converte cada Map para ProviderModel
  /// 4. Retorna List<ProviderModel>
  ///
  /// **Log esperado:**
  /// ```
  /// [DAO] Carregados 5 providers do cache
  /// ```
  ///
  /// **Checklist:**
  /// ❌ Cache não inicializado → Chame init() primeiro
  /// ❌ JSON inválido no cache → Trata gracefully, retorna lista vazia
  @override
  Future<List<ProviderModel>> listAll() async {
    try {
      final jsonString = _prefs.getString(_providersKey) ?? '[]';
      final jsonList = jsonDecode(jsonString) as List<dynamic>;

      return jsonList
          .map((json) => ProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // 🚨 Erro ao decodificar JSON → provavelmente dados corrompidos
      print('[ProvidersDAO] ❌ Erro ao carregar providers: $e');
      return [];
    }
  }

  /// 🔍 Obtém um provider pelo ID
  ///
  /// **Retorna:**
  /// - ProviderModel se encontrado
  /// - null se não encontrado
  ///
  /// **Exemplo:**
  /// ```dart
  /// final provider = await dao.getById('prov-123');
  /// if (provider != null) {
  ///   print('Encontrado: ${provider.name}');
  /// }
  /// ```
  @override
  Future<ProviderModel?> getById(String id) async {
    final list = await listAll();
    try {
      return list.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// ➕ Insere um novo provider
  ///
  /// Adiciona o provider à lista sem verificar se já existe.
  /// Use `upsert()` se quiser atualizar se já existe.
  @override
  Future<void> insert(ProviderModel model) async {
    final list = await listAll();
    list.add(model);
    await _saveAll(list);
  }

  /// ✏️ Atualiza um provider existente
  ///
  /// Se não encontrar um com o mesmo ID, não faz nada.
  /// Use `upsert()` para inserir se não existir.
  @override
  Future<void> update(ProviderModel model) async {
    final list = await listAll();
    final index = list.indexWhere((p) => p.id == model.id);
    if (index >= 0) {
      list[index] = model;
      await _saveAll(list);
    }
  }

  /// 🔄 Insere ou atualiza um provider
  ///
  /// Se já existe (mesmo ID), atualiza.
  /// Se não existe, insere no final.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final provider = ProviderModel(...);
  /// await dao.upsert(provider);  // Insere ou atualiza
  /// ```
  @override
  Future<void> upsert(ProviderModel model) async {
    final list = await listAll();
    final index = list.indexWhere((p) => p.id == model.id);
    if (index >= 0) {
      list[index] = model;
    } else {
      list.add(model);
    }
    await _saveAll(list);
  }

  /// 📦 Insere ou atualiza múltiplos providers (bulk operation)
  ///
  /// Útil durante sincronização com Supabase.
  /// Otimizado: lê uma vez, aplica todas as alterações, salva uma vez.
  ///
  /// **Exemplo (durante sync):**
  /// ```dart
  /// final remoteProviders = await supabase.from('providers').select();
  /// final dtoList = remoteProviders.map(ProviderModel.fromJson).toList();
  /// await dao.upsertAll(dtoList);  // Aplica todas
  /// ```
  ///
  /// **Log esperado:**
  /// ```
  /// [DAO] Upsertados 42 providers em bulk
  /// ```
  @override
  Future<void> upsertAll(List<ProviderModel> models) async {
    final list = await listAll();

    for (final model in models) {
      final index = list.indexWhere((p) => p.id == model.id);
      if (index >= 0) {
        list[index] = model;
      } else {
        list.add(model);
      }
    }

    await _saveAll(list);
  }

  /// 🗑️ Deleta um provider pelo ID
  ///
  /// **Retorna:**
  /// - true se deletado
  /// - false se não encontrado
  ///
  /// **Exemplo:**
  /// ```dart
  /// final deleted = await dao.delete('prov-123');
  /// if (deleted) {
  ///   print('Deletado com sucesso');
  /// }
  /// ```
  @override
  Future<bool> delete(String id) async {
    final list = await listAll();
    final initialLength = list.length;
    list.removeWhere((p) => p.id == id);

    if (list.length < initialLength) {
      await _saveAll(list);
      return true;
    }
    return false;
  }

  /// 🧹 Limpa todo o cache
  ///
  /// Remove a chave de providers do SharedPreferences.
  /// Após chamar isso, listAll() retornará lista vazia.
  ///
  /// ⚠️ Cuidado: Operação irreversível!
  @override
  Future<void> clear() async {
    await _prefs.remove(_providersKey);
  }

  /// 💾 Salva a lista de providers no cache (interno)
  ///
  /// Converte List<ProviderModel> → JSON string → SharedPreferences
  Future<void> _saveAll(List<ProviderModel> list) async {
    try {
      final jsonList = list.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await _prefs.setString(_providersKey, jsonString);
    } catch (e) {
      print('[ProvidersDAO] ❌ Erro ao salvar providers: $e');
      rethrow;
    }
  }
}
