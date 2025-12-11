# 🏗️ Clean Architecture Refactoring Plan

## 📊 Análise Estrutura Atual vs Clean Architecture

### ❌ PROBLEMAS ENCONTRADOS

1. **bus_schedules:**
   - ❌ `data/repositories/` (deveria estar em `infrastructure/repositories/`)
   - ❌ `infrastructure/repositories/` duplicado
   - ⚠️ Sem interface de repository em `domain/`
   - ❌ Sem datasource interface

2. **providers:**
   - ✅ Bem estruturado (é o modelo)
   - ⚠️ Faltam interfaces de repository e datasource

3. **routes:**
   - ❌ Sem Data layer (datasources, mappers, models)
   - ❌ Sem Infrastructure layer
   - ❌ Sem Repository pattern
   - ⚠️ Apenas Domain e Presentation

4. **settings:**
   - ❌ Sem Data layer
   - ❌ Sem Infrastructure layer
   - ⚠️ Apenas Domain e Presentation

5. **core:**
   - ✅ Bem estruturado

---

## ✅ CLEAN ARCHITECTURE - PADRÃO CORRETO

```
Feature (ex: providers)
│
├─ domain/
│  ├─ entities/
│  │  └─ provider.dart (Provider entity - puro, sem DB)
│  ├─ repositories/
│  │  └─ i_provider_repository.dart (Interface do Repository)
│  └─ usecases/ (Opcional - lógica complexa)
│
├─ data/
│  ├─ datasources/
│  │  ├─ provider_local_datasource.dart (Interface)
│  │  ├─ provider_local_datasource_impl.dart (SharedPreferences)
│  │  ├─ provider_remote_datasource.dart (Interface)
│  │  └─ provider_remote_datasource_impl.dart (Supabase)
│  ├─ models/
│  │  └─ provider_model.dart (DTO com fromJson/toJson)
│  ├─ mappers/
│  │  └─ provider_mapper.dart (Model ↔ Entity conversion)
│  └─ repositories/
│     └─ provider_repository_impl.dart (Implementa interface do domain)
│
├─ infrastructure/
│  └─ (Vazio ou Supabase client init se necessário)
│
└─ presentation/
   ├─ dialogs/
   ├─ pages/
   └─ widgets/
```

---

## 📋 PLANO DE REORGANIZAÇÃO

### 1️⃣ **bus_schedules** - Consolidação

**ATUAL:**
```
bus_schedules/
├─ data/
│  ├─ datasources/
│  ├─ models/
│  └─ repositories/ ❌ (MOVE para infrastructure)
├─ domain/
│  ├─ entities/
│  └─ repositories/
└─ infrastructure/
   ├─ remote/
   ├─ repositories/ ❌ (DUPLICADO)
   └─ repositories/ ❌ (ELIMINAR)
```

**NOVO:**
```
bus_schedules/
├─ domain/
│  ├─ entities/
│  └─ repositories/
│     └─ i_bus_schedule_repository.dart (Interface)
├─ data/
│  ├─ datasources/
│  │  ├─ bus_schedules_local_datasource.dart (Interface)
│  │  ├─ bus_schedules_local_dao.dart (Implementação)
│  │  ├─ i_bus_schedules_remote_datasource.dart (Interface)
│  │  └─ supabase_bus_schedules_remote_datasource.dart (Implementação)
│  ├─ models/
│  │  └─ bus_schedule_model.dart
│  ├─ mappers/
│  │  └─ bus_schedule_mapper.dart
│  └─ repositories/
│     └─ bus_schedule_repository_impl.dart (Une local + remote)
├─ presentation/
│  ├─ dialogs/
│  └─ pages/
└─ README.md
```

---

### 2️⃣ **providers** - Melhorias (Já está bom!)

**ATUAL:** ✅ Bem estruturado

**SUGESTÕES:**
- Adicionar interface `i_provider_repository.dart` em `domain/repositories/`
- Consolidar datasources em `data/datasources/` com interfaces
- Criar `provider_local_datasource.dart` interface

**NOVO:**
```
providers/
├─ domain/
│  ├─ entities/
│  │  └─ provider.dart
│  └─ repositories/
│     └─ i_provider_repository.dart ✨ (NEW)
├─ data/
│  ├─ datasources/
│  │  ├─ i_provider_local_datasource.dart ✨ (NEW)
│  │  ├─ provider_local_datasource_impl.dart ✨ (RENAME providers_local_dao.dart)
│  │  ├─ i_provider_remote_datasource.dart ✨ (NEW)
│  │  └─ supabase_provider_remote_datasource.dart (RENAME)
│  ├─ models/
│  │  └─ provider_model.dart
│  ├─ mappers/
│  │  └─ provider_mapper.dart
│  └─ repositories/
│     └─ provider_repository_impl.dart
└─ presentation/
   ├─ dialogs/
   ├─ pages/
   └─ widgets/
```

---

### 3️⃣ **routes** - Implementação Completa

**ATUAL:** ❌ Incompleto
```
routes/
├─ data/models/ ❌ (Mal localizado)
├─ domain/entities/
└─ presentation/pages/
```

**NOVO:**
```
routes/
├─ domain/
│  ├─ entities/
│  │  └─ bus_route.dart (Entidade pura)
│  └─ repositories/
│     └─ i_bus_route_repository.dart ✨ (NEW Interface)
├─ data/
│  ├─ datasources/
│  │  ├─ i_bus_route_local_datasource.dart ✨ (NEW)
│  │  ├─ bus_route_local_datasource_impl.dart ✨ (NEW)
│  │  ├─ i_bus_route_remote_datasource.dart ✨ (NEW)
│  │  └─ supabase_bus_route_remote_datasource.dart ✨ (NEW)
│  ├─ models/
│  │  └─ bus_route_model.dart (MOVE from data/models/)
│  ├─ mappers/
│  │  └─ bus_route_mapper.dart ✨ (NEW)
│  └─ repositories/
│     └─ bus_route_repository_impl.dart ✨ (NEW)
└─ presentation/
   ├─ pages/
   │  ├─ add_route_page.dart
   │  └─ route_list_page.dart
   └─ widgets/ (se houver)
```

---

### 4️⃣ **settings** - Implementação Completa

**ATUAL:** ❌ Incompleto
```
settings/
├─ data/models/
├─ domain/entities/
└─ presentation/pages/
```

**NOVO:**
```
settings/
├─ domain/
│  ├─ entities/
│  │  └─ user_settings.dart
│  └─ repositories/
│     └─ i_user_settings_repository.dart ✨ (NEW)
├─ data/
│  ├─ datasources/
│  │  ├─ i_user_settings_datasource.dart ✨ (NEW)
│  │  └─ user_settings_datasource_impl.dart ✨ (NEW)
│  ├─ models/
│  │  └─ user_settings_model.dart
│  ├─ mappers/
│  │  └─ user_settings_mapper.dart ✨ (NEW)
│  └─ repositories/
│     └─ user_settings_repository_impl.dart ✨ (NEW)
└─ presentation/
   ├─ pages/
   │  ├─ settings_page.dart
   │  └─ accessibility_page.dart
   └─ widgets/
```

---

## 🎯 RESUMO DAS MUDANÇAS

| Feature | Tipo | Ações |
|---------|------|-------|
| **bus_schedules** | Refactor | Move repos, consolidar datasources |
| **providers** | Melhoria | Adicionar interfaces, organizar |
| **routes** | Novo | Implementar Data + Infra completo |
| **settings** | Novo | Implementar Data + Infra completo |
| **core** | Check | ✅ Já está correto |

---

## 📐 BENEFÍCIOS DA REORGANIZAÇÃO

✅ **Testabilidade:** Interfaces de datasources e repositories
✅ **Escalabilidade:** Estrutura consistente em todos os features
✅ **Manutenibilidade:** Padrão claro (Domain/Data/Presentation)
✅ **Reutilização:** Mappers para conversão DTO ↔ Entity
✅ **Separação:** Cada camada tem responsabilidade clara

---

## 🚀 PRÓXIMAS AÇÕES

1. ✅ Reorganizar `bus_schedules`
2. ✅ Melhorar `providers`
3. ✅ Implementar `routes` completo
4. ✅ Implementar `settings` completo
5. ✅ Fazer commits com documentação
6. ✅ Atualizar imports em todo o projeto

---

**Preciso fazer essas reorganizações?** 🎯
