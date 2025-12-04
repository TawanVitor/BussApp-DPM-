import '../entities/provider.dart';

/// 📋 Interface do Repository de Providers (Domínio)
///
/// Define os contratos que qualquer implementação de repository
/// deve cumprir. A UI e a lógica de negócio usam esta interface,
/// não as implementações específicas.
///
/// Princípio: Separation of Concerns - a implementação (com Supabase, SQLite, etc)
/// fica desacoplada da interface de negócio.
///
/// ⚠️ IMPORTANTE: Esta interface trabalha APENAS com entidades de domínio (Provider),
/// nunca com DTOs. A conversão DTO <-> Domain é responsabilidade do Mapper.
///
/// Exemplo de uso na UI:
/// ```dart
/// final repository = ProvidersRepositoryImpl(...);
/// final providers = await repository.getAll();  // Retorna List<Provider>
/// ```
abstract class IProvidersRepository {
  /// 📥 Obtém todos os providers do cache local
  ///
  /// Retorna uma lista de entidades Provider (não DTOs).
  /// Esta chamada é rápida pois usa cache (SharedPreferences).
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] carregados 5 providers do cache
  /// ```
  Future<List<Provider>> getAll();

  /// 🔍 Obtém um provider pelo ID
  ///
  /// Retorna `null` se o provider não for encontrado.
  ///
  /// Exemplo:
  /// ```dart
  /// final provider = await repository.getById('prov-123');
  /// ```
  Future<Provider?> getById(String id);

  /// ➕ Cria um novo provider
  ///
  /// Recebe um [Provider] de domínio, converte para DTO, persiste e retorna
  /// a entidade com ID gerado (ou fornecido).
  ///
  /// Exemplo:
  /// ```dart
  /// final newProvider = await repository.create(providerEntity);
  /// print('Provider criado: ${newProvider.id}');
  /// ```
  Future<Provider> create(Provider provider);

  /// ✏️ Atualiza um provider existente
  ///
  /// Recebe um [Provider] com ID, converte para DTO e persiste.
  /// Retorna a entidade atualizada.
  Future<Provider> update(Provider provider);

  /// 🗑️ Deleta um provider pelo ID
  ///
  /// Remove o provider do cache local.
  /// Retorna `true` se deletado, `false` se não encontrado.
  Future<bool> delete(String id);

  /// 🔄 Sincroniza com Supabase (one-shot)
  ///
  /// Busca providers remotos do Supabase, aplica delta (novos, atualizados)
  /// ao cache local e retorna a quantidade de registros sincronizados.
  ///
  /// **Fluxo:**
  /// 1. Conecta ao Supabase
  /// 2. Busca providers remotos
  /// 3. Converte DTOs -> entidades de domínio
  /// 4. Upsert no cache local
  /// 5. Retorna quantidade de registros aplicados
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] iniciando sync com Supabase...
  /// [ProvidersRepository] sincronizados 3 providers do servidor
  /// ```
  ///
  /// Erros são capturados e re-lançados com contexto.
  Future<int> syncFromServer();
}
