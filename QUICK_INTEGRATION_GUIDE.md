# Guia de Integração - Remote Sync com Supabase

## 🚀 Quick Start (5 minutos)

### Passo 1: Adicionar Dependência

```bash
flutter pub add supabase_flutter
```

Ou no `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

### Passo 2: Configurar Supabase no main.dart

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bussapp/features/bus_schedules/infrastructure/remote/supabase_bus_schedules_remote_datasource.dart';
import 'package:bussapp/features/bus_schedules/data/datasources/bus_schedules_local_dao.dart';
import 'package:bussapp/features/bus_schedules/infrastructure/repositories/bus_schedules_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://seu-projeto.supabase.co',
    anonKey: 'sua-chave-anonima',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Instanciar o repository com remote sync
    final remoteApi = SupabaseBusSchedulesRemoteDatasource(
      client: Supabase.instance.client, // Passar cliente Supabase
    );
    final localDao = BusSchedulesLocalDao();
    final repository = BusSchedulesRepositoryImpl(
      remoteApi: remoteApi,
      localDao: localDao,
    );
    
    return MaterialApp(
      home: BusSchedulesPage(repository: repository),
    );
  }
}
```

### Passo 3: Usar no Widget

```dart
class BusSchedulesPage extends StatefulWidget {
  final IBusScheduleRepository repository;
  
  const BusSchedulesPage({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<BusSchedulesPage> createState() => _BusSchedulesPageState();
}

class _BusSchedulesPageState extends State<BusSchedulesPage> {
  late List<BusSchedule> _schedules = [];
  bool _isLoading = false;
  String? _lastSyncTime;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      // 1. Carregar do cache (rápido)
      final cached = await widget.repository.loadFromCache();
      if (mounted) {
        setState(() => _schedules = cached);
      }
      
      // 2. Sincronizar com servidor (background)
      final synced = await widget.repository.syncFromServer();
      if (kDebugMode) {
        print('Sincronizados $synced agendamentos');
      }
      
      // 3. Recarregar se houve mudanças
      if (mounted && synced > 0) {
        final updated = await widget.repository.loadFromCache();
        setState(() {
          _schedules = updated;
          _lastSyncTime = DateTime.now().toString();
        });
      }
    } catch (e) {
      if (mounted && kDebugMode) {
        print('Erro: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _schedules.length,
              itemBuilder: (context, index) {
                final schedule = _schedules[index];
                return ListTile(
                  title: Text(schedule.routeName),
                  subtitle: Text(schedule.destination),
                  trailing: Text(schedule.departureTime),
                );
              },
            ),
    );
  }
}
```

## 📋 Estrutura do Schema Supabase

Crie a tabela `bus_schedules` com as seguintes colunas:

```sql
CREATE TABLE bus_schedules (
  id TEXT PRIMARY KEY,
  route_name TEXT NOT NULL,
  destination TEXT NOT NULL,
  origin TEXT,
  departure_time TEXT NOT NULL,
  status TEXT DEFAULT 'active',
  accessibility BOOLEAN DEFAULT FALSE,
  fare REAL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  -- Adicione outras colunas conforme necessário
);

-- Índice para sincronização incremental
CREATE INDEX idx_updated_at ON bus_schedules(updated_at DESC);

-- RLS Policy: Apenas usuários autenticados podem ler
ALTER TABLE bus_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read for authenticated users" ON bus_schedules
  FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Allow insert/update for authenticated users" ON bus_schedules
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Allow update for authenticated users" ON bus_schedules
  FOR UPDATE
  USING (auth.role() = 'authenticated');

CREATE POLICY "Allow delete for authenticated users" ON bus_schedules
  FOR DELETE
  USING (auth.role() = 'authenticated');
```

## 🔐 Configuração RLS

Se você quer que QUALQUER PESSOA possa ler os dados (sem autenticação):

```sql
ALTER TABLE bus_schedules DISABLE ROW LEVEL SECURITY;
-- Ou deixar com policy pública:
CREATE POLICY "Allow read for everyone" ON bus_schedules
  FOR SELECT
  USING (true);
```

## 🧪 Testes

### Teste 1: Verificar Conexão

```dart
Future<void> _testConnection() async {
  try {
    final response = await Supabase.instance.client
        .from('bus_schedules')
        .select()
        .limit(1);
    
    print('✅ Conexão OK: $response');
  } catch (e) {
    print('❌ Erro de conexão: $e');
  }
}
```

### Teste 2: Verificar Sync

```dart
Future<void> _testSync() async {
  final repository = BusSchedulesRepositoryImpl(
    remoteApi: SupabaseBusSchedulesRemoteDatasource(),
    localDao: BusSchedulesLocalDao(),
  );
  
  print('🔄 Iniciando sync...');
  final synced = await repository.syncFromServer();
  print('✅ Sincronizados $synced agendamentos');
  
  final cached = await repository.loadFromCache();
  print('💾 Cache tem ${cached.length} agendamentos');
}
```

## 📊 Monitoramento

### Logs Disponíveis

Com `flutter run` ou `kDebugMode = true`:

1. **Início da sincronização:**
   ```
   BusSchedulesRepositoryImpl.syncFromServer: iniciando sincronização
   ```

2. **Leitura do last_sync:**
   ```
   BusSchedulesRepositoryImpl.syncFromServer: sincronização desde 2024-12-01 10:30:00.000Z
   ```

3. **Fetch do Supabase:**
   ```
   SupabaseBusSchedulesRemoteDatasource.fetchBusSchedules: recebidos 5 registros
   ```

4. **Persistência:**
   ```
   BusSchedulesRepositoryImpl.syncFromServer: 5 itens persistidos no cache
   ```

5. **Sucesso final:**
   ```
   BusSchedulesRepositoryImpl.syncFromServer: sucesso! 5 itens sincronizados
   ```

## ⚠️ Troubleshooting

### Erro: "Supabase not initialized"
```dart
// Solução: Chamar Supabase.initialize() antes de usar
await Supabase.initialize(url: '...', anonKey: '...');
```

### Erro: "Table not found"
```dart
// Verificar:
// 1. Nome da tabela no Supabase é 'bus_schedules'?
// 2. RLS está permitindo leitura?
// 3. Colunas existem (id, route_name, etc)?
```

### Erro: "DateTime parse error"
```dart
// O backend está retornando datas em qual formato?
// Verificar em supabase_bus_schedules_remote_datasource.dart:
// - updated_at precisa estar em ISO8601 (2024-12-01T10:30:00Z)
```

### Sync não funciona após editar dados
```dart
// Limpar cache e tentar novamente:
await repository.clear();
await repository.syncFromServer();
```

## 📈 Performance

### Benchmark Esperado (primeiros 10.000 agendamentos)

| Operação | Tempo | Notas |
|----------|-------|-------|
| loadFromCache() | 50-200ms | Depende do tamanho do cache |
| syncFromServer() (incremental) | 500-1500ms | Apenas itens modificados |
| syncFromServer() (first time) | 3-10s | Fetch + upsert de muitos itens |
| search() | 100-300ms | Em-memória, muito rápido |

### Otimizações Implementadas

- ✅ Sincronização incremental (apenas itens modificados desde `updated_at`)
- ✅ Pagination com limit (máx 500 itens por request)
- ✅ Índice `updated_at` no Supabase
- ✅ Timeout protection (30s)
- ✅ Cache local (SharedPreferences)

### Otimizações Futuras

- [ ] Implementar retry com exponential backoff
- [ ] Background sync com WorkManager
- [ ] Batch insert/update (vs individual upserts)
- [ ] Compressão de dados (se usar REST API)
- [ ] WebSocket para real-time updates

## 🔗 Links Úteis

- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Flutter SharedPreferences](https://pub.dev/packages/shared_preferences)

---

**Última atualização:** 2024-12-XX  
**Versão:** 1.0.0
