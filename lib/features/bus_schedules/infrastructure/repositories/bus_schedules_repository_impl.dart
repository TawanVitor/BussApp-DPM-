/// Repository Impl para BusSchedules com Sincronização Remota
///
/// **Papel do Repositório:**
/// Implementação concreta de IBusScheduleRepository que coordena:
/// - Cache local (via BusSchedulesLocalDao com SharedPreferences)
/// - Sincronização remota (via SupabaseBusSchedulesRemoteDatasource)
/// - Lógica de negócio (filtros, busca, CRUD)
///
/// **Arquitetura:**
/// - Delegação: métodos de leitura/escrita delegam ao DAO local
/// - Sincronização: lógica extraída para BusSchedulesSyncHelper (separação de responsabilidades)
/// - Logging: kDebugMode em operações críticas para debug
/// - Error handling: retorno seguro em caso de erro (lista vazia, false, etc)
///
/// **Fluxo Recomendado em Widget:**
/// ```
/// 1. initState: await repository.loadFromCache() → renderizar UI rápido
/// 2. Background: await repository.syncFromServer() → atualizar dados
/// 3. Callback: se synced > 0, chamar setState para recarregar
/// ```
///
/// **Dicas para evitar erros comuns:**
/// 1. **Sempre verifique mounted:** Antes de setState em callbacks assíncronos
/// 2. **Use logging:** kDebugMode mostra fluxo de cache/sync
/// 3. **Trate datas defensivamente:** Backend pode enviar DateTime ou String
/// 4. **Consulte referências:** Ver arquivos de debug do projeto

import 'package:flutter/foundation.dart';
import '../../data/datasources/bus_schedules_local_dao.dart';
import '../../data/models/bus_schedule_model.dart';
import '../../domain/entities/bus_schedule.dart';
import '../../domain/entities/bus_schedule_filters.dart';
import '../../domain/entities/bus_schedule_list_response.dart';
import '../../domain/repositories/i_bus_schedule_repository.dart';
import '../remote/i_bus_schedules_remote_api.dart';
import 'bus_schedules_sync_helper.dart';

class BusSchedulesRepositoryImpl implements IBusScheduleRepository {
  final IBusSchedulesRemoteApi _remoteApi;
  final BusSchedulesLocalDao _localDao;
  late final BusSchedulesSyncHelper _syncHelper;

  BusSchedulesRepositoryImpl({
    required IBusSchedulesRemoteApi remoteApi,
    required BusSchedulesLocalDao localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao {
    // Inicializar sync helper com dependências
    _syncHelper = BusSchedulesSyncHelper(
      remoteApi: _remoteApi,
      localDao: _localDao,
    );
  }

  /// Carrega todos os agendamentos do cache local de forma rápida
  ///
  /// Use este método para renderização inicial rápida enquanto
  /// syncFromServer() é chamado em background.
  @override
  Future<List<BusSchedule>> loadFromCache() async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.loadFromCache: iniciando');
      }

      final response = await _localDao.listAll(pageSize: 10000);
      final items = response.data;

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.loadFromCache: carregados ${items.length} agendamentos do cache');
      }

      return items;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.loadFromCache: ERRO! $e');
      }
      return [];
    }
  }

  /// Sincroniza agendamentos com servidor incrementalmente
  ///
  /// Delega a lógica de sincronização para BusSchedulesSyncHelper que:
  /// 1. Lê last sync timestamp de SharedPreferences
  /// 2. Busca RemoteApi com filtro since=lastSync
  /// 3. Faz upsert no DAO local
  /// 4. Atualiza timestamp
  /// 5. Retorna quantidade de itens
  ///
  /// **Retorna:** Quantidade de itens sincronizados (0 se erro ou sem mudanças)
  @override
  Future<int> syncFromServer() async {
    if (kDebugMode) {
      print('BusSchedulesRepositoryImpl.syncFromServer: delegando para sync helper');
    }
    return await _syncHelper.performSync();
  }

  /// Listagem completa com filtros e paginação
  @override
  Future<BusScheduleListResponse> listAll({
    BusScheduleFilters? filters,
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.listAll: page=$pageNumber, pageSize=$pageSize');
      }

      return await _localDao.listAll(
        filters: filters,
        pageSize: pageSize,
        page: pageNumber,
      );
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.listAll: ERRO! $e');
      }
      return BusScheduleListResponse(
        data: [],
        meta: BusScheduleMeta(
          total: 0,
          page: pageNumber,
          pageSize: pageSize,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
      );
    }
  }

  /// Busca agendamentos em destaque
  @override
  Future<List<BusSchedule>> listFeatured() async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.listFeatured: iniciando');
      }

      final response = await _localDao.listAll(pageSize: 20);
      final featured = response.data.take(5).toList();

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.listFeatured: retornando ${featured.length} destaques');
      }

      return featured;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.listFeatured: ERRO! $e');
      }
      return [];
    }
  }

  /// Busca agendamento por ID
  @override
  Future<BusSchedule?> getById(String id) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.getById: id=$id');
      }

      final response = await _localDao.listAll(pageSize: 10000);
      final schedule = response.data.firstWhere(
        (s) => s.id == id,
        orElse: () => throw Exception('Agendamento não encontrado: $id'),
      );

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.getById: encontrado');
      }

      return schedule;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.getById: ERRO! $e');
      }
      return null;
    }
  }

  /// Busca agendamentos por texto (rota, destino, origem)
  @override
  Future<List<BusSchedule>> search(String query, {int limit = 50}) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.search: query="$query", limit=$limit');
      }

      if (query.trim().isEmpty) {
        return [];
      }

      final response = await _localDao.listAll(pageSize: limit);
      final queryLower = query.toLowerCase().trim();

      final results = response.data
          .where((schedule) =>
              schedule.routeName.toLowerCase().contains(queryLower) ||
              schedule.destination.toLowerCase().contains(queryLower) ||
              (schedule.origin?.toLowerCase().contains(queryLower) ?? false))
          .toList();

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.search: encontrados ${results.length} resultados');
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.search: ERRO! $e');
      }
      return [];
    }
  }

  /// Cria novo agendamento
  @override
  Future<BusSchedule> create(BusSchedule schedule) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.create: id=${schedule.id}');
      }

      if (schedule is! BusScheduleModel) {
        throw Exception('Schedule deve ser do tipo BusScheduleModel');
      }

      await _localDao.upsertAll([schedule]);

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.create: sucesso');
      }

      return schedule;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.create: ERRO! $e');
      }
      rethrow;
    }
  }

  /// Atualiza agendamento existente
  @override
  Future<BusSchedule> update(String id, BusSchedule schedule) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.update: id=$id');
      }

      if (schedule is! BusScheduleModel) {
        throw Exception('Schedule deve ser do tipo BusScheduleModel');
      }

      await _localDao.upsertAll([schedule]);

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.update: sucesso');
      }

      return schedule;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.update: ERRO! $e');
      }
      rethrow;
    }
  }

  /// Deleta agendamento
  @override
  Future<bool> delete(String id) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.delete: id=$id');
      }

      final response = await _localDao.listAll(pageSize: 10000);
      final filtered = response.data.where((s) => s.id != id).toList();

      await _localDao.clear();
      if (filtered.isNotEmpty) {
        await _localDao.upsertAll(filtered);
      }

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.delete: sucesso');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.delete: ERRO! $e');
      }
      return false;
    }
  }

  /// Operação em lote (upsert)
  @override
  Future<List<BusSchedule>> upsertAll(List<BusSchedule> schedules) async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.upsertAll: ${schedules.length} itens');
      }

      // Converter para BusScheduleModel se necessário
      final models = <BusScheduleModel>[];
      for (final schedule in schedules) {
        if (schedule is BusScheduleModel) {
          models.add(schedule);
        } else {
          if (kDebugMode) {
            print('BusSchedulesRepositoryImpl.upsertAll: aviso - item não é BusScheduleModel');
          }
        }
      }

      if (models.isEmpty) {
        return [];
      }

      await _localDao.upsertAll(models);

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.upsertAll: ${models.length} itens persistidos');
      }

      return models;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.upsertAll: ERRO! $e');
      }
      rethrow;
    }
  }

  /// Limpa todos os agendamentos
  @override
  Future<bool> clear() async {
    try {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.clear: limpando cache');
      }

      await _localDao.clear();

      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.clear: sucesso');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesRepositoryImpl.clear: ERRO! $e');
      }
      return false;
    }
  }
}

/*
/// ============================================================================
/// EXEMPLO DE USO E CHECKLIST
/// ============================================================================

// Setup no service locator:
final remoteApi = SupabaseBusSchedulesRemoteDatasource();
final localDao = BusSchedulesLocalDao();
final repository = BusSchedulesRepositoryImpl(
  remoteApi: remoteApi,
  localDao: localDao,
);

// Fluxo recomendado em Widget (com mounted check):
void _loadSchedules() async {
  if (!mounted) return;
  setState(() => _isLoading = true);
  
  try {
    // 1. Carregar cache (renderização rápida)
    final cached = await repository.loadFromCache();
    if (mounted) {
      setState(() => _schedules = cached);
    }
    
    // 2. Sincronizar em background
    final synced = await repository.syncFromServer();
    if (kDebugMode) {
      print('Sincronizados $synced agendamentos');
    }
    
    // 3. Recarregar se houve mudanças
    if (mounted && synced > 0) {
      final updated = await repository.loadFromCache();
      setState(() => _schedules = updated);
    }
  } catch (e) {
    if (mounted && kDebugMode) {
      print('Erro: $e');
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}

/// ============================================================================
/// CHECKLIST DE ERROS COMUNS
/// ============================================================================

❌ Erro: "setState called after dispose"
✅ Solução: Adicionar `if (mounted)` antes de setState
   if (mounted) setState(() => _data = value);

❌ Erro: "Sincronização não atualiza UI"
✅ Solução: Chamar loadFromCache() após syncFromServer()
   final synced = await repo.syncFromServer();
   if (synced > 0) {
     final updated = await repo.loadFromCache();
     setState(() => _schedules = updated);
   }

❌ Erro: "Dados duplicados após sync"
✅ Solução: DAO.upsertAll() substitui registros com mesma chave primária
   Verifique BusScheduleModel.fromJson() para múltiplos formatos de tipo

❌ Erro: "Last sync não persiste"
✅ Solução: Testar SharedPreferences com `flutter clean && flutter run`
   Considerar incrementar versão: _lastSyncKeyV2

❌ Erro: "Timeout na sincronização"
✅ Solução: Ver BusSchedulesSyncHelper._syncTimeout (padrão 30s)
   Implementar retry logic se necessário

/// ============================================================================
/// LOGS ESPERADOS (com kDebugMode = true)
/// ============================================================================

BusSchedulesRepositoryImpl.loadFromCache: iniciando
BusSchedulesRepositoryImpl.loadFromCache: carregados 42 agendamentos do cache
BusSchedulesRepositoryImpl.syncFromServer: delegando para sync helper
BusSchedulesSyncHelper.performSync: iniciando sincronização
BusSchedulesSyncHelper: última sincronização em 2024-12-01 10:30:00.000Z
BusSchedulesSyncHelper: buscando RemoteApi com since=2024-12-01 10:30:00.000Z
BusSchedulesSyncHelper: recebidos 5 itens do remote
BusSchedulesSyncHelper: 5 itens persistidos no cache
BusSchedulesSyncHelper: último sync atualizado para 2024-12-01 11:45:00.000Z
BusSchedulesSyncHelper: ✅ sucesso! 5 itens sincronizados

/// ============================================================================
/// REFERÊNCIAS E ARQUIVOS RELACIONADOS
/// ============================================================================

1. bus_schedules_sync_helper.dart
   ├─ Lógica de sync extraída (separação de responsabilidades)
   ├─ performSync(): orquestra sincronização
   ├─ getLastSyncTime(): obtém timestamp
   └─ clearLastSync(): força nova sincronização

2. supabase_bus_schedules_remote_datasource.dart
   ├─ Implementação Supabase
   ├─ fetchBusSchedules(): fetch com paginação
   ├─ upsertBusSchedule(): insert/update
   └─ deleteBusSchedule(): delete

3. bus_schedules_local_dao.dart
   ├─ Persistência local com SharedPreferences
   ├─ listAll(): com filtros e paginação
   ├─ upsertAll(): batch insert/update
   └─ clear(): limpar tudo

4. Arquivos de debug do projeto:
   ├─ supabase_init_debug_prompt.md
   ├─ supabase_rls_remediation.md
   └─ providers_cache_debug_prompt.md

/// ============================================================================
/// DICAS DE PRODUCTION READINESS
/// ============================================================================

✅ Sempre usar `if (mounted)` em setState após operações assíncronas
✅ Implementar retry logic para sync em conexões instáveis
✅ Adicionar indicador visual de sincronização em andamento
✅ Considerar background sync com WorkManager para atualizações automáticas
✅ Monitorar logs para detectar problemas de conversão ou RLS
✅ Testar com múltiplos dispositivos simultâneos editando dados
✅ Validar integridade de dados após grandes sincronizações
✅ Documentar política de retenção (arquivamento vs exclusão hard)

*/

