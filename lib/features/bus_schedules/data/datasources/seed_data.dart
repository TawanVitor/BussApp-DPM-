import '../../domain/entities/bus_schedule.dart';
import 'bus_schedules_local_dao.dart';

class BusSchedulesSeedData {
  static Future<void> seedIfEmpty() async {
    final dao = BusSchedulesLocalDao();
    
    try {
      final response = await dao.listAll(pageSize: 1);
      
      if (response.data.isEmpty) {
        print('Adicionando dados de exemplo para horários...');
        await dao.upsertAll(_getSampleSchedules());
        print('Dados de exemplo adicionados com sucesso!');
      }
    } catch (e) {
      print('Erro ao verificar/adicionar dados: $e');
    }
  }

  static List<BusSchedule> _getSampleSchedules() {
    final now = DateTime.now();
    
    return [
      BusSchedule(
        id: '1',
        routeName: 'Linha 250 - Centro/Terminal',
        routeNumber: '250',
        destination: 'Terminal Central',
        origin: 'Centro',
        departureTime: '06:00',
        arrivalTime: '06:40',
        distanceKm: 12.5,
        durationMinutes: 40,
        status: 'active',
        stops: [
          BusStop(
            id: 'stop-1',
            name: 'Ponto Centro',
            street: 'Rua Principal, 100',
            order: 1,
            estimatedTime: '06:00',
          ),
          BusStop(
            id: 'stop-2',
            name: 'Av. Brasil',
            street: 'Av. Brasil, 500',
            order: 2,
            estimatedTime: '06:15',
          ),
          BusStop(
            id: 'stop-3',
            name: 'Terminal Central',
            street: 'Terminal Rodoviário',
            order: 3,
            estimatedTime: '06:40',
          ),
        ],
        frequencyMinutes: 30,
        operatingDays: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'],
        accessibility: true,
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '2',
        routeName: 'Linha 250 - Centro/Terminal',
        routeNumber: '250',
        destination: 'Terminal Central',
        origin: 'Centro',
        departureTime: '06:30',
        arrivalTime: '07:10',
        distanceKm: 12.5,
        durationMinutes: 40,
        status: 'active',
        stops: [
          BusStop(
            id: 'stop-1',
            name: 'Ponto Centro',
            street: 'Rua Principal, 100',
            order: 1,
            estimatedTime: '06:30',
          ),
          BusStop(
            id: 'stop-2',
            name: 'Av. Brasil',
            street: 'Av. Brasil, 500',
            order: 2,
            estimatedTime: '06:45',
          ),
          BusStop(
            id: 'stop-3',
            name: 'Terminal Central',
            street: 'Terminal Rodoviário',
            order: 3,
            estimatedTime: '07:10',
          ),
        ],
        frequencyMinutes: 30,
        accessibility: true,
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '3',
        routeName: 'Linha 250 - Centro/Terminal',
        routeNumber: '250',
        destination: 'Terminal Central',
        origin: 'Centro',
        departureTime: '07:00',
        arrivalTime: '07:40',
        distanceKm: 12.5,
        durationMinutes: 40,
        status: 'active',
        frequencyMinutes: 30,
        accessibility: true,
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '4',
        routeName: 'Linha 301 - Bairro Norte',
        routeNumber: '301',
        destination: 'Bairro Norte',
        origin: 'Centro',
        departureTime: '06:15',
        arrivalTime: '06:50',
        distanceKm: 8.3,
        durationMinutes: 35,
        status: 'active',
        stops: [
          BusStop(
            id: 'stop-4',
            name: 'Centro',
            street: 'Praça Central',
            order: 1,
            estimatedTime: '06:15',
          ),
          BusStop(
            id: 'stop-5',
            name: 'Shopping',
            street: 'Av. Comercial',
            order: 2,
            estimatedTime: '06:30',
          ),
          BusStop(
            id: 'stop-6',
            name: 'Bairro Norte',
            street: 'Rua do Norte, 200',
            order: 3,
            estimatedTime: '06:50',
          ),
        ],
        frequencyMinutes: 45,
        accessibility: false,
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '5',
        routeName: 'Linha 150 - Universidade',
        routeNumber: '150',
        destination: 'Campus Universitário',
        origin: 'Centro',
        departureTime: '06:45',
        arrivalTime: '07:30',
        distanceKm: 15.2,
        durationMinutes: 45,
        status: 'active',
        stops: [
          BusStop(
            id: 'stop-7',
            name: 'Terminal Centro',
            street: 'Av. Central',
            order: 1,
            estimatedTime: '06:45',
          ),
          BusStop(
            id: 'stop-8',
            name: 'Hospital Municipal',
            street: 'Rua Saúde, 100',
            order: 2,
            estimatedTime: '07:00',
          ),
          BusStop(
            id: 'stop-9',
            name: 'Biblioteca Central',
            street: 'Campus UFPR',
            order: 3,
            estimatedTime: '07:20',
          ),
          BusStop(
            id: 'stop-10',
            name: 'Campus Universitário',
            street: 'Entrada Principal',
            order: 4,
            estimatedTime: '07:30',
          ),
        ],
        frequencyMinutes: 20,
        accessibility: true,
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '6',
        routeName: 'Linha 150 - Universidade',
        routeNumber: '150',
        destination: 'Campus Universitário',
        departureTime: '07:05',
        arrivalTime: '07:50',
        status: 'delayed',
        fare: 4.50,
        createdAt: now,
        updatedAt: now,
      ),
      BusSchedule(
        id: '7',
        routeName: 'Linha 450 - Aeroporto',
        routeNumber: '450',
        destination: 'Aeroporto Internacional',
        origin: 'Rodoviária',
        departureTime: '05:30',
        arrivalTime: '06:15',
        distanceKm: 18.7,
        durationMinutes: 45,
        status: 'active',
        frequencyMinutes: 60,
        accessibility: true,
        fare: 8.00,
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}