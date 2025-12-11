import 'package:bussv1/features/bus_schedules/data/models/bus_schedule_model.dart';
import 'package:bussv1/features/bus_schedules/domain/entities/bus_schedule.dart';

class BusScheduleMapper {
  static BusSchedule toEntity(BusScheduleModel model) {
    return BusSchedule(
      id: model.id,
      routeName: model.routeName,
      routeNumber: model.routeNumber,
      destination: model.destination,
      origin: model.origin,
      departureTime: model.departureTime,
      arrivalTime: model.arrivalTime,
      distanceKm: model.distanceKm,
      durationMinutes: model.durationMinutes,
      imageUrl: model.imageUrl,
      status: model.status,
      stops: model.stops,
      frequencyMinutes: model.frequencyMinutes,
      operatingDays: model.operatingDays,
      accessibility: model.accessibility,
      fare: model.fare,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static BusScheduleModel toModel(BusSchedule entity) {
    return BusScheduleModel(
      id: entity.id,
      routeName: entity.routeName,
      routeNumber: entity.routeNumber,
      destination: entity.destination,
      origin: entity.origin,
      departureTime: entity.departureTime,
      arrivalTime: entity.arrivalTime,
      distanceKm: entity.distanceKm,
      durationMinutes: entity.durationMinutes,
      imageUrl: entity.imageUrl,
      status: entity.status,
      stops: entity.stops,
      frequencyMinutes: entity.frequencyMinutes,
      operatingDays: entity.operatingDays,
      accessibility: entity.accessibility,
      fare: entity.fare,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static List<BusSchedule> toEntityList(List<BusScheduleModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  static List<BusScheduleModel> toModelList(List<BusSchedule> entities) {
    return entities.map((entity) => toModel(entity)).toList();
  }
}
