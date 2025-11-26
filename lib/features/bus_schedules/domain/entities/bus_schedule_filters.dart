class BusScheduleFilters {
  final String? route;
  final String? destination;
  final String? stop;
  final String? after; // HH:mm
  final String? before; // HH:mm
  final String? status;
  final String? dayOfWeek;

  BusScheduleFilters({
    this.route,
    this.destination,
    this.stop,
    this.after,
    this.before,
    this.status,
    this.dayOfWeek,
  });

  BusScheduleFilters copyWith({
    String? route,
    String? destination,
    String? stop,
    String? after,
    String? before,
    String? status,
    String? dayOfWeek,
  }) {
    return BusScheduleFilters(
      route: route ?? this.route,
      destination: destination ?? this.destination,
      stop: stop ?? this.stop,
      after: after ?? this.after,
      before: before ?? this.before,
      status: status ?? this.status,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    );
  }

  bool get hasFilters =>
      route != null ||
      destination != null ||
      stop != null ||
      after != null ||
      before != null ||
      status != null ||
      dayOfWeek != null;

  Map<String, dynamic> toJson() => {
        if (route != null) 'route': route,
        if (destination != null) 'destination': destination,
        if (stop != null) 'stop': stop,
        if (after != null) 'after': after,
        if (before != null) 'before': before,
        if (status != null) 'status': status,
        if (dayOfWeek != null) 'dayOfWeek': dayOfWeek,
      };
}