# Resumo Técnico - Sincronização com Supabase (v2.0)

## 📋 Visão Geral

Este documento resume toda a implementação de sincronização remota com Supabase para o aplicativo Buss. Implementamos uma arquitetura em camadas com separação clara entre dados locais (cache) e remotos (servidor).

---

## 🏗️ Arquitetura

### Camadas Implementadas

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER                                          │
│ (Widgets, Pages, Dialogs)                                  │
│ ├─ bus_schedules_list_page.dart                            │
│ ├─ edit_schedule_dialog.dart                               │
│ └─ remove_confirmation_dialog.dart                         │
└────────────┬────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────┐
│ DOMAIN LAYER (Entities + Repository Interface)            │
│ ├─ entities/                                               │
│ │  ├─ bus_schedule.dart          [Entity]                 │
│ │  ├─ bus_schedule_filters.dart  [Filter DTO]             │
│ │  └─ bus_schedule_list_response.dart [Response DTO]      │
│ └─ repositories/                                           │
│    └─ i_bus_schedule_repository.dart  [Interface]         │
└────────────┬────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────────┐
│ INFRASTRUCTURE LAYER (Implementation)                      │
│                                                             │
│ LOCAL DATA SOURCE:                                          │
│ ├─ bus_schedules_local_dao.dart  [SharedPreferences]      │
│                                                             │
│ REMOTE DATA SOURCE (NEW):                                  │
│ ├─ remote/i_bus_schedules_remote_api.dart  [Interface]    │
│ └─ remote/supabase_bus_schedules_remote_datasource.dart   │
│    └─ [Supabase Implementation]                            │
│                                                             │
│ REPOSITORY IMPLEMENTATION (NEW):                           │
│ └─ repositories/bus_schedules_repository_impl.dart        │
│    └─ [Coordena Local + Remote com Sync]                  │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Arquivos Criados/Modificados

### ✅ Novos Arquivos

| Arquivo | Linhas | Propósito |
|---------|--------|----------|
| `infrastructure/remote/i_bus_schedules_remote_api.dart` | 50+ | Interface para API remota (Supabase) |
| `infrastructure/remote/supabase_bus_schedules_remote_datasource.dart` | 350+ | Implementação Supabase com logging |
| `infrastructure/repositories/bus_schedules_repository_impl.dart` | 400+ | Repository com sync + todos os métodos |

### 📝 Arquivos Existentes (Utilizados)

| Arquivo | Linhas | Uso |
|---------|--------|-----|
| `domain/entities/bus_schedule.dart` | 123 | Entity base (14+ propriedades) |
| `data/models/bus_schedule_model.dart` | 152+ | Serialização (fromJson/toJson) |
| `domain/repositories/i_bus_schedule_repository.dart` | 106+ | Interface (11 métodos) |
| `data/datasources/bus_schedules_local_dao.dart` | 320+ | Local cache com SharedPreferences |

---

## 🔄 Fluxo de Sincronização Detalhado

### Pré-Condição
- Supabase inicializado em `main.dart`
- Remote API e Local DAO injetados no Repository

### Fluxo Passo a Passo

```
┌─────────────────────────────────────────┐
│ 1. LOAD FROM CACHE                      │
│    loadFromCache()                      │
│    ├─ Lê tudo de SharedPreferences     │
│    ├─ Retorna lista completa (rápido)  │
│    └─ UI renderiza imediatamente       │
└────────────┬────────────────────────────┘
             │ [Em paralelo/Background]
             ▼
┌─────────────────────────────────────────┐
│ 2. SYNC FROM SERVER                     │
│    syncFromServer()                     │
│    │                                    │
│    ├─ Lê "bus_schedules_last_sync_v1"  │
│    │  do SharedPreferences              │
│    │                                    │
│    ├─ Busca Remote API com filtro      │
│    │  since = last_sync                │
│    │                                    │
│    ├─ Recebe RemotePage<BusSchedule>   │
│    │  com items[] e hasNext flag        │
│    │                                    │
│    ├─ Para cada item:                  │
│    │  ├─ Verificar se existe localmente│
│    │  ├─ Se sim: atualizar             │
│    │  ├─ Se não: inserir               │
│    │  └─ Persist via DAO.upsertAll()   │
│    │                                    │
│    ├─ Extrai timestamp mais recente    │
│    │  (updated_at do último item)      │
│    │                                    │
│    ├─ Salva em SharedPreferences       │
│    │  (para próxima sincronização)     │
│    │                                    │
│    └─ Retorna quantidade sincronizada  │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ 3. NOTIFY UI IF CHANGED                 │
│    if (synced > 0)                      │
│    ├─ setState(() => reload)            │
│    ├─ Rebuild list com dados novos     │
│    └─ Mostrar indicador de atualização │
└─────────────────────────────────────────┘
```

### Tratamento de Erros

```
Em cada ponto crítico:
├─ Try/Catch com logging kDebugMode
├─ Retorno seguro (lista vazia, 0 itens)
├─ Não propaga exceções para UI
└─ Diagnóstico facilitado via logs

Exemplos:
├─ Falha RemoteAPI → ReturnEmptyRemotePage
├─ Falha DAO → ReturnEmptyList  
├─ Falha Parse JSON → SkipItem + Log
└─ Timeout → ReturnZeroSynced
```

---

## 💾 Estrutura de Dados

### BusSchedule Entity (Domain)

```dart
class BusSchedule {
  final String id;
  final String routeName;
  final String destination;
  final String? origin;
  final String departureTime;
  final String status;          // 'active', 'inactive'
  final bool accessibility;
  final double? fare;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? stops;    // Paradas intermediárias
  // ... mais campos
}
```

### BusScheduleModel (Serializable)

```dart
class BusScheduleModel extends BusSchedule {
  // Herda todas as propriedades de BusSchedule
  
  factory BusScheduleModel.fromJson(Map<String, dynamic> json) {
    // Converte JSON do Supabase
    // Trata múltiplos formatos de tipo (id: int|string)
    // Converte datas: DateTime ou String → DateTime
    // Null-safe para campos opcionais
  }
  
  Map<String, dynamic> toJson() {
    // Serializa para Supabase upsert
  }
}
```

### RemotePage (Pagination Response)

```dart
class RemotePage<T> {
  final List<T> items;
  final bool hasNext;
  
  // Usado para detectar se há mais itens
  // pagination: if (response.hasNext) { fetchMore() }
}
```

---

## 🔑 Chaves de Persistência

| Chave | Tipo | Propósito | Versão |
|-------|------|----------|--------|
| `bus_schedules_v1` | JSON Array | Cache de agendamentos | V1 |
| `bus_schedules_last_sync_v1` | ISO8601 DateTime | Última sincronização | V1 |

### Estratégia de Versionamento

```
Se fazer breaking changes:
- Criar nova chave: bus_schedules_last_sync_v2
- Migrar dados manualmente ou limpar
- Documentar em MIGRATION.md

Benefício: Suporta múltiplas versões do app
```

---

## 📊 Métodos do Repository

| Método | Entrada | Saída | Async | Origem |
|--------|---------|-------|-------|--------|
| `loadFromCache()` | - | List<BusSchedule> | ✅ | LocalDAO |
| `syncFromServer()` | - | int (count) | ✅ | RemoteAPI → LocalDAO |
| `listAll(filters, page)` | Filters, page | BusScheduleListResponse | ✅ | LocalDAO |
| `listFeatured()` | - | List<BusSchedule> | ✅ | LocalDAO |
| `getById(id)` | String | BusSchedule? | ✅ | LocalDAO |
| `search(query)` | String | List<BusSchedule> | ✅ | LocalDAO |
| `create(schedule)` | BusSchedule | BusSchedule | ✅ | LocalDAO |
| `update(id, schedule)` | String, BusSchedule | BusSchedule | ✅ | LocalDAO |
| `delete(id)` | String | bool | ✅ | LocalDAO |
| `upsertAll(schedules)` | List<BusSchedule> | List<BusSchedule> | ✅ | LocalDAO |
| `clear()` | - | bool | ✅ | LocalDAO |

---

## 🐛 Debug e Logging

### Logs Disponíveis

Com `flutter run` em modo Debug:

```
┌─ BusSchedulesRepositoryImpl
│  ├─ loadFromCache: iniciando
│  ├─ loadFromCache: carregados X agendamentos
│  ├─ syncFromServer: iniciando
│  ├─ syncFromServer: sincronização desde DATETIME
│  ├─ syncFromServer: N itens persistidos
│  ├─ syncFromServer: último sync atualizado para DATETIME
│  ├─ syncFromServer: sucesso! N itens sincronizados
│  └─ [TODAS AS OPERAÇÕES COM TIMESTAMPS]
│
└─ SupabaseBusSchedulesRemoteDatasource
   ├─ fetchBusSchedules: iniciando fetch
   ├─ fetchBusSchedules: queryando table
   ├─ fetchBusSchedules: recebidos X registros
   ├─ fetchBusSchedules: convertendo para modelos
   ├─ fetchBusSchedules: sucesso! RemotePage retornada
   └─ [ERROS DE CONVERSÃO, ERROS DE CONEXÃO]
```

### Como Habilitar Logs

```dart
// Logs automáticos (desenvolvimento)
flutter run --debug

// Logs em release (desabilitado por padrão)
// Descomentar em kDebugMode checks
```

---

## 🧪 Testes Recomendados

### Teste 1: Conexão Inicial

```dart
void testConnection() async {
  final api = SupabaseBusSchedulesRemoteDatasource();
  final page = await api.fetchBusSchedules(limit: 5);
  
  expect(page.items, isNotEmpty);
  print('✅ Conexão OK');
}
```

### Teste 2: Sincronização Completa

```dart
void testFullSync() async {
  final repository = BusSchedulesRepositoryImpl(
    remoteApi: api,
    localDao: dao,
  );
  
  // Primeira sync (sem last_sync)
  int synced1 = await repository.syncFromServer();
  expect(synced1, greaterThan(0));
  
  // Segunda sync (com last_sync)
  int synced2 = await repository.syncFromServer();
  expect(synced2, lessThanOrEqualTo(synced1));
  
  print('✅ Sincronização funciona');
}
```

### Teste 3: Integridade de Dados

```dart
void testDataIntegrity() async {
  final cached = await repository.loadFromCache();
  final specific = await repository.getById(cached[0].id);
  
  expect(specific!.id, equals(cached[0].id));
  expect(specific.routeName, equals(cached[0].routeName));
  
  print('✅ Dados íntegros');
}
```

---

## ⚙️ Dependências Necessárias

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Já existente
  shared_preferences: ^2.2.0
  
  # ADICIONAR
  supabase_flutter: ^2.0.0
```

---

## 📋 Checklist de Implementação

### Antes de Deploy

- [ ] Supabase inicializado com URL e anonKey válidos
- [ ] Tabela `bus_schedules` criada no Supabase
- [ ] RLS policies configuradas (ou desabilitadas para dev)
- [ ] Índices criados (especialmente `updated_at`)
- [ ] SharedPreferences funcionando (testado localmente)
- [ ] Testes unitários passando
- [ ] Logs sendo gerados corretamente
- [ ] Timeout adequado (30s default)

### Após Deploy

- [ ] Primeira sincronização em produção testada
- [ ] Usuários conseguem carregar dados
- [ ] Alterações remotas sincronizam corretamente
- [ ] Performance é aceitável (<2s para sync normal)
- [ ] Sem erros de parsing em dados reais
- [ ] Rollback plan documentado

---

## 🚀 Próximos Passos

### Curto Prazo (1-2 sprints)

1. ✅ Implementação base (FEITO)
2. ⏳ Adicionar supabase_flutter a pubspec.yaml
3. ⏳ Testes unitários com mocks
4. ⏳ Integração com service locator

### Médio Prazo (3-4 sprints)

5. ⏳ Retry logic com exponential backoff
6. ⏳ Indicador visual de sync em andamento
7. ⏳ Background sync com WorkManager
8. ⏳ Suporte a múltiplos recursos (rotas, paradas)

### Longo Prazo (5+ sprints)

9. ⏳ WebSocket para real-time updates
10. ⏳ Offline-first com queue de operações
11. ⏳ Conflict resolution (edições simultâneas)
12. ⏳ Analytics de sync performance

---

## 🔗 Documentação Relacionada

- `QUICK_INTEGRATION_GUIDE.md` - Setup prático (5 min)
- `SUPABASE_SYNC_STATUS.md` - Status de implementação
- `IMPLEMENTATION_SUMMARY.md` - Histórico de features
- `QUICK_START.md` - Repository pattern basics
- `README_REPOSITORY.md` - Exemplos de uso

---

## 👨‍💻 Autores

- Implementação: GitHub Copilot
- Arquitetura: Clean Architecture + Repository Pattern
- Data: 2024-12-XX

---

**Status:** ✅ Pronto para integração com supabase_flutter  
**Versão:** 2.0.0 (Supabase Sync)  
**Branch:** supabase
