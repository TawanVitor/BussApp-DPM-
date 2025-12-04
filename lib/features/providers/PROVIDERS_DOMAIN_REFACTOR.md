# ✅ Providers Feature - UI Domain Refactor Completo

## 📋 Visão Geral

Este documento descreve a implementação completa do feature **Providers** aplicando o padrão didático de **Domain Refactor com Mapper**.

### Objetivo Principal

Desacoplar a camada de Apresentação (UI) da camada de Persistência usando:
- ✅ **Domain Entities** na UI (não DTOs)
- ✅ **Mapper** para conversão DTO ↔ Domain
- ✅ **Repository** como orquestrador
- ✅ **Supabase Sync** com auto-sync e pull-to-refresh
- ✅ **Didactic Comments** em todo o código
- ✅ **kDebugMode Logging** em pontos críticos

## 🏗️ Arquitetura

### Estrutura de Pastas

```
lib/features/providers/
├── domain/
│   ├── entities/
│   │   └── provider.dart          ← Entidade de domínio
│   └── repositories/
│       └── provider_repository.dart  ← Interface do repository
├── data/
│   ├── models/
│   │   └── provider_model.dart    ← DTO (Data Transfer Object)
│   ├── datasources/
│   │   └── providers_local_dao.dart  ← Cache local (SharedPrefs)
│   └── mappers/
│       └── provider_mapper.dart   ← Conversor Domain ↔ DTO
├── infrastructure/
│   ├── remote/
│   │   └── supabase_providers_remote_datasource.dart  ← API Supabase
│   └── repositories/
│       └── providers_repository_impl.dart  ← Repository com sync
└── presentation/
    ├── pages/
    │   └── providers_page.dart    ← Página principal (com RefreshIndicator)
    ├── widgets/
    │   ├── provider_list_view.dart  ← ListView de providers
    │   └── provider_list_item.dart  ← Card individual de provider
    └── dialogs/
        ├── provider_form_dialog.dart     ← Dialog create/edit
        └── provider_details_dialog.dart  ← Dialog view details
```

### Fluxo de Dados (Didático)

```
LEITURA (Supabase → Cache → UI):
┌────────────────┐
│ Supabase JSON  │ (table: providers)
└────────┬───────┘
         │ RemoteDatasource.fetchAll()
         ↓
┌────────────────┐
│  ProviderModel │ DTO (dados brutos)
└────────┬───────┘
         │ ProviderMapper.toEntity()
         ↓
┌────────────────┐
│   Provider     │ Domain Entity
│   (domínio)    │
└────────┬───────┘
         │ Repository.getAll()
         ↓
┌────────────────┐
│   ProvidersPage│ UI Layer
│   (recebe      │ (sempre Provider!)
│   List<Provider>)
└────────────────┘

ESCRITA (UI → Cache → Supabase):
┌────────────────┐
│   ProvidersPage│ UI cria/edita
│  (cria Provider)
└────────┬───────┘
         │ Repository.create/update()
         ↓
┌────────────────┐
│  ProviderModel │ Mapper.toDto()
│ (DTO format)   │
└────────┬───────┘
         │ DAO.upsert()
         ↓
┌────────────────┐
│ SharedPrefs    │ Cache local
└────────────────┘
```

## 🔄 Componentes Principais

### 1. Domain Entity (Provider)

**Arquivo:** `provider.dart`

```dart
class Provider {
  final String id;
  final String name;
  final String? imageUri;
  final double distanceKm;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  // copyWith, ==, hashCode, toString
}
```

**Responsabilidade:** Representar um provider no domínio de negócio (sem persistência)

### 2. DTO (ProviderModel)

**Arquivo:** `provider_model.dart`

```dart
class ProviderModel {
  final String id;
  final String name;
  final String? imageUri;
  final double distanceKm;
  final String createdAt;    // ← String (ISO 8601)
  final String updatedAt;    // ← String (ISO 8601)
  final bool isActive;
  
  // fromJson, toJson, copyWith
}
```

**Responsabilidade:** Formato de armazenamento na persistência

**⚠️ Diferenças importantes:**

| Provider (Domain) | ProviderModel (DTO) |
|------------------|-------------------|
| `DateTime createdAt` | `String createdAt` |
| `DateTime updatedAt` | `String updatedAt` |
| Usado em lógica | Usado em persistência |
| Sem métodos de persister | Com fromJson/toJson |

### 3. Mapper (ProviderMapper)

**Arquivo:** `provider_mapper.dart`

```dart
abstract class ProviderMapper {
  // DTO → Domain
  static Provider toEntity(ProviderModel model) {
    final createdAtDateTime = DateTime.tryParse(model.createdAt) ?? DateTime.now();
    return Provider(
      id: model.id,
      name: model.name,
      imageUri: model.imageUri,
      distanceKm: model.distanceKm,
      createdAt: createdAtDateTime,
      updatedAt: ...,
      isActive: model.isActive,
    );
  }

  // Domain → DTO
  static ProviderModel toDto(Provider entity) {
    return ProviderModel(
      id: entity.id,
      name: entity.name,
      imageUri: entity.imageUri,
      distanceKm: entity.distanceKm,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
      isActive: entity.isActive,
    );
  }

  // Listas
  static List<Provider> toDomainList(List<ProviderModel> models) => ...
  static List<ProviderModel> toDtoList(List<Provider> entities) => ...
}
```

**Responsabilidade:** Centralizar todas as conversões

### 4. DAO (ProvidersLocalDaoSharedPrefs)

**Arquivo:** `providers_local_dao.dart`

```dart
// Interface
abstract class IProvidersLocalDao {
  Future<List<ProviderModel>> listAll();
  Future<ProviderModel?> getById(String id);
  Future<void> insert(ProviderModel model);
  Future<void> update(ProviderModel model);
  Future<void> upsert(ProviderModel model);
  Future<void> upsertAll(List<ProviderModel> models);
  Future<bool> delete(String id);
  Future<void> clear();
}

// Implementação com SharedPreferences
class ProvidersLocalDaoSharedPrefs implements IProvidersLocalDao {
  // ... implementação
}
```

**Responsabilidade:** Persistência local (trabalha com DTOs)

### 5. Remote Datasource (SupabaseProvidersRemoteDatasource)

**Arquivo:** `supabase_providers_remote_datasource.dart`

```dart
abstract class IProvidersRemoteApi {
  Future<List<ProviderModel>> fetchAll();
  Future<ProviderModel?> fetchById(String id);
  Future<ProviderModel> create(ProviderModel model);
  Future<ProviderModel> update(ProviderModel model);
  Future<bool> delete(String id);
}

class SupabaseProvidersRemoteDatasource implements IProvidersRemoteApi {
  // TODO: Implementar com supabase_flutter
}
```

**Responsabilidade:** API remota (trabalha com DTOs)

### 6. Repository (ProvidersRepositoryImpl)

**Arquivo:** `providers_repository_impl.dart`

```dart
class ProvidersRepositoryImpl implements IProvidersRepository {
  final IProvidersRemoteApi _remoteApi;
  final IProvidersLocalDao _localDao;

  // Retorna sempre Provider (domain entity)
  Future<List<Provider>> getAll() async {
    final dtoList = await _localDao.listAll();
    return dtoList.map(ProviderMapper.toEntity).toList();
  }

  // Sincronização com Supabase
  Future<int> syncFromServer() async {
    final remoteDtoList = await _remoteApi.fetchAll();
    await _localDao.upsertAll(remoteDtoList);
    return remoteDtoList.length;
  }
}
```

**Responsabilidade:** Orquestrar dados + fazer conversões

### 7. UI - ProvidersPage

**Arquivo:** `providers_page.dart`

```dart
class _ProvidersPageState extends State<ProvidersPage> {
  List<Provider> _providers = [];  // ← Domain entities (nunca DTOs!)
  bool _isLoading = false;
  bool _isSyncing = false;
  late ProvidersRepositoryImpl _repository;

  // Auto-sync na primeira carga
  Future<void> _loadProviders() async {
    var providers = await _repository.getAll();
    if (providers.isEmpty) {
      final synced = await _repository.syncFromServer();
      providers = await _repository.getAll();
    }
    setState(() => _providers = providers);
  }

  // Pull-to-refresh manual
  Future<void> _handleRefresh() async {
    final synced = await _repository.syncFromServer();
    final providers = await _repository.getAll();
    setState(() => _providers = providers);
  }
}
```

**Responsabilidade:** Gerenciar UI e chamar Repository

## 📱 UI Components

### ProvidersListView

```dart
ProvidersListView(
  providers: providers,  // ← List<Provider> (não ProviderModel!)
  onEdit: (provider) => _handleEdit(provider),
  onDelete: (providerId) => _handleDelete(providerId),
  onTap: (provider) => _showDetails(provider),
)
```

### ProviderListItem

Card que exibe um provider:
- Imagem (placeholder se não houver)
- Nome
- Distância
- Status (ativo/inativo)
- Timestamps
- Botões (editar, deletar)

### ProviderFormDialog

```dart
// Criar
final newProvider = await showDialog<Provider>(
  context: context,
  builder: (context) => const ProviderFormDialog(),
);

// Editar
final updated = await showDialog<Provider>(
  context: context,
  builder: (context) => ProviderFormDialog(initialValue: provider),
);
```

**Valida:** Nome, URL, distância

### ProviderDetailsDialog

Exibe detalhes completos:
- Imagem grande
- Nome + status
- ID, distância, datas
- Botões (fechar, editar, deletar)

## 🔄 Fluxo de Sincronização

### Primeira Carga (Auto-Sync)

```
initState()
  ↓
_initializeRepository()
  ├─ Criar DAO
  ├─ Criar Repository
  └─ _loadProviders()
     ├─ Carregar cache
     ├─ Cache vazio? → _syncFromServer()
     │   ├─ RemoteAPI.fetchAll() → List<ProviderModel>
     │   ├─ DAO.upsertAll()
     │   └─ Repository.getAll() → List<Provider>
     └─ setState()
```

**Logs esperados:**

```
[ProvidersPage] iniciando carregamento de providers...
[ProvidersPage] carregados 0 providers do cache
[ProvidersPage] cache vazio, iniciando auto-sync...
[ProvidersRepository] Iniciando sync com Supabase...
[ProvidersRepository] Buscados 42 providers remotos
[ProvidersRepository] Aplicados 42 providers ao cache
[ProvidersPage] sincronizados 42 providers!
[ProvidersPage] UI atualizada com 42 providers
```

### Pull-to-Refresh (Manual)

```
User pulls ↑
  ↓
RefreshIndicator.onRefresh → _handleRefresh()
  ├─ _isSyncing = true
  ├─ LinearProgressIndicator (topo)
  ├─ Repository.syncFromServer() (com timeout 30s)
  ├─ Repository.getAll()
  ├─ setState()
  ├─ SnackBar("Sincronizados X providers")
  └─ _isSyncing = false
```

**Logs esperados:**

```
[ProvidersPage] iniciando refresh manual...
[ProvidersRepository] Iniciando sync com Supabase...
[ProvidersRepository] Buscados 42 providers remotos
[ProvidersRepository] Aplicados 42 providers ao cache
[ProvidersPage] refresh: sincronizados 42 providers
```

## 🎓 Padrões Didáticos Aplicados

### 1. **Domain-Driven Design**

✅ Entidades de domínio (Provider) separadas de DTOs (ProviderModel)
✅ Repository como fachada
✅ Mapper concentrando conversões

### 2. **Dependency Injection**

```dart
ProvidersRepositoryImpl(
  remoteApi: SupabaseProvidersRemoteDatasource(),
  localDao: ProvidersLocalDaoSharedPrefs(),
)
```

✅ Fácil de testar (mock dependências)
✅ Desacoplado

### 3. **RefreshIndicator + AlwaysScrollableScrollPhysics**

```dart
RefreshIndicator(
  onRefresh: _handleRefresh,
  child: ListView(
    physics: AlwaysScrollableScrollPhysics(),
    ...
  ),
)
```

✅ Pull-to-refresh funciona mesmo com lista vazia
✅ Feedback visual consistente

### 4. **Auto-Sync + Manual Sync**

✅ Auto-sync na primeira abertura (cache vazio)
✅ Manual sync via pull-to-refresh
✅ Timeout de 30 segundos (proteção contra travamentos)

### 5. **Logging Didático com kDebugMode**

```dart
if (kDebugMode) {
  print('[ProvidersRepository] Iniciando sync com Supabase...');
}
```

✅ Logs em pontos críticos
✅ Facilitam debug
✅ Desaparecem em produção

### 6. **Mounted Safety Check**

```dart
if (mounted) {
  setState(() => _providers = providers);
}
```

✅ Evita "setState() called after dispose()"
✅ Padrão recomendado do Flutter

## 📊 Exemplo de Dados

### Provider (Domain Entity)

```dart
Provider(
  id: 'prov_1704849000000_123',
  name: 'João Silva',
  imageUri: 'https://example.com/profile.jpg',
  distanceKm: 5.2,
  createdAt: DateTime(2025, 1, 10, 10, 30, 0),
  updatedAt: DateTime(2025, 1, 10, 15, 45, 30),
  isActive: true,
)
```

### ProviderModel (DTO/JSON)

```json
{
  "id": "prov_1704849000000_123",
  "name": "João Silva",
  "image_uri": "https://example.com/profile.jpg",
  "distance_km": 5.2,
  "created_at": "2025-01-10T10:30:00.000Z",
  "updated_at": "2025-01-10T15:45:30.000Z",
  "is_active": true
}
```

## ⚠️ Checklist de Erros Comuns

### ❌ Usar DTO diretamente na UI

```dart
// ❌ ERRADO
final providers = await dao.listAll();  // Retorna List<ProviderModel>
setState(() => _providers = providers);  // UI com DTOs!
```

```dart
// ✅ CORRETO
final dtos = await dao.listAll();
final providers = dtos.map(ProviderMapper.toEntity).toList();
setState(() => _providers = providers);
```

### ❌ Esquecer de converter DateTime

```dart
// ❌ ERRADO
final provider = Provider(
  createdAt: model.createdAt,  // String! Erro de tipo
);
```

```dart
// ✅ CORRETO
final createdAt = DateTime.tryParse(model.createdAt) ?? DateTime.now();
final provider = Provider(
  createdAt: createdAt,
);
```

### ❌ Não permitir pull-to-refresh em lista vazia

```dart
// ❌ ERRADO
body: _providers.isEmpty
    ? Center(child: Text('Vazio'))  // Não scrollável!
    : ListView(...)
```

```dart
// ✅ CORRETO
body: RefreshIndicator(
  onRefresh: _handleRefresh,
  child: _providers.isEmpty
      ? ListView(
          physics: AlwaysScrollableScrollPhysics(),
          children: [Center(child: Text('Vazio'))],
        )
      : ListView(...)
)
```

### ❌ setState() after dispose()

```dart
// ❌ ERRADO
await repository.syncFromServer();
setState(() => _providers = ...);  // Pode quebrar se page fechar!
```

```dart
// ✅ CORRETO
await repository.syncFromServer();
if (mounted) {
  setState(() => _providers = ...);
}
```

### ❌ Sync sem timeout

```dart
// ❌ ERRADO
final synced = await repository.syncFromServer();  // Pode pendurar infinitamente
```

```dart
// ✅ CORRETO
final synced = await repository.syncFromServer().timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw Exception('Sync timeout'),
);
```

## 🚀 Próximas Etapas

1. **Implementar Supabase Real**
   - Adicionar `supabase_flutter` ao pubspec.yaml
   - Implementar `SupabaseProvidersRemoteDatasource` com cliente real
   - Configurar tabela e RLS no Supabase

2. **Testes Unitários**
   - DTO conversions (ProviderMapper)
   - Repository métodos
   - Mock RemoteAPI e DAO

3. **Testes de Widget**
   - ProvidersPage com mock repository
   - List view rendering
   - Dialog interactions

4. **Features Avançadas**
   - Filtros (por nome, ativo/inativo)
   - Busca em tempo real
   - Offline detection
   - Cache expiration (1 hora)
   - Retry com backoff exponencial

## 📚 Arquivos de Referência

```
✅ Criados:
- provider.dart (Domain Entity)
- provider_repository.dart (Interface)
- provider_model.dart (DTO)
- provider_mapper.dart (Conversão)
- providers_local_dao.dart (Cache)
- supabase_providers_remote_datasource.dart (API)
- providers_repository_impl.dart (Repository)
- providers_page.dart (UI)
- provider_list_view.dart (Widget)
- provider_list_item.dart (Card)
- provider_form_dialog.dart (Create/Edit)
- provider_details_dialog.dart (Details)

📝 Documentação:
- PROVIDERS_DOMAIN_REFACTOR.md (este arquivo)
```

## 🎓 Aprendizados Principais

1. **Separação de Responsabilidades:** UI usa Domain, não DTO
2. **Mapper Pattern:** Todas as conversões em um lugar
3. **Dependency Injection:** Facilita testing e flexibilidade
4. **Auto-sync:** Melhor UX (não pede ao usuário na primeira vez)
5. **Pull-to-refresh:** Controle do usuário sobre atualização
6. **Logging Didático:** Facilita debug e aprendizado
7. **Mounted Check:** Padrão essencial do Flutter

---

**Status:** ✅ Implementação Completa
**Versão:** 1.0.0
**Data:** 2025-01-10
