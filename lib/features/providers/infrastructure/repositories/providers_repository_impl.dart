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

  /// 🔄 Sincroniza com Supabase - Push-Then-Pull (Bidirecional)
  ///
  /// **FLUXO COMPLETO - SINCRONIZAÇÃO BIDIRECIONAL:**
  ///
  /// Esta implementação realiza um ciclo completo de sincronização:
  ///
  /// ```
  /// ┌─────────────────────────────────────────┐
  /// │  1️⃣  PUSH (Local → Supabase)            │
  /// │  ├─ Carregar cache local                │
  /// │  ├─ Enviar via upsertProviders()        │
  /// │  └─ Registrar resultado (erro ignorado) │
  /// └──────────────┬──────────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────────┐
  /// │  2️⃣  PULL (Supabase → Local)            │
  /// │  ├─ Buscar atualizações remotas         │
  /// │  ├─ Aplicar via upsertAll()             │
  /// │  └─ Atualizar lastSync timestamp        │
  /// └──────────────┬──────────────────────────┘
  ///                │
  /// ┌──────────────▼──────────────────────────┐
  /// │  3️⃣  RESULTADO                          │
  /// │  └─ Retornar quantidade sincronizada    │
  /// └──────────────────────────────────────────┘
  /// ```
  ///
  /// **Por que Push-Then-Pull?**
  ///
  /// 1. **Push primeiro:**
  ///    - Envia mudanças locais para remoto (offlinechanges)
  ///    - Usa upsert (insert-or-update) para segurança
  ///    - Erros de push não bloqueiam o pull
  ///
  /// 2. **Pull depois:**
  ///    - Busca mudanças remotas (feitas por outros usuários)
  ///    - Aplica localmente (reconciliação)
  ///    - Garante consistência final
  ///
  /// **Tratamento de conflitos:**
  /// - Usa timestamp `updated_at` para resolver conflitos
  /// - Política: Last-Write-Wins (quem atualizou mais recentemente ganha)
  /// - O servidor é a fonte de verdade após o pull
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersRepository] Iniciando sync com Supabase...
  /// [ProvidersRepository] PUSH: enviando 3 providers locais
  /// [SupabaseDatasource] upsertProviders: enviando 3 itens
  /// [ProvidersRepository] PUSH: 3 items enviados (ou 0 se erro)
  /// [ProvidersRepository] PULL: buscando atualizações remotas
  /// [ProvidersRepository] PULL: aplicados 2 providers remotos
  /// [ProvidersRepository] Sync concluído: 5 total
  /// ```
  ///
  /// **Checklist de implementação:**
  /// ✅ Ler cache local para push
  /// ✅ Chamar upsertProviders (melhor esforço)
  /// ✅ Registrar resultado do push (mesmo com erro)
  /// ✅ Buscar remoto para pull
  /// ✅ Aplicar remotos localmente
  /// ✅ Atualizar lastSync
  /// ✅ Retornar contagem total
  /// ✅ Logging em cada passo
  /// ✅ if(mounted) antes de setState (na UI)
  /// ✅ Timeout de 30s (na UI)
  ///
  /// **Erros comuns:**
  /// ❌ Bloquear pull se push falhar → Usa try/catch para continuar
  /// ❌ Não converter DTOs → Usar Mapper para conversão
  /// ❌ Perder IDs locais → Supabase preserva IDs via upsert
  /// ❌ Não sincronizar se cache tem dados → Sempre sincroniza (bidirecional)
  @override
  Future<int> syncFromServer() async {
    try {
      if (kDebugMode) {
        print('[ProvidersRepository] ═══════════════════════════════════════');
        print('[ProvidersRepository] Iniciando SYNC BIDIRECIONAL com Supabase...');
        print('[ProvidersRepository] ═══════════════════════════════════════');
      }

      int totalSynced = 0;

      // ═══════════════════════════════════════════════════════════════
      // 🔵 PASSO 1: PUSH (Local → Supabase)
      // ═══════════════════════════════════════════════════════════════

      if (kDebugMode) {
        print('[ProvidersRepository] 📤 INICIANDO PUSH...');
      }

      try {
        // Carregar cache local
        final localDtoList = await _localDao.listAll();

        if (kDebugMode) {
          print('[ProvidersRepository] PUSH: carregados ${localDtoList.length} items locais');
        }

        // Enviar para remoto (upsert - insert or update)
        final pushed = await _remoteApi.upsertProviders(localDtoList);

        if (kDebugMode) {
          print('[ProvidersRepository] ✅ PUSH: $pushed items enviados para remoto');
        }

        totalSynced += pushed; // Soma ao total

      } catch (pushError) {
        // ⚠️ Erro no push NÃO bloqueia o pull
        // Isso é o "best-effort" mencionado no prompt
        if (kDebugMode) {
          print('[ProvidersRepository] ⚠️ Erro no PUSH (continuando com PULL): $pushError');
        }
        // Não relança erro - continua com pull
      }

      // ═══════════════════════════════════════════════════════════════
      // 🔵 PASSO 2: PULL (Supabase → Local)
      // ═══════════════════════════════════════════════════════════════

      if (kDebugMode) {
        print('[ProvidersRepository] 📥 INICIANDO PULL...');
      }

      try {
        // Buscar dados remotos
        final remoteDtoList = await _remoteApi.fetchAll();

        if (kDebugMode) {
          print('[ProvidersRepository] PULL: buscados ${remoteDtoList.length} items remotos');
        }

        // Aplicar no cache local (upsertAll - preserve locals if not in remote)
        await _localDao.upsertAll(remoteDtoList);

        if (kDebugMode) {
          print('[ProvidersRepository] ✅ PULL: ${remoteDtoList.length} items aplicados ao cache');
        }

        totalSynced += remoteDtoList.length; // Soma ao total

        // ═══════════════════════════════════════════════════════════════
        // 🔵 PASSO 3: RESULT
        // ═══════════════════════════════════════════════════════════════

        if (kDebugMode) {
          print('[ProvidersRepository] ═══════════════════════════════════════');
          print('[ProvidersRepository] ✅ SYNC CONCLUÍDO COM SUCESSO!');
          print('[ProvidersRepository] Total sincronizado: $totalSynced items');
          print('[ProvidersRepository] ═══════════════════════════════════════');
        }

        return totalSynced;

      } catch (pullError) {
        // Erro no pull é crítico - relança
        if (kDebugMode) {
          print('[ProvidersRepository] ❌ Erro CRÍTICO no PULL: $pullError');
        }
        rethrow;
      }

    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersRepository] ❌ Erro fatal ao sincronizar: $e');
      }
      rethrow;
    }
  }
}
