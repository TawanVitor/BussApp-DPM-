class BusSchedule {
  final String id;
  final String routeName;
  final String? routeNumber;
  final String destination;
  final String? origin;
  final String departureTime;
  final String? arrivalTime;
  final double? distanceKm;
  final int? durationMinutes;
  final String? imageUrl;
  final String status; // active, delayed, cancelled
  final List<BusStop>? stops;
  final int? frequencyMinutes;
  final List<String>? operatingDays;
  final bool? accessibility;
  final double? fare;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusSchedule({
    required this.id,
    required this.routeName,
    this.routeNumber,
    required this.destination,
    this.origin,
    required this.departureTime,
    this.arrivalTime,
    this.distanceKm,
    this.durationMinutes,
    this.imageUrl,
    required this.status,
    this.stops,
    this.frequencyMinutes,
    this.operatingDays,
    this.accessibility,
    this.fare,
    required this.createdAt,
    required this.updatedAt,
  });

  BusSchedule copyWith({
    String? id,
    String? routeName,
    String? routeNumber,
    String? destination,
    String? origin,
    String? departureTime,
    String? arrivalTime,
    double? distanceKm,
    int? durationMinutes,
    String? imageUrl,
    String? status,
    List<BusStop>? stops,
    int? frequencyMinutes,
    List<String>? operatingDays,
    bool? accessibility,
    double? fare,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusSchedule(
      id: id ?? this.id,
      routeName: routeName ?? this.routeName,
      routeNumber: routeNumber ?? this.routeNumber,
      destination: destination ?? this.destination,
      origin: origin ?? this.origin,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      stops: stops ?? this.stops,
      frequencyMinutes: frequencyMinutes ?? this.frequencyMinutes,
      operatingDays: operatingDays ?? this.operatingDays,
      accessibility: accessibility ?? this.accessibility,
      fare: fare ?? this.fare,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class BusStop {
  final String id;
  final String name;
  final String street;
  final int order;
  final double? latitude;
  final double? longitude;
  final String? estimatedTime;

  BusStop({
    required this.id,
    required this.name,
    required this.street,
    required this.order,
    this.latitude,
    this.longitude,
    this.estimatedTime,
  });

  BusStop copyWith({
    String? id,
    String? name,
    String? street,
    int? order,
    double? latitude,
    double? longitude,
    String? estimatedTime,
  }) {
    return BusStop(
      id: id ?? this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      order: order ?? this.order,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      estimatedTime: estimatedTime ?? this.estimatedTime,
    );
  }
}