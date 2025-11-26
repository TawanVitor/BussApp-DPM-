
import '../../domain/entities/bus_route.dart';

class BusRouteModel extends BusRoute {
  BusRouteModel({
    required String id,
    required String name,
    required String from,
    required String to,
    required String time,
    required List<String> stops,
    required DateTime createdAt,
  }) : super(
         id: id,
         name: name,
         from: from,
         to: to,
         time: time,
         stops: stops,
         createdAt: createdAt,
       );

  factory BusRouteModel.fromJson(Map<String, dynamic> json) {
    return BusRouteModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      time: json['time'] as String? ?? '',
      stops: List<String>.from(json['stops'] ?? []),
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'from': from,
    'to': to,
    'time': time,
    'stops': stops,
    'createdAt': createdAt.toIso8601String(),
  };
}
