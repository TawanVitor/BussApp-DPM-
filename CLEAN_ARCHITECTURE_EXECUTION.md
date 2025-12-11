# 🚀 EXECUÇÃO: Clean Architecture Reorganização

## ✅ STATUS ATUAL

```
✅ domain/repositories/i_bus_schedule_repository.dart - EXISTE
✅ data/repositories/bus_schedule_repository_impl.dart - EXISTE  
✅ data/datasources/bus_schedules_local_dao.dart - EXISTE
✅ data/models/bus_schedule_model.dart - EXISTE
✅ infrastructure/remote/supabase_bus_schedules_remote_datasource.dart - EXISTE

❌ FALTAM INTERFACES DE DATASOURCES
❌ SEM MAPPERS
❌ routes, settings INCOMPLETOS
```

---

## 📋 AÇÕES NECESSÁRIAS (ORDEM)

### 1️⃣ **bus_schedules** - Criar Interfaces de Datasources

```dart
// ✨ NEW: data/datasources/i_bus_schedules_local_datasource.dart
abstract class IBusSchedulesLocalDatasource {
  Future<BusScheduleListResponse> listAll(...);
  Future<BusSchedule?> getById(String id);
  Future<BusSchedule> create(BusSchedule entity);
  Future<BusSchedule> update(BusSchedule entity);
  Future<bool> delete(String id);
}

// ✨ NEW: data/datasources/i_bus_schedules_remote_datasource.dart
abstract class IBusSchedulesRemoteDatasource {
  Future<List<BusScheduleModel>> fetchAll();
  Future<BusScheduleModel?> fetchById(String id);
  Future<BusScheduleModel> create(BusScheduleModel model);
  Future<BusScheduleModel> update(BusScheduleModel model);
  Future<bool> delete(String id);
}
```

### 2️⃣ **Criar Mapper para bus_schedules**

```dart
// ✨ NEW: data/mappers/bus_schedule_mapper.dart
class BusScheduleMapper {
  static BusScheduleModel toModel(BusSchedule entity) { ... }
  static BusSchedule toEntity(BusScheduleModel model) { ... }
}
```

### 3️⃣ **Atualizar Repository Implementation**

```dart
// ATUALIZAR: data/repositories/bus_schedule_repository_impl.dart
class BusScheduleRepositoryImpl implements IBusScheduleRepository {
  final IBusSchedulesLocalDatasource _local;
  final IBusSchedulesRemoteDatasource _remote;

  BusScheduleRepositoryImpl({
    required IBusSchedulesLocalDatasource local,
    required IBusSchedulesRemoteDatasource remote,
  }) : _local = local, _remote = remote;
}
```

### 4️⃣ **Mesmo para providers**

```dart
// ✨ Criar interfaces em data/datasources/
// ✨ Consolidar com nomes consistentes
```

### 5️⃣ **Implementar routes completo**

```dart
// ✨ Criar toda a estrutura Domain/Data/Presentation
```

### 6️⃣ **Implementar settings completo**

```dart
// ✨ Criar toda a estrutura Domain/Data/Presentation
```

---

## 🎯 COMEÇAREI COM:

1. ✅ Criar interfaces de datasources para bus_schedules
2. ✅ Criar mapper para bus_schedules
3. ✅ Atualizar repository para usar interfaces
4. ✅ Fazer commit
5. ✅ Fazer o mesmo para providers
6. ✅ Implementar routes
7. ✅ Implementar settings
8. ✅ Atualizar imports em todo projeto
9. ✅ Documentar estrutura final

**Quer que continue?** ✅
