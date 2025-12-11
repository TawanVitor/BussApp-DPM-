import 'package:bussv1/features/bus_schedules/data/models/bus_schedule_model.dart';

abstract class IBusSchedulesRemoteDatasource {
  Future<List<BusScheduleModel>> fetchAll();

  Future<BusScheduleModel?> fetchById(String id);

  Future<BusScheduleModel> create(BusScheduleModel model);

  Future<BusScheduleModel> update(BusScheduleModel model);

  Future<bool> delete(String id);

  Future<int> upsertBusSchedules(List<BusScheduleModel> models);
}
