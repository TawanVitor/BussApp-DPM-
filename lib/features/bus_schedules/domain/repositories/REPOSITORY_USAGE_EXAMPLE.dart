/// Exemplo de Uso e Integração - Repositório BusSchedule
///
/// Este arquivo demonstra como integrar e usar o repositório
/// em diferentes partes da aplicação.
///

import 'package:flutter/material.dart';
import 'package:bussv1/features/bus_schedules/domain/repositories/i_bus_schedule_repository.dart';
import 'package:bussv1/features/bus_schedules/data/repositories/bus_schedule_repository_impl.dart';
import 'package:bussv1/features/bus_schedules/data/datasources/bus_schedules_local_dao.dart';

/// ============================================================================
/// 1. SETUP INICIAL (main.dart ou service_locator.dart)
/// ============================================================================

void setupBusScheduleRepository() {
  // Criar instância do DAO
  final localDao = BusSchedulesLocalDao();

  // Criar instância do repositório
  final IBusScheduleRepository repository = 
      BusScheduleRepositoryImpl(localDao: localDao);

  // Se usar GetIt ou similar, registrar como singleton:
  // getIt.registerSingleton<IBusScheduleRepository>(repository);
  
  // Ou guardar em uma variável global se necessário
  print('✅ Repositório inicializado: ${repository.runtimeType}');
}

/// ============================================================================
/// 2. USO EM CONTROLLER/PROVIDER
/// ============================================================================

class BusScheduleController {
  final IBusScheduleRepository _repository;

  BusScheduleController(this._repository);

  /// Inicializa dados (carrega cache + sincroniza com servidor)
  Future<void> initializeData() async {
    try {
      // 1️⃣ Carrega do cache rapidamente
      print('📥 Carregando cache...');
      final cached = await _repository.loadFromCache();
      print('✅ ${cached.length} agendamentos em cache');

      // 2️⃣ Sincroniza com servidor em background
      print('🔄 Sincronizando com servidor...');
      final changed = await _repository.syncFromServer();
      print('✅ $changed agendamentos sincronizados');

      // 3️⃣ Lista completa após sync
      print('📋 Listando agendamentos...');
      final response = await _repository.listAll(pageSize: 20);
      print('✅ ${response.data.length} agendamentos disponíveis');
    } catch (e) {
      print('❌ Erro ao inicializar: $e');
    }
  }

  /// Busca agendamentos em destaque
  Future<void> loadFeaturedSchedules() async {
    try {
      final featured = await _repository.listFeatured();
      print('⭐ ${featured.length} agendamentos em destaque');
    } catch (e) {
      print('❌ Erro ao carregar destaque: $e');
    }
  }

  /// Busca agendamentos por query
  Future<void> searchSchedules(String query) async {
    try {
      final results = await _repository.search(query);
      print('🔍 Encontrados ${results.length} resultados para "$query"');
    } catch (e) {
      print('❌ Erro ao buscar: $e');
    }
  }

  /// Obtém agendamento específico
  Future<void> getScheduleDetails(String id) async {
    try {
      final schedule = await _repository.getById(id);
      if (schedule != null) {
        print('📍 Agendamento encontrado: ${schedule.routeName}');
      } else {
        print('⚠️ Agendamento não encontrado');
      }
    } catch (e) {
      print('❌ Erro ao buscar agendamento: $e');
    }
  }
}

/// ============================================================================
/// 3. USO EM WIDGETS/PAGES (com FutureBuilder)
/// ============================================================================

class BusSchedulesListPageWithRepository extends StatefulWidget {
  final IBusScheduleRepository repository;

  const BusSchedulesListPageWithRepository({
    required this.repository,
  });

  @override
  State<BusSchedulesListPageWithRepository> createState() =>
      _BusSchedulesListPageWithRepositoryState();
}

class _BusSchedulesListPageWithRepositoryState
    extends State<BusSchedulesListPageWithRepository> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initialize();
  }

  Future<void> _initialize() async {
    await widget.repository.loadFromCache();
    await widget.repository.syncFromServer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Horários de Ônibus')),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          return _buildList();
        },
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder(
      future: widget.repository.listAll(pageSize: 20),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final response = snapshot.data!;

        if (response.data.isEmpty) {
          return const Center(child: Text('Nenhum agendamento encontrado'));
        }

        return ListView.builder(
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final schedule = response.data[index];
            return ListTile(
              title: Text(schedule.routeName),
              subtitle: Text('${schedule.origin ?? 'N/A'} → ${schedule.destination}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () async {
                final details = await widget.repository.getById(schedule.id);
                if (details != null && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Partida: ${details.departureTime}'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}

/// ============================================================================
/// 4. TESTES UNITÁRIOS - Exemplos de Mock (comentados)
/// ============================================================================

/*
Para criar um Mock adequado do repositório, use o pacote 'mockito':

dependency: mockito: ^5.4.0

Exemplo com mockito:

@GenerateMocks([IBusScheduleRepository])
void main() {
  late MockIBusScheduleRepository mockRepository;

  setUp(() {
    mockRepository = MockIBusScheduleRepository();
  });

  test('buscar agendamento deve retornar item correto', () async {
    // Arrange
    final schedule = BusScheduleModel(
      id: '1',
      routeName: 'Linha 250',
      destination: 'Terminal Central',
      departureTime: '14:00',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    when(mockRepository.getById('1'))
        .thenAnswer((_) async => schedule);
    
    // Act
    final result = await mockRepository.getById('1');
    
    // Assert
    expect(result?.routeName, equals('Linha 250'));
    verify(mockRepository.getById('1')).called(1);
  });

  test('listar agendamentos deve retornar lista', () async {
    // Arrange
    final response = BusScheduleListResponse(
      data: [
        BusScheduleModel(
          id: '1',
          routeName: 'Linha 250',
          destination: 'Terminal Central',
          departureTime: '14:00',
          status: 'active',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      meta: BusScheduleListResponseMeta(
        total: 1,
        page: 1,
        pageSize: 20,
        pages: 1,
      ),
    );
    
    when(mockRepository.listAll())
        .thenAnswer((_) async => response);
    
    // Act
    final result = await mockRepository.listAll();
    
    // Assert
    expect(result.data.length, equals(1));
    expect(result.meta.total, equals(1));
  });
}
*/

/// ============================================================================
/// 5. DICAS E BOAS PRÁTICAS
/// ============================================================================

/*
✅ FAZER:
- Use a interface IBusScheduleRepository em vez da implementação
- Injetar repositório através de construtores
- Tratar exceções com try/catch
- Usar FutureBuilder ou StreamBuilder em Widgets
- Cachear resultados quando apropriado
- Sincronizar com servidor em background
- Validar dados antes de persistir

❌ NÃO FAZER:
- Instanciar BusScheduleRepositoryImpl diretamente em Widgets
- Fazer requisições síncronas (usar sempre await em Future)
- Ignorar exceções com .catch() vazio
- Fazer múltiplas requisições simultâneas sem controle
- Persistir dados sem validação
- Bloquear UI durante operações de I/O

⚡ PERFORMANCE:
- Usar pageSize adequado (20-50 é comum)
- Implementar busca com debounce
- Cache agressivo para dados que mudam pouco
- Sincronização incremental (não sempre tudo)
- Considerar Stream/StateNotifier para atualizações em tempo real
*/
