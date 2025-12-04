/// Utilitário para Sincronização de BusSchedules
///
/// **Propósito:**
/// Extrair a lógica de sincronização incremental em um classe auxiliar
/// para melhorar legibilidade e facilitar testes unitários.
///
/// **Responsabilidades:**
/// 1. Ler/atualizar last sync timestamp de SharedPreferences
/// 2. Orquestrar chamada ao RemoteApi com filtros apropriados
/// 3. Persistir dados sincronizados no DAO local
/// 4. Retornar quantidade de itens sincronizados
/// 5. Logging detalhado com kDebugMode
///

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/bus_schedules_local_dao.dart';
import '../../data/models/bus_schedule_model.dart';
import '../remote/i_bus_schedules_remote_api.dart';

class BusSchedulesSyncHelper {
  static const String _lastSyncKeyV1 = 'bus_schedules_last_sync_v1';
  static const Duration _syncTimeout = Duration(seconds: 30);

  final IBusSchedulesRemoteApi _remoteApi;
  final BusSchedulesLocalDao _localDao;
  final Future<SharedPreferences> _prefs;

  BusSchedulesSyncHelper({
    required IBusSchedulesRemoteApi remoteApi,
    required BusSchedulesLocalDao localDao,
  })  : _remoteApi = remoteApi,
        _localDao = localDao,
        _prefs = SharedPreferences.getInstance();

  /// Sincroniza agendamentos com servidor incrementalmente
  ///
  /// **Fluxo:**
  /// 1. Lê last sync timestamp de SharedPreferences
  /// 2. Busca RemoteApi com filtro since=lastSync
  /// 3. Converte resposta para BusScheduleModel
  /// 4. Faz upsert no DAO local (persistência)
  /// 5. Atualiza last sync timestamp
  /// 6. Retorna quantidade de itens sincronizados
  ///
  /// **Tratamento de erros:**
  /// - Timeout: retorna 0 (sem crash)
  /// - Parse error: log e continua
  /// - RemoteApi indisponível: retorna 0
  ///
  /// **Retorna:** Quantidade de itens sincronizados (0 se erro)
  Future<int> performSync() async {
    try {
      if (kDebugMode) {
        print('BusSchedulesSyncHelper.performSync: iniciando sincronização');
      }

      final prefs = await _prefs;

      // ========== PASSO 1: Ler último timestamp ==========
      final lastSyncIso = prefs.getString(_lastSyncKeyV1);
      DateTime? since;

      if (lastSyncIso != null && lastSyncIso.isNotEmpty) {
        try {
          since = DateTime.parse(lastSyncIso);
          if (kDebugMode) {
            print('BusSchedulesSyncHelper: última sincronização em $since');
          }
        } catch (_) {
          if (kDebugMode) {
            print('BusSchedulesSyncHelper: erro ao parsear lastSync, ignorando');
          }
        }
      } else {
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: primeira sincronização (sem lastSync anterior)');
        }
      }

      // ========== PASSO 2: Buscar RemoteApi com timeout ==========
      if (kDebugMode) {
        print('BusSchedulesSyncHelper: buscando RemoteApi com since=$since');
      }

      final remotePage = await _remoteApi
          .fetchBusSchedules(since: since, limit: 500)
          .timeout(_syncTimeout, onTimeout: () {
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: TIMEOUT na requisição remota após 30s');
        }
        return RemotePage(items: []);
      });

      if (remotePage.items.isEmpty) {
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: nenhum item retornado');
        }
        return 0;
      }

      if (kDebugMode) {
        print('BusSchedulesSyncHelper: recebidos ${remotePage.items.length} itens do remote');
      }

      // ========== PASSO 3: Fazer upsert no DAO local ==========
      try {
        await _localDao.upsertAll(remotePage.items);
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: ${remotePage.items.length} itens persistidos no cache');
        }
      } catch (e) {
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: ERRO ao persistir itens!');
          print('  erro: $e');
        }
        rethrow;
      }

      // ========== PASSO 4: Atualizar timestamp de sincronização ==========
      final newestTimestamp = _computeNewestTimestamp(remotePage.items);
      try {
        await prefs.setString(_lastSyncKeyV1, newestTimestamp.toUtc().toIso8601String());
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: último sync atualizado para $newestTimestamp');
        }
      } catch (e) {
        if (kDebugMode) {
          print('BusSchedulesSyncHelper: ERRO ao atualizar timestamp!');
          print('  erro: $e');
        }
      }

      if (kDebugMode) {
        print('BusSchedulesSyncHelper: ✅ sucesso! ${remotePage.items.length} itens sincronizados');
      }

      return remotePage.items.length;
    } catch (e, st) {
      if (kDebugMode) {
        print('BusSchedulesSyncHelper.performSync: ❌ ERRO geral durante sincronização!');
        print('  erro: $e');
        print('  stack: $st');
      }
      return 0;
    }
  }

  /// Computa o timestamp mais recente entre os itens
  /// Para evitar problemas de parsing, retorna DateTime.now().toUtc() se falhar
  DateTime _computeNewestTimestamp(List<BusScheduleModel> items) {
    if (items.isEmpty) {
      return DateTime.now().toUtc();
    }

    try {
      return items
          .map((item) => item.updatedAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    } catch (_) {
      if (kDebugMode) {
        print('BusSchedulesSyncHelper: erro ao computar newest timestamp, usando now()');
      }
      return DateTime.now().toUtc();
    }
  }

  /// Limpa o timestamp de última sincronização
  /// Útil para forçar sincronização completa na próxima vez
  Future<void> clearLastSync() async {
    try {
      final prefs = await _prefs;
      await prefs.remove(_lastSyncKeyV1);
      if (kDebugMode) {
        print('BusSchedulesSyncHelper: last sync timestamp removido');
      }
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesSyncHelper: erro ao limpar last sync: $e');
      }
    }
  }

  /// Obtém o timestamp da última sincronização bem-sucedida
  /// Retorna null se nunca foi sincronizado
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await _prefs;
      final iso = prefs.getString(_lastSyncKeyV1);
      if (iso == null) return null;
      return DateTime.parse(iso);
    } catch (_) {
      return null;
    }
  }
}

/*
/// ============================================================================
/// EXEMPLO DE USO
/// ============================================================================

// Uso no Repository:
final syncHelper = BusSchedulesSyncHelper(
  remoteApi: remoteApi,
  localDao: localDao,
);

// Sincronizar
final synced = await syncHelper.performSync();
print('Sincronizados $synced agendamentos');

// Obter último sync
final lastSync = await syncHelper.getLastSyncTime();
print('Última sincronização: $lastSync');

// Forçar nova sincronização completa
await syncHelper.clearLastSync();

/// ============================================================================
/// LOGS ESPERADOS
/// ============================================================================

BusSchedulesSyncHelper.performSync: iniciando sincronização
BusSchedulesSyncHelper: última sincronização em 2024-12-01 10:30:00.000Z
BusSchedulesSyncHelper: buscando RemoteApi com since=2024-12-01 10:30:00.000Z
BusSchedulesSyncHelper: recebidos 42 itens do remote
BusSchedulesSyncHelper: 42 itens persistidos no cache
BusSchedulesSyncHelper: último sync atualizado para 2024-12-01 11:45:00.000Z
BusSchedulesSyncHelper: ✅ sucesso! 42 itens sincronizados

/// ============================================================================
/// CHECKLIST COMUM
/// ============================================================================

❌ Erro: "Sincronização não atualiza UI"
✅ Solução: Repository chama syncFromServer() e depois recarrega cache
   Considerar usar StreamBuilder para updates automáticas

❌ Erro: "Dados duplicados após sync"
✅ Solução: DAO.upsertAll() deve substituir registros existentes
   Verificar que chave primária está correta

❌ Erro: "Last sync timestamp não persiste"
✅ Solução: Verificar se SharedPreferences.getInstance() está funcionando
   Testar com: flutter clean && flutter run

❌ Erro: "Timeout na sincronização"
✅ Solução: Aumentar _syncTimeout ou implementar retry logic
   Considerar dividir em chunks menores

*/
