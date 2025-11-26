import '../../domain/entities/bus_schedule.dart';

class BusScheduleModel extends BusSchedule {
  BusScheduleModel({
    required String id,
    required String routeName,
    String? routeNumber,
    required String destination,
    String? origin,
    required String departureTime,
    String? arrivalTime,
    double? distanceKm,
    int? durationMinutes,
    String? imageUrl,
    required String status,
    List<BusStop>? stops,
    int? frequencyMinutes,
    List<String>? operatingDays,
    bool? accessibility,
    double? fare,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          routeName: routeName,
          routeNumber: routeNumber,
          destination: destination,
          origin: origin,
          departureTime: departureTime,
          arrivalTime: arrivalTime,
          distanceKm: distanceKm,
          durationMinutes: durationMinutes,
          imageUrl: imageUrl,
          status: status,
          stops: stops,
          frequencyMinutes: frequencyMinutes,
          operatingDays: operatingDays,
          accessibility: accessibility,
          fare: fare,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory BusScheduleModel.fromJson(Map<String, dynamic> json) {
    return BusScheduleModel(
      id: json['id'] as String? ?? '',
      routeName: json['routeName'] as String? ?? '',
      routeNumber: json['routeNumber'] as String?,
      destination: json['destination'] as String? ?? '',
      origin: json['origin'] as String?,
      departureTime: json['departureTime'] as String? ?? '',
      arrivalTime: json['arrivalTime'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: json['duration_minutes'] as int?,
      imageUrl: json['image_url'] as String?,
      status: json['status'] as String? ?? 'active',
      stops: json['stops'] != null
          ? (json['stops'] as List)
              .map((stop) => BusStopModel.fromJson(stop))
              .toList()
          : null,
      frequencyMinutes: json['frequency_minutes'] as int?,
      operatingDays: json['operatingDays'] != null
          ? List<String>.from(json['operatingDays'])
          : null,
      accessibility: json['accessibility'] as bool?,
      fare: (json['fare'] as num?)?.toDouble(),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'routeName': routeName,
        if (routeNumber != null) 'routeNumber': routeNumber,
        'destination': destination,
        if (origin != null) 'origin': origin,
        'departureTime': departureTime,
        if (arrivalTime != null) 'arrivalTime': arrivalTime,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (imageUrl != null) 'image_url': imageUrl,
        'status': status,
        if (stops != null)
          'stops': stops!.map((s) => BusStopModel.fromEntity(s).toJson()).toList(),
        if (frequencyMinutes != null) 'frequency_minutes': frequencyMinutes,
        if (operatingDays != null) 'operatingDays': operatingDays,
        if (accessibility != null) 'accessibility': accessibility,
        if (fare != null) 'fare': fare,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class BusStopModel extends BusStop {
  BusStopModel({
    required String id,
    required String name,
    required String street,
    required int order,
    double? latitude,
    double? longitude,
    String? estimatedTime,
  }) : super(
          id: id,
          name: name,
          street: street,
          order: order,
          latitude: latitude,
          longitude: longitude,
          estimatedTime: estimatedTime,
        );

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      street: json['street'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      estimatedTime: json['estimatedTime'] as String?,
    );
  }

  factory BusStopModel.fromEntity(BusStop stop) {
    return BusStopModel(
      id: stop.id,
      name: stop.name,
      street: stop.street,
      order: stop.order,
      latitude: stop.latitude,
      longitude: stop.longitude,
      estimatedTime: stop.estimatedTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'street': street,
        'order': order,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (estimatedTime != null) 'estimatedTime': estimatedTime,
      };
}