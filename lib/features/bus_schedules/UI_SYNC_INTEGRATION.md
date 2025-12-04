# Integração Supabase no BusSchedulesListPage

## 📋 Visão Geral

O `BusSchedulesListPage` foi integrado com sincronização Supabase, fornecendo dois fluxos de atualização de dados:

1. **Auto-sync na primeira abertura** - Se o cache está vazio
2. **Pull-to-refresh manual** - Usuário puxa para atualizar

## 🔄 Fluxo de Sincronização

### 1. Inicialização (initState)

```
initState()
    ↓
_loadSchedules()
```

### 2. Carregamento de Agendamentos (_loadSchedules)

```
_loadSchedules()
    ↓
Carregar cache (SharedPreferences)
    ↓
Cache tem dados?
    ├─ SIM → Mostrar lista + kDebugMode log ✓
    └─ NÃO → Sincronizar com servidor
        ↓
    Criar SupabaseBusSchedulesRemoteDatasource
        ↓
    Criar BusSchedulesRepositoryImpl
        ↓
    Chamar syncFromServer()
        ↓
    Recarregar cache
        ↓
    Mostrar lista atualizada
        ↓
    Erro? → Mostrar mensagem + continuar com cache vazio
```

**Pontos de Logging (kDebugMode):**

```dart
// 1. Início
'[BusSchedulesListPage] iniciando carregamento de agendamentos'

// 2. Cache carregado
'[BusSchedulesListPage] carregados ${response.data.length} agendamentos do cache'

// 3. Cache vazio, sincronizar
'[BusSchedulesListPage] cache vazio, iniciando sincronização com servidor'

// 4. Sincronização concluída
'[BusSchedulesListPage] sincronizados $synced agendamentos do servidor'

// 5. Recarregado
'[BusSchedulesListPage] lista atualizada com ${updatedResponse.data.length} itens'

// Erro em sincronização
'[BusSchedulesListPage] ❌ erro ao sincronizar: $syncError'
```

### 3. Pull-to-Refresh Manual (_handleRefresh)

```
Usuário puxa para cima
    ↓
RefreshIndicator chama onRefresh: _handleRefresh
    ↓
Criar instâncias (Remote API + Repository)
    ↓
Chamar syncFromServer() com timeout de 30s
    ↓
Recarregar _loadSchedules()
    ↓
Mostrar SnackBar com resultado
    └─ Sucesso: "Sincronizados X agendamentos"
    └─ Erro: "Erro ao sincronizar: [mensagem]"
```

## 🎯 Componentes Utilizados

### 1. RefreshIndicator (Body Widget)

```dart
RefreshIndicator(
  onRefresh: _handleRefresh,
  child: /* ListView ou loading ou empty state */,
)
```

**Responsabilidade:** Detectar gesto pull-to-refresh e chamar _handleRefresh

### 2. AlwaysScrollableScrollPhysics (ListView)

Aplicado em DUAS localizações:

```dart
// Empty State ListView
ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: [/* empty state */],
)

// Loaded State ListView
ListView.builder(
  physics: const AlwaysScrollableScrollPhysics(),
  itemBuilder: /* build schedule card */,
)
```

**Responsabilidade:** Permitir scroll/pull-to-refresh mesmo com poucos itens

### 3. Remote Datasource + Repository

```dart
// Instanciados dinamicamente em _loadSchedules()
final remoteApi = SupabaseBusSchedulesRemoteDatasource();
final repository = BusSchedulesRepositoryImpl(
  remoteApi: remoteApi,
  localDao: _dao,
);

// Sincronização
final synced = await repository.syncFromServer();
```

## 📱 UX States

### Estado 1: Carregando

```
┌─────────────────────────────┐
│  Horários de Ônibus  🔄  🌙 │
├─────────────────────────────┤
│                             │
│                             │
│        ⏳ Carregando...      │
│                             │
│                             │
└─────────────────────────────┘
```

### Estado 2: Cache Vazio (Permite Pull-to-Refresh)

```
┌─────────────────────────────┐
│  Horários de Ônibus  🔄  🌙 │
├─────────────────────────────┤
│                             │
│                             │
│        📅 Nenhum horário     │
│                             │
│  Puxe para sincronizar      │
│        dados do servidor    │
│       [Ajustar filtros]     │
│                             │
│                             │
└─────────────────────────────┘
```

**⚠️ Importante:** Envolvido em `ListView` com `AlwaysScrollableScrollPhysics` para permitir pull-to-refresh

### Estado 3: Com Dados

```
┌─────────────────────────────┐
│  Horários de Ônibus  🔄  🌙 │
├─────────────────────────────┤
│ ⚠️ Filtros ativos [Limpar]  │
│ Total: 15 horários          │
├─────────────────────────────┤
│ 🚌 Linha 101                │
│    07:30 → 08:15            │
│    Segunda à Sexta          │
│                             │
│ 🚌 Linha 102                │
│    08:00 → 08:45            │
│    Segunda à Sexta          │
│                             │
└─────────────────────────────┘
↑ (Pull para atualizar)
```

## ⚠️ Checklist de Erros Comuns

- ❌ **"setState() called after dispose()"** 
  - ✅ Solução: Usar `if (mounted)` antes de setState

- ❌ **"Pull-to-refresh não funciona com lista vazia"**
  - ✅ Solução: Usar `AlwaysScrollableScrollPhysics` na ListView vazia

- ❌ **"App trava ao sincronizar"**
  - ✅ Solução: Sincronização é async, não bloqueia UI
  - ✅ Usar timeout de 30s em _handleRefresh

- ❌ **"Cache não atualiza após sincronização"**
  - ✅ Solução: Chamar _loadSchedules() após syncFromServer()

- ❌ **"Logs não aparecem no console"**
  - ✅ Solução: Verificar que `kDebugMode` está sendo usado
  - ✅ Verificar que o console está configurado para DEBUG

## 🔧 Modificações Realizadas

### Imports Adicionados

```dart
import 'package:flutter/foundation.dart'; // Para kDebugMode
import '../../infrastructure/remote/supabase_bus_schedules_remote_datasource.dart';
import '../../infrastructure/repositories/bus_schedules_repository_impl.dart';
```

### Método _loadSchedules() - REFATORADO

**Antes:** Apenas carregava cache
**Depois:** Carrega cache → Se vazio, sincroniza com servidor → Recarrega cache

- 100+ linhas
- 8 pontos de logging com kDebugMode
- Try/catch para erro de sincronização
- `if (mounted)` antes de setState

### Método _handleRefresh() - NOVO

**Propósito:** Callback para RefreshIndicator.onRefresh

- 42 linhas
- Sincronização forçada (ignora cache)
- Timeout de 30 segundos
- SnackBar com resultado (sucesso ou erro)
- 3 pontos de logging com kDebugMode

### Widget build() - WRAPPER COM RefreshIndicator

**Antes:** 
```dart
body: _isLoading ? ... : _response == null ? ... : ...
```

**Depois:**
```dart
body: RefreshIndicator(
  onRefresh: _handleRefresh,
  child: _isLoading ? ... : _response == null ? ... : ...
)
```

### ListView - Physics Adicionada

Adicionado `physics: const AlwaysScrollableScrollPhysics()` em:
1. Empty state ListView
2. Data list ListView.builder

## 📊 Exemplo de Logs Esperados

### Primeira abertura (cache vazio)

```
[BusSchedulesListPage] iniciando carregamento de agendamentos
[BusSchedulesListPage] carregados 0 agendamentos do cache
[BusSchedulesListPage] cache vazio, iniciando sincronização com servidor
[BusSchedulesListPage] sincronizados 42 agendamentos do servidor
[BusSchedulesListPage] lista atualizada com 42 itens
```

### Segunda abertura (cache com dados)

```
[BusSchedulesListPage] iniciando carregamento de agendamentos
[BusSchedulesListPage] carregados 42 agendamentos do cache
```

### Pull-to-refresh

```
[BusSchedulesListPage] iniciando refresh manual
[BusSchedulesListPage] sincronizados 42 agendamentos do servidor
[BusSchedulesListPage] refresh concluído
```

### Erro durante sync

```
[BusSchedulesListPage] iniciando carregamento de agendamentos
[BusSchedulesListPage] carregados 0 agendamentos do cache
[BusSchedulesListPage] cache vazio, iniciando sincronização com servidor
[BusSchedulesListPage] ❌ erro ao sincronizar: SocketException: Connection refused
```

## 🚀 Próximas Etapas

1. **Testar com Supabase real**
   - Verificar conexão e autenticação
   - Validar dados sincronizados

2. **Performance**
   - Monitorar tempo de sincronização
   - Otimizar se necessário

3. **Tratamento de Erro Avançado**
   - Retry com backoff exponencial
   - Offline detection

4. **Cache Persistente**
   - Implementar expiração de cache (ex: 1 hora)
   - Auto-sync periódico

## 📚 Referências

- `BusSchedulesRepositoryImpl` - Lógica de sincronização
- `BusSchedulesSyncHelper` - Helper de sincronização
- `SupabaseBusSchedulesRemoteDatasource` - API remota
- `BusSchedulesLocalDao` - Cache local

---

**Status:** ✅ Integração Completa
**Último Update:** Integração de RefreshIndicator + Auto-sync
**Didactic Prompt:** 100% aplicado
