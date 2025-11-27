# ⚡ Quick Start - Edição de Agendamentos

## 1️⃣ Arquivo Principal: Dialog de Edição

📂 **Local:** `lib/features/bus_schedules/presentation/dialogs/edit_schedule_dialog.dart`

### Uso Rápido:
```dart
// Importar
import 'package:bussv1/features/bus_schedules/presentation/dialogs/edit_schedule_dialog.dart';

// Usar em qualquer widget
await showEditScheduleDialog(
  context,
  schedule, // BusScheduleModel
  () => _recarregarLista(), // Callback após salvar
);
```

---

## 2️⃣ Integração na Lista (Já Feita ✅)

```dart
// Cada item tem um ícone de edição
IconButton(
  icon: const Icon(Icons.edit, color: Colors.blue),
  onPressed: () {
    if (schedule is BusScheduleModel) {
      _handleEditSchedule(schedule);
    }
  },
)
```

---

## 3️⃣ Repositório - Como Usar

### Criar Repositório:
```dart
final dao = BusSchedulesLocalDao();
final repository = BusScheduleRepositoryImpl(localDao: dao);
```

### Operações Básicas:
```dart
// Listar
final response = await repository.listAll(pageSize: 20);

// Buscar por ID
final schedule = await repository.getById(id);

// Atualizar (usado no dialog de edição)
await repository.update(id, updatedSchedule);

// Deletar
await repository.delete(id);

// Buscar
final results = await repository.search("termo");
```

---

## 4️⃣ Fluxo Completo de Edição

1. ✅ Usuário clica no ícone de lápis
2. ✅ Dialog abre com dados preenchidos
3. ✅ Usuário edita campos
4. ✅ Clica "Salvar"
5. ✅ Sistema valida campos
6. ✅ Salva via `repository.update()`
7. ✅ Mostra SnackBar de sucesso
8. ✅ Dialog fecha
9. ✅ Lista recarrega automaticamente

---

## 5️⃣ Campos Editáveis

```
✏️ Nome da Rota (obrigatório)
✏️ Número da Rota
✏️ Destino (obrigatório)
✏️ Origem
✏️ Horário de Partida (obrigatório)
✏️ Horário de Chegada
✏️ Distância (km)
✏️ Duração (minutos)
✏️ Frequência (minutos)
✏️ Tarifa (R$)
📋 Status (Ativo/Atrasado/Cancelado)
♿ Acessibilidade (sim/não)
```

---

## 6️⃣ Tratamento de Erros

```dart
try {
  await showEditScheduleDialog(context, schedule, callback);
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Erro: $e')),
  );
}
```

---

## 7️⃣ Arquivos Criados

```
lib/features/bus_schedules/
├── presentation/dialogs/
│   └── edit_schedule_dialog.dart              ← NOVO (Dialog)
├── domain/repositories/
│   ├── i_bus_schedule_repository.dart         ← NOVO (Interface)
│   └── REPOSITORY_USAGE_EXAMPLE.dart          ← NOVO (Exemplos)
└── data/repositories/
    └── bus_schedule_repository_impl.dart      ← NOVO (Implementação)
```

---

## ✅ Tudo Pronto!

A edição de agendamentos está **100% funcional**. 

- Clique no lápis azul em qualquer item
- Edite os campos
- Salve e a lista recarrega automaticamente

**Nenhuma configuração adicional necessária!** 🚀
