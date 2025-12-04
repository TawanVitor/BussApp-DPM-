import 'package:flutter/foundation.dart';

import '../../data/datasources/providers_local_dao.dart';
import '../../data/mappers/provider_mapper.dart';
import '../../domain/entities/provider.dart';
import '../../domain/repositories/provider_repository.dart';
import '../../infrastructure/remote/supabase_providers_remote_datasource.dart';

/// 🏢 Implementação do Repository de Providers
///
/// Este é o orquestrador central de dados.
/// Gerencia tanto o cache local quanto a sincronização com Supabase.
///
/// **Responsabilidades:**
/// 1. Ler/escrever no cache local (DAO)
/// 2. Sincronizar com servidor remoto (Remote API)
/// 3. Converter entre DTOs e entidades de domínio (Mapper)
/// 4. Implementar lógica de negócio (ex: upsert inteligente)
///
/// **Fluxo de dados:**
/// ```
/// UI → Repository → (Mapper) → DAO/RemoteAPI → Cache/Supabase
/// ```
///
/// **Princípio DIDÁTICO:**
/// - A UI chama Repository métodos
/// - Repository converte com Mapper
/// - Repository persiste ou sincroniza
/// - Resultado volta como entidade de domínio
///
/// **Exemplo de uso:**
/// ```dart
/// final repository = ProvidersRepositoryImpl(
///   remoteApi: SupabaseProvidersRemoteDatasource(),
///   localDao: ProvidersLocalDaoSharedPrefs(),
/// );
/// await repository.init();
/// final providers = await repository.getAll();  // Retorna List<Provider>
/// ```
class ProvidersRepositoryImpl implements IProvidersRepository {
  /// 🌐 API remota (Supabase)
  final IProvidersRemoteApi _remoteApi;

  /// 💾 DAO local (cache)
  final IProvidersLocalDao _localDao;

  /// Construtor que recebe dependências via injeção
  ///
  /// ✅ PADRÃO DIDÁTICO: Constructor Injection
  /// - Permite testing: mock remoteApi e localDao
  /// - Permite múltiplas implementações (ex: SQLite em vez de SharedPrefs)
  /// - Decoupling: Repository não cria suas dependências
  ProvidersRepositoryImpl({
    required IProvidersRemoteApi remoteApi,
    required IProvidersLocalDao localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao;

  /// 📥 Obtém todos os providers do cache
  ///
  /// **Fluxo:**
  /// 1. Chama DAO para listar (DTOs)
  /// 2. Converte DTOs → Entidades de domínio (Mapper)
  /// 3. Retorna List<Provider>
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] Carregando providers do cache...
  /// [ProvidersRepository] Carregados 5 providers
  /// ```
  ///
  /// ⚠️ IMPORTANTE DIDÁTICO:
  /// - Esta função retorna ENTIDADES DE DOMÍNIO, não DTOs
  /// - A conversão acontece aqui, na fronteira do Repository
  /// - A UI recebe sempre Provider, nunca ProviderModel
  @override
  Future<List<Provider>> getAll() async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Carregando providers do cache...');
      }

      // 🔵 PASSO 1: Lê DTOs do cache
      final dtoList = await _localDao.listAll();

      // 🔵 PASSO 2: Converte DTOs → Entidades (usando Mapper)
      final domainList = dtoList.map(ProviderMapper.toEntity).toList();

      if (kDebugMode) {
        print('[ProvidersRepository] Carregados ${domainList.length} providers');
      }

      return domainList;
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao carregar providers: $e');
      }
      rethrow;
    }
  }

  /// 🔍 Obtém um provider pelo ID
  ///
  /// **Fluxo:**
  /// 1. Chama DAO (retorna ProviderModel ou null)
  /// 2. Se encontrado, converte para Provider (Mapper)
  /// 3. Retorna Provider ou null
  @override
  Future<Provider?> getById(String id) async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Buscando provider: $id');
      }

      final dto = await _localDao.getById(id);
      if (dto == null) return null;

      // Converte DTO → Entidade
      return ProviderMapper.toEntity(dto);
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao buscar provider: $e');
      }
      rethrow;
    }
  }

  /// ➕ Cria um novo provider
  ///
  /// **Fluxo:**
  /// 1. Recebe Provider (entidade de domínio)
  /// 2. Converte para ProviderModel (Mapper)
  /// 3. Persiste no cache (DAO)
  /// 4. Retorna Provider
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] Criando provider: João Silva
  /// [ProvidersRepository] Provider criado com sucesso
  /// ```
  @override
  Future<Provider> create(Provider provider) async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Criando provider: ${provider.name}');
      }

      // 🔵 PASSO 1: Converte Entidade → DTO (Mapper)
      final dto = ProviderMapper.toDto(provider);

      // 🔵 PASSO 2: Persiste no cache
      await _localDao.insert(dto);

      if (kDebugMode) {
        print('[ProvidersRepository] Provider criado com sucesso');
      }

      return provider;
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao criar provider: $e');
      }
      rethrow;
    }
  }

  /// ✏️ Atualiza um provider
  ///
  /// **Fluxo:**
  /// 1. Recebe Provider (entidade atualizada)
  /// 2. Converte para ProviderModel
  /// 3. Persiste no cache (update)
  /// 4. Retorna Provider
  @override
  Future<Provider> update(Provider provider) async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Atualizando provider: ${provider.id}');
      }

      // Converte Entidade → DTO
      final dto = ProviderMapper.toDto(provider);

      // Atualiza no cache
      await _localDao.update(dto);

      if (kDebugMode) {
        print('[ProvidersRepository] Provider atualizado com sucesso');
      }

      return provider;
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao atualizar provider: $e');
      }
      rethrow;
    }
  }

  /// 🗑️ Deleta um provider
  ///
  /// **Retorna:**
  /// - true se deletado
  /// - false se não encontrado
  @override
  Future<bool> delete(String id) async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Deletando provider: $id');
      }

      final deleted = await _localDao.delete(id);

      if (kDebugMode) {
        print('[ProvidersRepository] Provider ${deleted ? 'deletado' : 'não encontrado'}');
      }

      return deleted;
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao deletar provider: $e');
      }
      rethrow;
    }
  }

  /// 🔄 Sincroniza com Supabase (one-shot)
  ///
  /// **FLUXO COMPLETO (DIDÁTICO):**
  ///
  /// ```
  /// PASSO 1: Buscar dados remotos
  ///   |
  ///   v
  /// PASSO 2: Converter DTOs → Entidades (Mapper)
  ///   |
  ///   v
  /// PASSO 3: Converter Entidades → DTOs (Mapper)
  ///   |
  ///   v
  /// PASSO 4: Upsert no cache (DAO)
  ///   |
  ///   v
  /// PASSO 5: Retornar quantidade
  /// ```
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] Iniciando sync com Supabase...
  /// [ProvidersRepository] Buscados 42 providers remotos
  /// [ProvidersRepository] Aplicados 42 providers ao cache
  /// [ProvidersRepository] Sync concluído com sucesso!
  /// ```
  ///
  /// **Checklist de erros ao implementar:**
  /// ❌ Não converter DTOs → não causaria erro, mas viola a arquitetura
  /// ❌ Não fazer upsert (apenas insert) → duplicaria em sincronizações seguintes
  /// ❌ Não retornar quantidade → UI não sabe quantos foram sincronizados
  ///
  /// **Timeout sugerido para UI:** 30 segundos
  @override
  Future<int> syncFromServer() async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] Iniciando sync com Supabase...');
      }

      // 🔵 PASSO 1: Busca dados remotos (retorna DTOs)
      final remoteDtoList = await _remoteApi.fetchAll();

      if (kDebugMode) {
        print('[ProvidersRepository] Buscados ${remoteDtoList.length} providers remotos');
      }

      // 🔵 PASSO 2: Upsert DTOs no cache (DAO trabalha com DTOs)
      await _localDao.upsertAll(remoteDtoList);

      if (kDebugMode) {
        print('[ProvidersRepository] Aplicados ${remoteDtoList.length} providers ao cache');
        print('[ProvidersRepository] Sync concluído com sucesso!');
      }

      return remoteDtoList.length;
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro ao sincronizar: $e');
      }
      rethrow;
    }
  }
}
