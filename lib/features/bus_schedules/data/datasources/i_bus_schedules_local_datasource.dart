import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule.dart';
import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule_filters.dart';
import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule_list_response.dart';

abstract class IBusSchedulesLocalDatasource {
  Future<BusScheduleListResponse> listAll({
    BusScheduleFilters? filters,
    int pageSize = 20,
    int page = 1,
  });

  Future<BusSchedule?> getById(String id);

  Future<BusSchedule> create(BusSchedule entity);

  Future<BusSchedule> update(BusSchedule entity);

  Future<bool> delete(String id);
}
