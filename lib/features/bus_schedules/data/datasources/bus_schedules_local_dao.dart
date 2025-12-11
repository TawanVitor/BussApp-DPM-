import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/bus_schedule.dart';
import '../../domain/entities/bus_schedule_filters.dart';
import '../../domain/entities/bus_schedule_list_response.dart';
import '../models/bus_schedule_model.dart';
import 'i_bus_schedules_local_datasource.dart';

class BusSchedulesLocalDao implements IBusSchedulesLocalDatasource {
  static const String _storageKey = 'bus_schedules_v1';
  static const int _defaultPage = 1;
  static const int _defaultPageSize = 20;
  static const int _maxPageSize = 100;

  Future<BusScheduleListResponse> listAll({
    BusScheduleFilters? filters,
    int page = _defaultPage,
    int pageSize = _defaultPageSize,
    String sortBy = 'departureTime',
    String sortDir = 'asc',
    List<String>? include,
  }) async {
    try {
      // Validações
      final validPage = page < 1 ? _defaultPage : page;
      final validPageSize = pageSize < 1
          ? _defaultPageSize
          : (pageSize > _maxPageSize ? _maxPageSize : pageSize);

      // Carregar dados
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      List<BusSchedule> allSchedules = [];

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final schedulesList = data['schedules'] as List? ?? [];
        allSchedules = schedulesList
            .map((json) => BusScheduleModel.fromJson(json))
            .toList();
      }

      // Aplicar filtros
      List<BusSchedule> filtered = _applyFilters(allSchedules, filters);

      // Aplicar ordenação
      filtered = _applySort(filtered, sortBy, sortDir);

      // Calcular paginação
      final total = filtered.length;
      final totalPages = (total / validPageSize).ceil();
      final startIndex = (validPage - 1) * validPageSize;
      final endIndex = startIndex + validPageSize;

      final paginatedData = filtered.sublist(
        startIndex,
        endIndex > total ? total : endIndex,
      );

      // Aplicar includes (remover stops se não solicitado)
      final finalData = _applyIncludes(paginatedData, include);

      return BusScheduleListResponse(
        meta: BusScheduleMeta(
          total: total,
          page: validPage,
          pageSize: validPageSize,
          totalPages: totalPages,
          hasNextPage: validPage < totalPages,
          hasPreviousPage: validPage > 1,
        ),
        filtersApplied: filters,
        sortApplied: BusScheduleSort(field: sortBy, direction: sortDir),
        includesApplied: include,
        data: finalData,
      );
    } catch (e) {
      print('Erro ao listar horários: $e');
      return BusScheduleListResponse(
        meta: BusScheduleMeta(
          total: 0,
          page: page,
          pageSize: pageSize,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        ),
        data: [],
      );
    }
  }

  List<BusSchedule> _applyFilters(
    List<BusSchedule> schedules,
    BusScheduleFilters? filters,
  ) {
    if (filters == null || !filters.hasFilters) return schedules;

    return schedules.where((schedule) {
      // Filtro de rota
      if (filters.route != null &&
          !schedule.routeName.toLowerCase().contains(
                filters.route!.toLowerCase(),
              )) {
        return false;
      }

      // Filtro de destino
      if (filters.destination != null &&
          !schedule.destination.toLowerCase().contains(
                filters.destination!.toLowerCase(),
              )) {
        return false;
      }

      // Filtro de parada
      if (filters.stop != null && schedule.stops != null) {
        final hasStop = schedule.stops!.any(
          (stop) => stop.name.toLowerCase().contains(
                filters.stop!.toLowerCase(),
              ),
        );
        if (!hasStop) return false;
      }

      // Filtro de horário mínimo (after)
      if (filters.after != null) {
        if (_compareTime(schedule.departureTime, filters.after!) < 0) {
          return false;
        }
      }

      // Filtro de horário máximo (before)
      if (filters.before != null) {
        if (_compareTime(schedule.departureTime, filters.before!) > 0) {
          return false;
        }
      }

      // Filtro de status
      if (filters.status != null && schedule.status != filters.status) {
        return false;
      }

      return true;
    }).toList();
  }

  int _compareTime(String time1, String time2) {
    try {
      final parts1 = time1.split(':');
      final parts2 = time2.split(':');
      final hours1 = int.parse(parts1[0]);
      final hours2 = int.parse(parts2[0]);
      final minutes1 = int.parse(parts1[1]);
      final minutes2 = int.parse(parts2[1]);

      if (hours1 != hours2) return hours1.compareTo(hours2);
      return minutes1.compareTo(minutes2);
    } catch (e) {
      return 0;
    }
  }

  List<BusSchedule> _applySort(
    List<BusSchedule> schedules,
    String sortBy,
    String sortDir,
  ) {
    final sorted = List<BusSchedule>.from(schedules);

    sorted.sort((a, b) {
      int comparison = 0;

      switch (sortBy) {
        case 'departureTime':
          comparison = _compareTime(a.departureTime, b.departureTime);
          break;
        case 'arrivalTime':
          if (a.arrivalTime != null && b.arrivalTime != null) {
            comparison = _compareTime(a.arrivalTime!, b.arrivalTime!);
          }
          break;
        case 'routeName':
          comparison = a.routeName.compareTo(b.routeName);
          break;
        case 'destination':
          comparison = a.destination.compareTo(b.destination);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return sortDir == 'desc' ? -comparison : comparison;
    });

    return sorted;
  }

  List<BusSchedule> _applyIncludes(
    List<BusSchedule> schedules,
    List<String>? include,
  ) {
    if (include == null || include.isEmpty) {
      // Remover stops se não solicitado
      return schedules
          .map((s) => s.copyWith(stops: include?.contains('stops') == true ? s.stops : null))
          .toList();
    }

    return schedules;
  }

  Future<void> upsertAll(List<BusSchedule> schedules) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      List<BusSchedule> existing = [];

      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final schedulesList = data['schedules'] as List? ?? [];
        existing = schedulesList
            .map((json) => BusScheduleModel.fromJson(json))
            .toList();
      }

      // Atualizar ou adicionar
      for (final newSchedule in schedules) {
        final index = existing.indexWhere((s) => s.id == newSchedule.id);
        if (index >= 0) {
          existing[index] = newSchedule;
        } else {
          existing.add(newSchedule);
        }
      }

      // Salvar
      final dataToSave = {
        'schedules': existing
            .map((s) => BusScheduleModel.fromJson({
                  'id': s.id,
                  'routeName': s.routeName,
                  'routeNumber': s.routeNumber,
                  'destination': s.destination,
                  'origin': s.origin,
                  'departureTime': s.departureTime,
                  'arrivalTime': s.arrivalTime,
                  'distance_km': s.distanceKm,
                  'duration_minutes': s.durationMinutes,
                  'image_url': s.imageUrl,
                  'status': s.status,
                  'stops': s.stops
                      ?.map((stop) => {
                            'id': stop.id,
                            'name': stop.name,
                            'street': stop.street,
                            'order': stop.order,
                            'latitude': stop.latitude,
                            'longitude': stop.longitude,
                            'estimatedTime': stop.estimatedTime,
                          })
                      .toList(),
                  'frequency_minutes': s.frequencyMinutes,
                  'operatingDays': s.operatingDays,
                  'accessibility': s.accessibility,
                  'fare': s.fare,
                  'createdAt': s.createdAt.toIso8601String(),
                  'updatedAt': s.updatedAt.toIso8601String(),
                }).toJson())
            .toList(),
        'lastSync': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, jsonEncode(dataToSave));
      print('Horários salvos com sucesso: ${schedules.length}');
    } catch (e) {
      print('Erro ao salvar horários: $e');
      rethrow;
    }
  }

  Future<void> clear({BusScheduleFilters? filters}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (filters == null || !filters.hasFilters) {
        // Limpar tudo
        await prefs.remove(_storageKey);
        print('Todos os horários foram removidos');
      } else {
        // Limpar apenas os filtrados
        final response = await listAll(filters: filters, pageSize: 10000);
        final idsToRemove = response.data.map((s) => s.id).toSet();

        final jsonStr = prefs.getString(_storageKey);
        if (jsonStr != null && jsonStr.isNotEmpty) {
          final data = jsonDecode(jsonStr) as Map<String, dynamic>;
          final schedulesList = data['schedules'] as List? ?? [];
          final remaining = schedulesList
              .where((json) => !idsToRemove.contains(json['id']))
              .toList();

          final dataToSave = {
            'schedules': remaining,
            'lastSync': DateTime.now().toIso8601String(),
          };

          await prefs.setString(_storageKey, jsonEncode(dataToSave));
          print('Horários filtrados removidos: ${idsToRemove.length}');
        }
      }
    } catch (e) {
      print('Erro ao limpar horários: $e');
      rethrow;
    }
  }

  @override
  Future<BusSchedule?> getById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr == null || jsonStr.isEmpty) {
        return null;
      }

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final schedulesList = data['schedules'] as List? ?? [];
      
      final schedule = schedulesList
          .map((json) => BusScheduleModel.fromJson(json))
          .firstWhere(
            (s) => s.id == id,
            orElse: () => null as dynamic,
          );
      
      return schedule;
    } catch (e) {
      print('Erro ao buscar por ID: $e');
      return null;
    }
  }

  @override
  Future<BusSchedule> create(BusSchedule entity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      List<dynamic> schedulesList = [];
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        schedulesList = data['schedules'] as List? ?? [];
      }

      final newModel = {
        'id': entity.id,
        'routeName': entity.routeName,
        'destination': entity.destination,
        'departureTime': entity.departureTime,
        'arrivalTime': entity.arrivalTime,
        'status': entity.status,
        'createdAt': entity.createdAt.toIso8601String(),
        'updatedAt': entity.updatedAt.toIso8601String(),
        'routeNumber': entity.routeNumber,
        'origin': entity.origin,
        'distanceKm': entity.distanceKm,
        'durationMinutes': entity.durationMinutes,
        'imageUrl': entity.imageUrl,
        'stops': entity.stops,
        'frequencyMinutes': entity.frequencyMinutes,
        'operatingDays': entity.operatingDays,
        'accessibility': entity.accessibility,
        'fare': entity.fare,
      };

      schedulesList.add(newModel);

      final dataToSave = {
        'schedules': schedulesList,
        'lastSync': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, jsonEncode(dataToSave));

      return entity;
    } catch (e) {
      print('Erro ao criar agendamento: $e');
      rethrow;
    }
  }

  @override
  Future<BusSchedule> update(BusSchedule entity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr == null || jsonStr.isEmpty) {
        throw Exception('Nenhum agendamento para atualizar');
      }

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final schedulesList = data['schedules'] as List? ?? [];

      final index = schedulesList.indexWhere((json) => json['id'] == entity.id);

      if (index == -1) {
        throw Exception('Agendamento não encontrado');
      }

      schedulesList[index] = {
        'id': entity.id,
        'routeName': entity.routeName,
        'destination': entity.destination,
        'departureTime': entity.departureTime,
        'arrivalTime': entity.arrivalTime,
        'status': entity.status,
        'createdAt': entity.createdAt.toIso8601String(),
        'updatedAt': entity.updatedAt.toIso8601String(),
        'routeNumber': entity.routeNumber,
        'origin': entity.origin,
        'distanceKm': entity.distanceKm,
        'durationMinutes': entity.durationMinutes,
        'imageUrl': entity.imageUrl,
        'stops': entity.stops,
        'frequencyMinutes': entity.frequencyMinutes,
        'operatingDays': entity.operatingDays,
        'accessibility': entity.accessibility,
        'fare': entity.fare,
      };

      final dataToSave = {
        'schedules': schedulesList,
        'lastSync': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, jsonEncode(dataToSave));

      return entity;
    } catch (e) {
      print('Erro ao atualizar agendamento: $e');
      rethrow;
    }
  }

  @override
  Future<bool> delete(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);

      if (jsonStr == null || jsonStr.isEmpty) {
        return false;
      }

      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      final schedulesList = data['schedules'] as List? ?? [];

      final initialLength = schedulesList.length;
      schedulesList.removeWhere((json) => json['id'] == id);

      if (schedulesList.length == initialLength) {
        return false;
      }

      final dataToSave = {
        'schedules': schedulesList,
        'lastSync': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_storageKey, jsonEncode(dataToSave));

      return true;
    } catch (e) {
      print('Erro ao deletar agendamento: $e');
      rethrow;
    }
  }

}