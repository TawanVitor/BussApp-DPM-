/// Exemplo de Injeção de Dependências com GetIt
///
/// Este arquivo mostra como configurar o Repository, RemoteApi e LocalDao
/// usando o pacote GetIt para injeção de dependências.
///
/// **Como usar:**
/// 1. Adicionar GetIt ao pubspec.yaml: `get_it: ^7.0.0`
/// 2. Chamar `setupServiceLocator()` no main() antes de runApp()
/// 3. Acessar repository em qualquer lugar: `getIt<IBusScheduleRepository>()`

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../features/bus_schedules/data/datasources/bus_schedules_local_dao.dart';
import '../features/bus_schedules/domain/repositories/i_bus_schedule_repository.dart';
import '../features/bus_schedules/infrastructure/remote/i_bus_schedules_remote_api.dart';
import '../features/bus_schedules/infrastructure/remote/supabase_bus_schedules_remote_datasource.dart';
import '../features/bus_schedules/infrastructure/repositories/bus_schedules_repository_impl.dart';

final getIt = GetIt.instance;

/// Configura todas as dependências da aplicação
/// Chamar uma única vez em main()
Future<void> setupServiceLocator() async {
  // 1. Registrar SharedPreferences (singleton)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // 2. Registrar DAO local (singleton)
  getIt.registerSingleton<BusSchedulesLocalDao>(
    BusSchedulesLocalDao(),
  );

  // 3. Registrar Remote API (singleton)
  // Se usar Supabase, passar o client aqui
  getIt.registerSingleton<IBusSchedulesRemoteApi>(
    SupabaseBusSchedulesRemoteDatasource(
      // client: Supabase.instance.client, // Descomentar quando integrar Supabase
    ),
  );

  // 4. Registrar Repository (singleton)
  getIt.registerSingleton<IBusScheduleRepository>(
    BusSchedulesRepositoryImpl(
      remoteApi: getIt<IBusSchedulesRemoteApi>(),
      localDao: getIt<BusSchedulesLocalDao>(),
    ),
  );

  print('✅ Service Locator configurado');
}

/// ============================================================================
/// EXEMPLO DE USO EM MAIN.DART
/// ============================================================================

/*
import 'package:flutter/material.dart';
import 'service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup de dependências
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BusSchedulesPage(),
    );
  }
}
*/

/// ============================================================================
/// EXEMPLO DE USO EM WIDGET
/// ============================================================================

/*
class BusSchedulesPage extends StatefulWidget {
  const BusSchedulesPage({Key? key}) : super(key: key);

  @override
  State<BusSchedulesPage> createState() => _BusSchedulesPageState();
}

class _BusSchedulesPageState extends State<BusSchedulesPage> {
  late IBusScheduleRepository _repository;
  late List<BusSchedule> _schedules = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Acessar repository injetado
    _repository = getIt<IBusScheduleRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Carregar cache
      final cached = await _repository.loadFromCache();
      if (mounted) {
        setState(() => _schedules = cached);
      }
      
      // Sincronizar em background
      await _repository.syncFromServer();
      
      // Recarregar UI
      if (mounted) {
        final updated = await _repository.loadFromCache();
        setState(() => _schedules = updated);
      }
    } catch (e) {
      print('Erro: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_schedules[index].routeName),
                );
              },
            ),
    );
  }
}
*/

/// ============================================================================
/// SETUP COM SUPABASE
/// ============================================================================

/*
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase ANTES de setupServiceLocator
  await Supabase.initialize(
    url: 'https://seu-projeto.supabase.co',
    anonKey: 'sua-chave-anonima',
  );

  // Setup de dependências
  await setupServiceLocator();

  runApp(const MyApp());
}

// Depois atualizar setupServiceLocator para:
Future<void> setupServiceLocator() async {
  // ... (registros anteriores)
  
  // Registrar Remote API COM cliente Supabase
  getIt.registerSingleton<IBusSchedulesRemoteApi>(
    SupabaseBusSchedulesRemoteDatasource(
      client: Supabase.instance.client, // ← Passar aqui
    ),
  );
  
  // ... (resto do código)
}
*/

/// ============================================================================
/// SETUP COM RIVERPOD (ALTERNATIVA)
/// ============================================================================

/*
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Providers
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

final busSchedulesLocalDaoProvider = Provider<BusSchedulesLocalDao>((ref) {
  return BusSchedulesLocalDao();
});

final busSchedulesRemoteApiProvider = Provider<IBusSchedulesRemoteApi>((ref) {
  return SupabaseBusSchedulesRemoteDatasource();
});

final busScheduleRepositoryProvider = Provider<IBusScheduleRepository>((ref) {
  final remoteApi = ref.watch(busSchedulesRemoteApiProvider);
  final localDao = ref.watch(busSchedulesLocalDaoProvider);
  
  return BusSchedulesRepositoryImpl(
    remoteApi: remoteApi,
    localDao: localDao,
  );
});

// Uso em Widget:
class BusSchedulesPage extends ConsumerWidget {
  const BusSchedulesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.watch(busScheduleRepositoryProvider);
    
    return Scaffold(
      // ... usar repository
    );
  }
}
*/

/// ============================================================================
/// SETUP COM PROVIDER (ALTERNATIVA)
/// ============================================================================

/*
import 'package:provider/provider.dart';

// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final localDao = BusSchedulesLocalDao();
  final remoteApi = SupabaseBusSchedulesRemoteDatasource();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        Provider<BusSchedulesLocalDao>.value(value: localDao),
        Provider<IBusSchedulesRemoteApi>.value(value: remoteApi),
        Provider<IBusScheduleRepository>(
          create: (_) => BusSchedulesRepositoryImpl(
            remoteApi: remoteApi,
            localDao: localDao,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Uso em Widget:
class BusSchedulesPage extends StatelessWidget {
  const BusSchedulesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final repository = context.read<IBusScheduleRepository>();
    
    return Scaffold(
      // ... usar repository
    );
  }
}
*/

/// ============================================================================
/// TESTES COM MOCKS (EXEMPLO COM GET_IT)
/// ============================================================================

/*
// mock_remote_api.dart
class MockBusSchedulesRemoteApi implements IBusSchedulesRemoteApi {
  @override
  Future<RemotePage<BusScheduleModel>> fetchBusSchedules({
    DateTime? since,
    int limit = 500,
    int offset = 0,
  }) async {
    // Retornar dados mock
    return RemotePage(
      items: [
        BusScheduleModel(
          id: '1',
          routeName: 'Rota 1',
          destination: 'Destino 1',
          departureTime: '08:00',
          status: 'active',
          accessibility: false,
          fare: 5.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ],
      hasNext: false,
    );
  }
  
  @override
  Future<BusScheduleModel> upsertBusSchedule(BusScheduleModel model) async {
    return model;
  }
  
  @override
  Future<bool> deleteBusSchedule(String id) async {
    return true;
  }
}

// test/repository_test.dart
void main() {
  group('BusSchedulesRepository Tests', () {
    late BusSchedulesRepositoryImpl repository;
    late MockBusSchedulesRemoteApi mockRemoteApi;
    late BusSchedulesLocalDao mockLocalDao;
    
    setUp(() {
      mockRemoteApi = MockBusSchedulesRemoteApi();
      mockLocalDao = BusSchedulesLocalDao();
      
      repository = BusSchedulesRepositoryImpl(
        remoteApi: mockRemoteApi,
        localDao: mockLocalDao,
      );
    });
    
    test('syncFromServer retorna itens mock', () async {
      final count = await repository.syncFromServer();
      expect(count, greaterThan(0));
    });
  });
}
*/

/// ============================================================================
/// CHECKLIST PARA INTEGRAÇÃO
/// ============================================================================

/*
✅ Checklist de Integração com Service Locator:

1. PREPARAÇÃO
   [ ] Adicionar GetIt ao pubspec.yaml
   [ ] Criar arquivo service_locator.dart (este arquivo)
   [ ] Imports corretos para all classes

2. SETUP
   [ ] Chamar setupServiceLocator() em main()
   [ ] WidgetsFlutterBinding.ensureInitialized() primeiro
   [ ] SharedPreferences.getInstance() antes de registrar

3. VERIFICAÇÃO
   [ ] Testar: getIt<IBusScheduleRepository>() não nula
   [ ] Testar: loadFromCache() retorna lista
   [ ] Testar: syncFromServer() retorna número

4. DEBUGGING
   [ ] Adicionar print statements em setupServiceLocator()
   [ ] Verificar logs: "✅ Service Locator configurado"
   [ ] Se erro: verificar ordem de registros (dependências primeiro)

5. DEPLOY
   [ ] Testar em emulador primeiro
   [ ] Testar em device real
   [ ] Monitorar logs em primeiro acesso
*/
