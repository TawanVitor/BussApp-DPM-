/// Interface para acesso remoto de agendamentos via API.
///
/// Define contrato para operações CRUD remotas (Supabase, REST API, etc).
/// Implementações concretas devem cuidar de:
/// - Conversão de tipos (int/string, DateTime/String)
/// - Tratamento de erros de rede e parsing
/// - Paginação e filtros de data
///

import '../../data/models/bus_schedule_model.dart';

/// Modelo para resposta paginada do servidor remoto
class RemotePage<T> {
  final List<T> items;
  final bool hasNext;

  RemotePage({
    required this.items,
    this.hasNext = false,
  });
}

/// Interface do remote datasource para agendamentos
abstract class IBusSchedulesRemoteApi {
  /// Busca agendamentos do servidor remoto com filtros opcionais
  ///
  /// - [since]: data de última sincronização para buscar apenas alterações
  /// - [limit]: quantidade máxima de registros por requisição
  /// - [offset]: posição inicial para paginação
  Future<RemotePage<BusScheduleModel>> fetchBusSchedules({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  });

  /// Sincroniza um agendamento individual para o servidor
  Future<BusScheduleModel> upsertBusSchedule(BusScheduleModel schedule);

  /// Deleta um agendamento no servidor
  Future<bool> deleteBusSchedule(String id);
}
