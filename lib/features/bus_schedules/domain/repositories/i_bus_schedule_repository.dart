/// Interface de repositório para a entidade BusSchedule.
///
/// O repositório define as operações de acesso e sincronização de dados,
/// separando a lógica de persistência da lógica de negócio.
/// Utilizar interfaces facilita a troca de implementações (ex.: local, remota)
/// e torna o código mais testável e modular.
///

import '../entities/bus_schedule.dart';
import '../entities/bus_schedule_filters.dart';
import '../entities/bus_schedule_list_response.dart';

abstract class IBusScheduleRepository {
  /// Carrega todos os agendamentos do cache local de forma rápida.
  /// 
  /// Prática recomendada: Use este método para renderização inicial rápida
  /// enquanto dados remotos são sincronizados em background.
  Future<List<BusSchedule>> loadFromCache();

  /// Sincroniza agendamentos com o servidor incrementalmente.
  /// 
  /// Retorna quantos registros foram alterados/adicionados.
  /// Prática recomendada: Chamar periodicamente para manter dados atualizados.
  Future<int> syncFromServer();

  /// Listagem completa de agendamentos (normalmente do cache após sincronização).
  /// 
  /// Parâmetros opcionais de filtro e paginação.
  /// Retorna: Resposta estruturada com metadados de paginação.
  Future<BusScheduleListResponse> listAll({
    BusScheduleFilters? filters,
    int pageSize = 20,
    int pageNumber = 1,
  });

  /// Busca agendamentos em destaque/filtrados.
  /// 
  /// Útil para exibir recomendações ou rotas populares.
  /// Retorna: Lista de agendamentos destacados.
  Future<List<BusSchedule>> listFeatured();

  /// Busca opcional por ID direto no cache.
  /// 
  /// Prática recomendada: Use para obter detalhes de um agendamento específico.
  /// Retorna: Agendamento se encontrado, null caso contrário.
  Future<BusSchedule?> getById(String id);

  /// Busca agendamentos por query (rota, destino, etc).
  /// 
  /// Útil para implementar busca em tempo real.
  Future<List<BusSchedule>> search(String query, {int limit = 50});

  /// Cria um novo agendamento.
  /// 
  /// Retorna: Agendamento criado com ID gerado.
  Future<BusSchedule> create(BusSchedule schedule);

  /// Atualiza um agendamento existente.
  /// 
  /// Retorna: Agendamento atualizado.
  Future<BusSchedule> update(String id, BusSchedule schedule);

  /// Deleta um agendamento.
  /// 
  /// Retorna: true se deletado com sucesso.
  Future<bool> delete(String id);

  /// Operação em lote: insere ou atualiza múltiplos agendamentos.
  /// 
  /// Prática recomendada: Use após sincronização com servidor.
  Future<List<BusSchedule>> upsertAll(List<BusSchedule> schedules);

  /// Limpa todos os agendamentos do repositório.
  /// 
  /// ⚠️ CUIDADO: Operação irreversível.
  Future<bool> clear();
}

/// Exemplo de uso em um Controller/Provider:
///
/// ```dart
/// class BusScheduleController {
///   final IBusScheduleRepository _repository;
///
///   BusScheduleController(this._repository);
///
///   Future<void> initializeData() async {
///     // 1. Carrega do cache rapidamente
///     final cached = await _repository.loadFromCache();
///     print('${cached.length} agendamentos em cache');
///
///     // 2. Sincroniza com servidor em background
///     final changed = await _repository.syncFromServer();
///     print('$changed agendamentos sincronizados');
///
///     // 3. Lista completa após sync
///     final response = await _repository.listAll(pageSize: 20);
///     print('${response.data.length} agendamentos disponíveis');
///   }
///
///   Future<void> searchRoutes(String query) async {
///     final results = await _repository.search(query);
///     print('Encontrados ${results.length} resultados');
///   }
/// }
/// ```