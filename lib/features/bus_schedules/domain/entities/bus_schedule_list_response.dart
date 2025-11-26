import 'bus_schedule.dart';
import 'bus_schedule_filters.dart';

class BusScheduleListResponse {
  final BusScheduleMeta meta;
  final BusScheduleFilters? filtersApplied;
  final BusScheduleSort? sortApplied;
  final List<String>? includesApplied;
  final List<BusSchedule> data;

  BusScheduleListResponse({
    required this.meta,
    this.filtersApplied,
    this.sortApplied,
    this.includesApplied,
    required this.data,
  });
}

class BusScheduleMeta {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  BusScheduleMeta({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });
}

class BusScheduleSort {
  final String field;
  final String direction; // asc | desc

  BusScheduleSort({
    required this.field,
    required this.direction,
  });
}