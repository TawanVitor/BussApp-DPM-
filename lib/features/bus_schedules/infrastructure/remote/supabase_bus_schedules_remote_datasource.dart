/// Remote Datasource Supabase para BusSchedules
///
/// **Papel do Datasource Remoto:**
/// Este datasource encapsula toda a lógica de comunicação com Supabase,
/// incluindo conversão de tipos, tratamento de erros, paginação e logging.
/// Não inclui cache aqui - apenas busca e conversão de dados brutos.
///
/// **Dicas para evitar erros comuns:**
/// 1. **Conversão robusta de tipos:** O DTO (BusScheduleModel) deve aceitar múltiplos
///    formatos vindos do backend (ex: id como int/string, datas como DateTime/String).
/// 2. **Sempre log com kDebugMode:** Adicione prints nos principais pontos do fluxo
///    para facilitar debug de problemas de integração.
/// 3. **Try/catch em parsing:** Envolva conversão de datas, tipos e chamadas externas
///    em try/catch, sempre retornando valores seguros.
/// 4. **Nunca exponha segredos:** Não faça print de keys, tokens ou dados sensíveis.
/// 5. **Consulte arquivos de debug:** Veja providers_cache_debug_prompt.md,
///    supabase_init_debug_prompt.md e supabase_rls_remediation.md para exemplos
///    de logs reais e soluções de problemas.
///
/// **NOTA:** Este arquivo requer `supabase_flutter` no pubspec.yaml
/// Adicione: supabase_flutter: ^2.0.0 (ou versão mais recente)
///

// TODO: Descomente quando supabase_flutter estiver no pubspec.yaml
// import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/bus_schedule_model.dart';
import 'i_bus_schedules_remote_api.dart';

// Placeholder para SupabaseClient enquanto pacote não está disponível
// Remova isto quando supabase_flutter for adicionado ao pubspec.yaml
typedef SupabaseClient = dynamic;

class SupabaseBusSchedulesRemoteDatasource implements IBusSchedulesRemoteApi {
  static const String _tableName = 'bus_schedules';
  
  final dynamic _client; // SupabaseClient quando supabase_flutter estiver disponível

  /// Construtor
  /// 
  /// [client] deve ser uma instância de SupabaseClient (quando supabase_flutter estiver disponível)
  /// Se null, tentará usar Supabase.instance.client (requer inicialização prévia)
  SupabaseBusSchedulesRemoteDatasource({dynamic client})
      : _client = client;

  /// Busca agendamentos do Supabase com paginação e filtros por data
  ///
  /// - [since]: busca apenas agendamentos modificados após esta data (usando updated_at >= since)
  /// - [limit]: quantidade máxima de registros (padrão 500, máximo recomendado)
  /// - [offset]: posição inicial para paginação
  ///
  /// Retorna: RemotePage com lista de modelos convertidos e flag hasNext
  /// Se houver erro, retorna página vazia para evitar crashes
  @override
  Future<RemotePage<BusScheduleModel>> fetchBusSchedules({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  }) async {
    try {
      if (_client == null) {
        if (kDebugMode) {
          print('SupabaseBusSchedulesRemoteDatasource.fetchBusSchedules: _client é null');
        }
        return RemotePage(items: []);
      }

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.fetchBusSchedules: iniciando requisição');
        print('  since: $since, limit: $limit, offset: $offset');
      }

      // Construir query (supabase_flutter)
      var query = _client.from(_tableName).select();

      // Filtro por data de última modificação (sincronização incremental)
      if (since != null) {
        final sinceIso = since.toUtc().toIso8601String();
        query = query.gte('updated_at', sinceIso);
        if (kDebugMode) {
          print('SupabaseBusSchedulesRemoteDatasource: aplicando filtro since = $sinceIso');
        }
      }

      // Ordenar por data de modificação descendente (mais recentes primeiro)
      query = query.order('updated_at', ascending: false);

      // Paginação usando range (offset, offset+limit-1)
      final rangeEnd = offset + limit - 1;
      query = query.range(offset, rangeEnd);

      // Executar requisição
      final List<dynamic> rows = await query;

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource: recebidos ${rows.length} registros');
      }

      // Converter rows para BusScheduleModel
      final items = <BusScheduleModel>[];
      for (final row in rows) {
        try {
          final model = BusScheduleModel.fromJson(row as Map<String, dynamic>);
          items.add(model);
        } catch (e) {
          if (kDebugMode) {
            print('SupabaseBusSchedulesRemoteDatasource: erro ao converter registro: $e');
            print('  row: $row');
          }
          // Continuar com próximo registro
          continue;
        }
      }

      // Determinar se há próxima página
      // Se recebemos exatamente `limit` registros, provavelmente há mais
      final hasNext = rows.length == limit;

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource: convertidos ${items.length} registros');
        print('SupabaseBusSchedulesRemoteDatasource: hasNext = $hasNext');
      }

      return RemotePage(items: items, hasNext: hasNext);
    } catch (e, st) {
      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.fetchBusSchedules: ERRO!');
        print('  erro: $e');
        print('  stack: $st');
      }
      // Retornar página vazia em caso de erro para evitar crash
      return RemotePage(items: []);
    }
  }

  /// Sincroniza (insere ou atualiza) um agendamento no Supabase
  ///
  /// Usa upsert (insert/update automático baseado em primary key)
  /// Retorna modelo atualizado com dados do servidor
  @override
  Future<BusScheduleModel> upsertBusSchedule(BusScheduleModel schedule) async {
    try {
      if (_client == null) {
        throw Exception('SupabaseClient não inicializado');
      }

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.upsertBusSchedule: iniciando');
        print('  id: ${schedule.id}');
      }

      final json = schedule.toJson();

      // Usar upsert para inserir ou atualizar automaticamente
      final response = await _client
          .from(_tableName)
          .upsert(json, onConflict: 'id')
          .select()
          .single();

      final result = BusScheduleModel.fromJson(response as Map<String, dynamic>);

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.upsertBusSchedule: sucesso');
      }

      return result;
    } catch (e, st) {
      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.upsertBusSchedule: ERRO!');
        print('  erro: $e');
        print('  stack: $st');
      }
      rethrow;
    }
  }

  /// Deleta um agendamento no Supabase
  ///
  /// Retorna true se deletado com sucesso, false caso contrário
  @override
  Future<bool> deleteBusSchedule(String id) async {
    try {
      if (_client == null) {
        throw Exception('SupabaseClient não inicializado');
      }

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.deleteBusSchedule: iniciando');
        print('  id: $id');
      }

      await _client.from(_tableName).delete().eq('id', id);

      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.deleteBusSchedule: sucesso');
      }

      return true;
    } catch (e, st) {
      if (kDebugMode) {
        print('SupabaseBusSchedulesRemoteDatasource.deleteBusSchedule: ERRO!');
        print('  erro: $e');
        print('  stack: $st');
      }
      return false;
    }
  }
}

/*
/// ============================================================================
/// EXEMPLO DE USO E CHECKLIST DE ERROS COMUNS
/// ============================================================================

// Uso básico:
final remote = SupabaseBusSchedulesRemoteDatasource();
final page = await remote.fetchBusSchedules(limit: 50);
print('Recebidos ${page.items.length} agendamentos');

// Com filtro de sincronização:
final lastSync = DateTime(2024, 12, 1);
final pageSince = await remote.fetchBusSchedules(since: lastSync, limit: 500);

// Upsert individual:
final updated = await remote.upsertBusSchedule(schedule);

// Deletar:
final deleted = await remote.deleteBusSchedule(id);

/// CHECKLIST DE ERROS COMUNS E COMO EVITAR:
///
/// ❌ Erro: "Falha ao converter JSON para BusScheduleModel"
/// ✅ Solução: Verifique se BusScheduleModel.fromJson() aceita múltiplos formatos
///    - id pode vir como int ou string
///    - datas podem vir como DateTime ou String ISO8601
///    - campos opcionais podem estar ausentes (null)
///
/// ❌ Erro: "Exceção ao fazer parse de DateTime"
/// ✅ Solução: Adicione try/catch em conversões de data
///    ```dart
///    DateTime? parseDate(dynamic value) {
///      try {
///        if (value == null) return null;
///        if (value is DateTime) return value;
///        if (value is String) return DateTime.parse(value);
///      } catch (_) {}
///      return null;
///    }
///    ```
///
/// ❌ Erro: "RLS Policy rejected request"
/// ✅ Solução: Consulte supabase_rls_remediation.md para configuração
///    Verifique autenticação, permissões de row-level security
///
/// ❌ Erro: "Nenhum agendamento retornado após sync"
/// ✅ Solução: Adicione prints/logs para inspecionar:
///    - Conteúdo dos dados retornados
///    - Conversão de tipos
///    - Filtros aplicados
///    - Paginação (offset/limit)
///
/// ❌ Erro: "Timeout na requisição Supabase"
/// ✅ Solução: Aumentar limite (limit) reduzindo quantidade de registros
///    Considerar paginação com offset
///    Verificar conexão de rede
///
/// ❌ Erro: "Problema com Supabase na inicialização"
/// ✅ Solução: Consulte supabase_init_debug_prompt.md
///    Verifique credenciais (URL, anon key)
///    Confirme que Supabase.initialize() foi chamado em main.dart

/// EXEMPLO DE LOGS ESPERADOS (com kDebugMode = true):
///
/// SupabaseBusSchedulesRemoteDatasource.fetchBusSchedules: iniciando requisição
///   since: null, limit: 500, offset: 0
/// SupabaseBusSchedulesRemoteDatasource: recebidos 42 registros
/// SupabaseBusSchedulesRemoteDatasource: convertidos 42 registros
/// SupabaseBusSchedulesRemoteDatasource: hasNext = false

/// REFERÊNCIAS ÚTEIS:
/// - lib/features/bus_schedules/infrastructure/repositories/bus_schedules_repository_impl.dart
/// - supabase_init_debug_prompt.md
/// - supabase_rls_remediation.md
/// - providers_cache_debug_prompt.md
*/
