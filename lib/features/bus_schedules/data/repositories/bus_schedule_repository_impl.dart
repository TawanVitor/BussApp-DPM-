import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule.dart';
import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule_filters.dart';
import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule_list_response.dart';
import 'package:bussv1/features/bus_schedules/domain/repositories/i_bus_schedule_repository.dart';
import 'package:bussv1/features/bus_schedules/data/datasources/i_bus_schedules_local_datasource.dart';
import 'package:bussv1/features/bus_schedules/data/datasources/i_bus_schedules_remote_datasource.dart';
import 'package:bussv1/features/bus_schedules/data/mappers/bus_schedule_mapper.dart';

import '../models/bus_schedule_model.dart';

class BusScheduleRepositoryImpl implements IBusScheduleRepository {
  final IBusSchedulesLocalDatasource _localDatasource;
  final IBusSchedulesRemoteDatasource? _remoteDatasource;

  BusScheduleRepositoryImpl({
    required IBusSchedulesLocalDatasource localDatasource,
    IBusSchedulesRemoteDatasource? remoteDatasource,
  })  : _localDatasource = localDatasource,
        _remoteDatasource = remoteDatasource;

  @override
  Future<List<BusSchedule>> loadFromCache() async {
    try {
      final response = await _localDatasource.listAll(pageSize: 1000);
      return response.data;
    } catch (e) {
      print('Erro ao carregar cache: $e');
      return [];
    }
  }

  @override
  Future<int> syncFromServer() async {
    try {
      if (_remoteDatasource == null) return 0;
      
      // PUSH: enviar local para remoto
      final localResponse = await _localDatasource.listAll(pageSize: 10000);
      final localModels = BusScheduleMapper.toModelList(localResponse.data);
      await _remoteDatasource.upsertBusSchedules(localModels);
      
      // PULL: buscar remoto
      final remoteModels = await _remoteDatasource.fetchAll();
      final remoteEntities = BusScheduleMapper.toEntityList(remoteModels);
      
      // Aplicar ao cache
      final upserted = await upsertAll(remoteEntities);
      
      return upserted.length;
    } catch (e) {
      print('Erro ao sincronizar: $e');
      return 0;
    }
  }

  @override
  Future<BusScheduleListResponse> listAll({
    BusScheduleFilters? filters,
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    try {
      return await _localDatasource.listAll(
        filters: filters,
        pageSize: pageSize,
        page: pageNumber,
      );
    } catch (e) {
      print('Erro ao listar agendamentos: $e');
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

  @override
  Future<List<BusSchedule>> listFeatured() async {
    try {
      final response = await _localDatasource.listAll(pageSize: 10);
      // Filtrar por agendamentos destacados (ex: mais populares)
      return response.data.take(5).toList();
    } catch (e) {
      print('Erro ao listar destaque: $e');
      return [];
    }
  }

  @override
  Future<BusSchedule?> getById(String id) async {
    try {
      final response = await _localDatasource.listAll(pageSize: 1000);
      return response.data.firstWhere(
        (schedule) => schedule.id == id,
        orElse: () => throw Exception('Não encontrado'),
      );
    } catch (e) {
      print('Erro ao buscar por ID: $e');
      return null;
    }
  }

  @override
  Future<List<BusSchedule>> search(String query, {int limit = 50}) async {
    try {
      final response = await _localDatasource.listAll(pageSize: limit);
      final queryLower = query.toLowerCase();
      return response.data
          .where((schedule) =>
              schedule.routeName.toLowerCase().contains(queryLower) ||
              schedule.destination.toLowerCase().contains(queryLower) ||
              (schedule.origin?.toLowerCase().contains(queryLower) ?? false))
          .toList();
    } catch (e) {
      print('Erro ao buscar: $e');
      return [];
    }
  }

  @override
  Future<BusSchedule> create(BusSchedule schedule) async {
    try {
      final model = BusScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        routeName: schedule.routeName,
        destination: schedule.destination,
        departureTime: schedule.departureTime,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        routeNumber: schedule.routeNumber,
        origin: schedule.origin,
        arrivalTime: schedule.arrivalTime,
        distanceKm: schedule.distanceKm,
        durationMinutes: schedule.durationMinutes,
        imageUrl: schedule.imageUrl,
        stops: schedule.stops,
        frequencyMinutes: schedule.frequencyMinutes,
        operatingDays: schedule.operatingDays,
        accessibility: schedule.accessibility,
        fare: schedule.fare,
      );
      await (_localDatasource as dynamic).upsertAll([model]);
      return BusScheduleMapper.toEntity(model);
    } catch (e) {
      throw Exception('Erro ao criar agendamento: $e');
    }
  }

  @override
  Future<BusSchedule> update(String id, BusSchedule schedule) async {
    try {
      final model = BusScheduleModel(
        id: id,
        routeName: schedule.routeName,
        destination: schedule.destination,
        departureTime: schedule.departureTime,
        status: schedule.status,
        createdAt: schedule.createdAt,
        updatedAt: DateTime.now(),
        routeNumber: schedule.routeNumber,
        origin: schedule.origin,
        arrivalTime: schedule.arrivalTime,
        distanceKm: schedule.distanceKm,
        durationMinutes: schedule.durationMinutes,
        imageUrl: schedule.imageUrl,
        stops: schedule.stops,
        frequencyMinutes: schedule.frequencyMinutes,
        operatingDays: schedule.operatingDays,
        accessibility: schedule.accessibility,
        fare: schedule.fare,
      );
      await (_localDatasource as dynamic).upsertAll([model]);
      return BusScheduleMapper.toEntity(model);
    } catch (e) {
      throw Exception('Erro ao atualizar agendamento: $e');
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final response = await _localDatasource.listAll(pageSize: 10000);
      final filtered = response.data.where((s) => s.id != id).toList();
      await (_localDatasource as dynamic).clear();
      if (filtered.isNotEmpty) {
        final models = BusScheduleMapper.toModelList(filtered);
        await (_localDatasource as dynamic).upsertAll(models);
      }
      return true;
    } catch (e) {
      print('Erro ao deletar: $e');
      return false;
    }
  }

  @override
  Future<List<BusSchedule>> upsertAll(List<BusSchedule> schedules) async {
    try {
      final models = BusScheduleMapper.toModelList(schedules);
      await (_localDatasource as dynamic).upsertAll(models);
      return schedules;
    } catch (e) {
      throw Exception('Erro ao fazer upsert: $e');
    }
  }

  @override
  Future<bool> clear() async {
    try {
      await (_localDatasource as dynamic).clear();
      return true;
    } catch (e) {
      print('Erro ao limpar: $e');
      return false;
    }
  }
}