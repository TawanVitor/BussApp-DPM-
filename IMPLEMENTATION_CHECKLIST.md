# ✅ Checklist Prático de Implementação - Remote Sync v2.0

## 🎯 Objetivo
Integrar o sistema de sincronização com Supabase ao seu projeto Flutter existente, testando cada passo.

---

## 📋 PARTE 1: SUPABASE (Setup Inicial)

### Passo 1.1: Criar Projeto Supabase
- [ ] Ir para https://supabase.com
- [ ] Criar novo projeto (ou usar existente)
- [ ] Anotar:
  - [ ] **Project URL:** `https://seu-projeto.supabase.co`
  - [ ] **Anon Key:** `eyJhbGci... (começando com eyJ)`
- [ ] Esperar projeto ficar "ready" (verde)

### Passo 1.2: Criar Schema do Banco
- [ ] Abrir Supabase Dashboard → SQL Editor
- [ ] Copiar conteúdo de `supabase_schema.sql`
- [ ] Colar no SQL Editor
- [ ] Executar cada seção:
  - [ ] `CREATE TABLE bus_schedules` (Seção 1)
  - [ ] `CREATE INDEX` (Seção 2)
  - [ ] `CREATE FUNCTION` + `CREATE TRIGGER` (Seções 3-4)
  - [ ] `ALTER TABLE ENABLE ROW LEVEL SECURITY` (Seção 5)
  - [ ] Executar Opção A ou B (Políticas RLS)
  - [ ] ✅ Opcional: Inserir dados de teste (Seção 8)

### Passo 1.3: Verificar Criação
- [ ] Abrir Supabase Dashboard → Table Editor
- [ ] Procurar tabela `bus_schedules`
- [ ] Ver colunas:
  - [ ] id, route_name, destination, departure_time, status, updated_at, etc
- [ ] Se tiver dados de teste:
  - [ ] Selecionar primeira linha
  - [ ] Verificar que `created_at` e `updated_at` estão preenchidos
- [ ] ✅ Se tudo OK: Marque como completo

---

## 📦 PARTE 2: ADICIONAR DEPENDÊNCIA

### Passo 2.1: Adicionar supabase_flutter
```bash
cd /caminho/para/seu/projeto
flutter pub add supabase_flutter
```

- [ ] Comando executado sem erros
- [ ] `pubspec.yaml` agora contém: `supabase_flutter: ^2.0.0`

### Passo 2.2: Verificar Instalação
```bash
flutter pub get
```

- [ ] Comando executado sem erros
- [ ] Sem erros de incompatibilidade

---

## 🔧 PARTE 3: CONFIGURAR NO MAIN.DART

### Passo 3.1: Importar Supabase

Abrir `lib/main.dart` e adicionar no topo:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
```

- [ ] Arquivo modificado
- [ ] Sem "red squiggly" (erros)

### Passo 3.2: Inicializar Supabase

Na função `main()`, ANTES de `runApp()`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ADICIONAR ISTO (usar suas credenciais)
  await Supabase.initialize(
    url: 'https://seu-projeto.supabase.co',
    anonKey: 'sua-chave-anonima-aqui',
  );
  
  runApp(const MyApp());
}
```

- [ ] Credenciais substituídas (URL e anonKey)
- [ ] Sem erros de compilação
- [ ] ⚠️ IMPORTANTE: Substituir com seus valores reais!

### Passo 3.3: Verificar Compilação

```bash
flutter run
```

- [ ] App compila sem erros
- [ ] Sem erros de "Supabase not initialized"
- [ ] App abre normalmente

---

## 🔗 PARTE 4: INJETAR NO REPOSITORY

### Passo 4.1: Onde Instanciar Repository

Encontrar ou criar um local ÚNICO para instanciar:

**Opção A: Em main.dart (Simples)**
```dart
final remoteApi = SupabaseBusSchedulesRemoteDatasource(
  client: Supabase.instance.client,
);
final localDao = BusSchedulesLocalDao();
final repository = BusSchedulesRepositoryImpl(
  remoteApi: remoteApi,
  localDao: localDao,
);
```

**Opção B: Com GetIt (Recomendado)**
Ver `service_locator_example.dart`

- [ ] Escolher opção (A ou B)
- [ ] Documentar onde foi criado

### Passo 4.2: Passar ao Widget Principal

Se usar opção A:
```dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: BusSchedulesPage(repository: repository),
  );
}
```

- [ ] Repository injetado no widget principal
- [ ] Sem erros de compilação

---

## 🧪 PARTE 5: TESTAR CACHE LOCAL (Sem Supabase)

### Passo 5.1: Testar BusSchedulesLocalDao
```dart
// Em um botão ou initState:
void _testLocalCache() async {
  try {
    final dao = BusSchedulesLocalDao();
    
    // Tentar listar (vazio no início)
    final response = await dao.listAll();
    print('Cache tem ${response.data.length} agendamentos');
    
    // Se vazio, tudo OK
    assert(response.data.isEmpty);
    print('✅ Cache local funciona');
  } catch (e) {
    print('❌ Erro cache: $e');
  }
}
```

- [ ] Chamar função ao abrir app
- [ ] Ver log: "Cache local funciona"
- [ ] ✅ Teste passou

---

## 🌐 PARTE 6: TESTAR SUPABASE REMOTO

### Passo 6.1: Testar Conexão Remota
```dart
void _testSupabaseConnection() async {
  try {
    print('Testando conexão Supabase...');
    
    final client = Supabase.instance.client;
    final response = await client
        .from('bus_schedules')
        .select()
        .limit(1);
    
    print('✅ Supabase conectado! Resposta: $response');
  } catch (e) {
    print('❌ Erro Supabase: $e');
  }
}
```

- [ ] Chamar função ao abrir app
- [ ] Se dados de teste foram inseridos:
  - [ ] Ver log: "✅ Supabase conectado!"
  - [ ] Ver resposta com dados
- [ ] Se erro "RLS":
  - [ ] Voltar ao Supabase → SQL Editor
  - [ ] Executar Opção A (políticas públicas)
  - [ ] Testar novamente
- [ ] ✅ Conexão OK

### Passo 6.2: Testar RemoteApi
```dart
void _testRemoteApi() async {
  try {
    print('Testando RemoteApi...');
    
    final api = SupabaseBusSchedulesRemoteDatasource(
      client: Supabase.instance.client,
    );
    
    final page = await api.fetchBusSchedules(limit: 10);
    print('✅ RemoteApi OK! ${page.items.length} itens');
  } catch (e) {
    print('❌ Erro RemoteApi: $e');
  }
}
```

- [ ] Chamar função
- [ ] Ver log com sucesso ou erro
- [ ] ✅ RemoteApi OK

---

## 🔄 PARTE 7: TESTAR SINCRONIZAÇÃO

### Passo 7.1: Testar syncFromServer()
```dart
void _testSync() async {
  try {
    print('Testando sincronização...');
    
    final repository = BusSchedulesRepositoryImpl(
      remoteApi: SupabaseBusSchedulesRemoteDatasource(
        client: Supabase.instance.client,
      ),
      localDao: BusSchedulesLocalDao(),
    );
    
    // Testar sync
    int synced = await repository.syncFromServer();
    print('✅ Sincronizados $synced agendamentos');
    
    // Testar cache depois
    final cached = await repository.loadFromCache();
    print('💾 Cache tem ${cached.length} agendamentos');
    
    assert(synced >= 0);
    assert(cached.isNotEmpty || synced == 0);
    print('✅ Sincronização funcionou!');
    
  } catch (e) {
    print('❌ Erro sync: $e');
  }
}
```

- [ ] Chamar função
- [ ] Ver logs:
  - [ ] "Sincronizados X agendamentos"
  - [ ] "Cache tem Y agendamentos"
  - [ ] "Sincronização funcionou!"
- [ ] Se erro:
  - [ ] Verificar erro específico no log
  - [ ] Consultar "Troubleshooting" abaixo
- [ ] ✅ Sincronização OK

### Passo 7.2: Testar Segunda Sync (Incremental)
```dart
void _testIncrementalSync() async {
  try {
    print('Testando sincronização incremental...');
    
    final repository = /* ... */;
    
    // Primeira sync
    final sync1 = await repository.syncFromServer();
    print('1ª sync: $sync1 itens');
    
    // Aguardar 2 segundos
    await Future.delayed(Duration(seconds: 2));
    
    // Segunda sync (deve ser menor ou igual)
    final sync2 = await repository.syncFromServer();
    print('2ª sync: $sync2 itens');
    
    // Segunda sync deve ter menos itens (incremental)
    assert(sync2 <= sync1);
    print('✅ Incremental sync OK!');
    
  } catch (e) {
    print('❌ Erro: $e');
  }
}
```

- [ ] Chamar função
- [ ] Ver logs:
  - [ ] "1ª sync: X itens"
  - [ ] "2ª sync: Y itens (Y <= X)"
  - [ ] "Incremental sync OK!"
- [ ] ✅ Teste passou

---

## 📱 PARTE 8: INTEGRAR NO WIDGET REAL

### Passo 8.1: Modificar initState do Widget
```dart
@override
void initState() {
  super.initState();
  _loadSchedules();
}

Future<void> _loadSchedules() async {
  if (!mounted) return;
  
  setState(() => _isLoading = true);
  
  try {
    // 1. Carregar cache rápido
    final cached = await _repository.loadFromCache();
    if (mounted) {
      setState(() => _schedules = cached);
    }
    
    // 2. Sincronizar em background
    final synced = await _repository.syncFromServer();
    if (kDebugMode) {
      print('Sincronizados $synced agendamentos');
    }
    
    // 3. Recarregar se mudou
    if (mounted && synced > 0) {
      final updated = await _repository.loadFromCache();
      setState(() => _schedules = updated);
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
```

- [ ] Código copiado para widget
- [ ] `_repository` está acessível (injetado ou global)
- [ ] Compile: `flutter run`
- [ ] ✅ Widget renderiza com dados

### Passo 8.2: Testar em Emulador
- [ ] Abrir app
- [ ] Verificar logs:
  - [ ] "loadFromCache: carregados X agendamentos"
  - [ ] "syncFromServer: sincronizados Y agendamentos"
  - [ ] "Cache tem Z agendamentos"
- [ ] Verificar UI:
  - [ ] Lista mostra dados do cache
  - [ ] Loading desaparece
  - [ ] Sem erros visíveis
- [ ] ✅ Tudo funciona

---

## 📊 PARTE 9: TESTAR MUDANÇAS REMOTAS

### Passo 9.1: Inserir Dados no Supabase
- [ ] Abrir Supabase Dashboard → Table Editor
- [ ] Clicar em `bus_schedules`
- [ ] Clicar "Insert row"
- [ ] Preencher:
  - [ ] id: `test-route-123`
  - [ ] route_name: `Rota Teste`
  - [ ] destination: `Destino Teste`
  - [ ] departure_time: `15:00`
  - [ ] status: `active`
- [ ] Clicar "Save"
- [ ] ✅ Dado inserido

### Passo 9.2: Sincronizar no App
- [ ] Abrir app novamente (ou chamar `_loadSchedules()`)
- [ ] Ver logs:
  - [ ] "syncFromServer: sincronizados 1 agendamentos"
- [ ] Verificar UI:
  - [ ] Novo agendamento aparece na lista
- [ ] ✅ Sincronização de mudanças funciona

---

## 🛠️ PARTE 10: TESTAR EDIÇÃO LOCAL

### Passo 10.1: Testar Edit Feature Existente
- [ ] Abrir app
- [ ] Clicar em agendamento (deve ter 🖊️ ícone)
- [ ] Clicar para editar
- [ ] Alterar campo (ex: destination)
- [ ] Salvar edição
- [ ] Verificar:
  - [ ] UI atualiza localmente
  - [ ] Dado persiste após reload
- [ ] ✅ Edit feature funciona

### Passo 10.2: Verificar Persistência
- [ ] Fechar app completamente
- [ ] Reabrir app
- [ ] Verificar que edição foi mantida
- [ ] ✅ Dados persistem corretamente

---

## 📋 PARTE 11: VALIDAÇÃO FINAL

### Passo 11.1: Checklist de Performance
- [ ] Cache carrega em < 200ms (instantâneo)
- [ ] Sync completa em < 2 segundos
- [ ] Nenhum travamento
- [ ] Nenhum memory leak (monitore Device → Memory no IDE)

### Passo 11.2: Checklist de Funcionalidade
- [ ] ✅ loadFromCache() retorna dados
- [ ] ✅ syncFromServer() sincroniza mudanças
- [ ] ✅ listAll() com filtros funciona
- [ ] ✅ getById() encontra agendamento
- [ ] ✅ search() localiza rotas
- [ ] ✅ create() adiciona novo agendamento
- [ ] ✅ update() edita agendamento
- [ ] ✅ delete() remove agendamento
- [ ] ✅ clear() limpa cache

### Passo 11.3: Checklist de Logs
- [ ] kDebugMode prints aparecem no console
- [ ] Logs mostram timestamps
- [ ] Erros são captturados e logados
- [ ] Sem exceções não capturadas

---

## 🐛 PARTE 12: TROUBLESHOOTING

| Erro | Causa | Solução |
|------|-------|---------|
| "Target of URI doesn't exist" | supabase_flutter não instalado | `flutter pub add supabase_flutter` |
| "Supabase not initialized" | Supabase.initialize() não chamado | Chamar em main() ANTES de runApp() |
| "Table not found" | Tabela bus_schedules não criada | Executar supabase_schema.sql |
| "RLS denied" | RLS policies bloqueando | Executar Opção A (públicas) em supabase_schema.sql |
| "DateTime parse error" | Formato de data incorreto | Verificar se returned_at está em ISO8601 |
| "setState called after dispose" | Widget descartado durante async | Adicionar `if (mounted)` SEMPRE |
| "Empty list" | Nenhum dado no Supabase | Inserir dados de teste manualmente |
| "Timeout" | Requisição demorando > 30s | Aumentar timeout ou dividir sync em chunks |

---

## ✅ CONCLUSÃO

Se todos os passos acima foram completados com ✅:

🎉 **Parabéns! Seu sistema de sincronização com Supabase está funcionando!**

### Próximas Melhorias (Opcional)
- [ ] Adicionar indicador visual de sincronização
- [ ] Implementar retry com exponential backoff
- [ ] Adicionar background sync com WorkManager
- [ ] Implementar real-time updates com WebSocket

---

## 📞 Ajuda

Se tiver dúvidas:
1. Revisar logs com `kDebugMode`
2. Consultar `QUICK_INTEGRATION_GUIDE.md`
3. Consultar `TECHNICAL_SUMMARY.md`
4. Verificar `supabase_schema.sql` novamente

---

**Última Atualização:** 2024-12-XX  
**Versão:** 2.0.0 (Supabase Sync)
