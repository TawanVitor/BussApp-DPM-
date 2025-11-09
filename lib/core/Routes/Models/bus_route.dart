class BusRoute {
  String name;
  String from;
  String to;
  String time;
  List<String> stops;

  BusRoute({
    required this.name,
    required this.from,
    required this.to,
    required this.time,
    List<String>? stops,
  }) : stops = stops ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'from': from,
        'to': to,
        'time': time,
        'stops': stops,
      };

  factory BusRoute.fromJson(Map<String, dynamic> json) => BusRoute(
        name: json['name'] as String? ?? '',
        from: json['from'] as String? ?? '',
        to: json['to'] as String? ?? '',
        time: json['time'] as String? ?? '',
        stops: List<String>.from(json['stops'] ?? []),
      );
}