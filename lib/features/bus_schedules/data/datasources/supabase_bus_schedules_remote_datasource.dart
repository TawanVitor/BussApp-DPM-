import '../models/bus_schedule_model.dart';
import 'i_bus_schedules_remote_datasource.dart';

/// Remote Datasource para Supabase Bus Schedules
/// 
/// Implementação de placeholder - será configurada com cliente Supabase real
/// quando a dependência supabase_flutter for instalada.
class SupabaseBusSchedulesRemoteDatasource
    implements IBusSchedulesRemoteDatasource {
  // ignore: unused_field
  final dynamic _supabaseClient;

  SupabaseBusSchedulesRemoteDatasource(this._supabaseClient);

  @override
  Future<List<BusScheduleModel>> fetchAll() async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // final response = await _supabaseClient
      //     .from('bus_schedules')
      //     .select()
      //     .order('departureTime', ascending: true);
      //
      // return (response as List)
      //     .map((json) => BusScheduleModel.fromJson(json))
      //     .toList();
      
      return [];
    } catch (e) {
      throw Exception('Erro ao buscar agendamentos remotos: $e');
    }
  }

  @override
  Future<BusScheduleModel?> fetchById(String id) async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // final response = await _supabaseClient
      //     .from('bus_schedules')
      //     .select()
      //     .eq('id', id)
      //     .single();
      //
      // return BusScheduleModel.fromJson(response);
      
      return null;
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('No rows')) {
        return null;
      }
      throw Exception('Erro ao buscar agendamento remoto: $e');
    }
  }

  @override
  Future<BusScheduleModel> create(BusScheduleModel model) async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // final response = await _supabaseClient
      //     .from('bus_schedules')
      //     .insert(model.toJson())
      //     .select()
      //     .single();
      //
      // return BusScheduleModel.fromJson(response);
      
      return model;
    } catch (e) {
      throw Exception('Erro ao criar agendamento remoto: $e');
    }
  }

  @override
  Future<BusScheduleModel> update(BusScheduleModel model) async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // final response = await _supabaseClient
      //     .from('bus_schedules')
      //     .update(model.toJson())
      //     .eq('id', model.id)
      //     .select()
      //     .single();
      //
      // return BusScheduleModel.fromJson(response);
      
      return model;
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento remoto: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // await _supabaseClient.from('bus_schedules').delete().eq('id', id);
      
      return true;
    } catch (e) {
      throw Exception('Erro ao deletar agendamento remoto: $e');
    }
  }

  @override
  Future<int> upsertBusSchedules(List<BusScheduleModel> models) async {
    try {
      // TODO: Implementar quando Supabase estiver disponível
      // final jsonList = models.map((m) => m.toJson()).toList();
      //
      // final response = await _supabaseClient
      //     .from('bus_schedules')
      //     .upsert(jsonList)
      //     .select();
      //
      // return (response as List).length;
      
      return models.length;
    } catch (e) {
      throw Exception('Erro ao fazer upsert de agendamentos remotos: $e');
    }
  }
}

