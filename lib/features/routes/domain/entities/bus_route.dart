class BusRoute {
  final String id;
  final String name;
  final String from;
  final String to;
  final String time;
  final List<String> stops;
  final DateTime createdAt;

  BusRoute({
    required this.id,
    required this.name,
    required this.from,
    required this.to,
    required this.time,
    required this.stops,
    required this.createdAt,
  });

  BusRoute copyWith({
    String? id,
    String? name,
    String? from,
    String? to,
    String? time,
    List<String>? stops,
    DateTime? createdAt,
  }) {
    return BusRoute(
      id: id ?? this.id,
      name: name ?? this.name,
      from: from ?? this.from,
      to: to ?? this.to,
      time: time ?? this.time,
      stops: stops ?? this.stops,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
