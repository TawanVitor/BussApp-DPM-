import 'package:flutter/material.dart';
import '../../data/datasources/bus_schedules_local_dao.dart';
import '../../domain/entities/bus_schedule.dart';
import '../../domain/entities/bus_schedule_filters.dart';
import '../../domain/entities/bus_schedule_list_response.dart';
import '../dialogs/schedule_actions_dialog.dart';
import '../dialogs/remove_confirmation_dialog.dart';
import '../pages/edit_schedule_page.dart';

class BusSchedulesListPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const BusSchedulesListPage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<BusSchedulesListPage> createState() => _BusSchedulesListPageState();
}

class _BusSchedulesListPageState extends State<BusSchedulesListPage> {
  final _dao = BusSchedulesLocalDao();
  BusScheduleListResponse? _response;
  bool _isLoading = true;
  BusScheduleFilters _filters = BusScheduleFilters();

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _isLoading = true);

    try {
      final response = await _dao.listAll(
        filters: _filters,
        include: ['stops'],
      );

      if (mounted) {
        setState(() {
          _response = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar horários: $e')),
        );
      }
    }
  }

  void _showFilterDialog() {
    final routeController = TextEditingController(text: _filters.route);
    final destinationController = TextEditingController(text: _filters.destination);
    final afterController = TextEditingController(text: _filters.after);
    final beforeController = TextEditingController(text: _filters.before);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar Horários'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: routeController,
                  decoration: const InputDecoration(
                    labelText: 'Rota/Linha',
                    hintText: 'Ex: Linha 250',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: destinationController,
                  decoration: const InputDecoration(
                    labelText: 'Destino',
                    hintText: 'Ex: Terminal Central',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: afterController,
                  decoration: const InputDecoration(
                    labelText: 'Após horário',
                    hintText: 'Ex: 14:00',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: beforeController,
                  decoration: const InputDecoration(
                    labelText: 'Antes do horário',
                    hintText: 'Ex: 18:00',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                routeController.dispose();
                destinationController.dispose();
                afterController.dispose();
                beforeController.dispose();
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _filters = BusScheduleFilters(
                    route: routeController.text.isEmpty ? null : routeController.text,
                    destination: destinationController.text.isEmpty
                        ? null
                        : destinationController.text,
                    after: afterController.text.isEmpty ? null : afterController.text,
                    before: beforeController.text.isEmpty ? null : beforeController.text,
                  );
                });
                routeController.dispose();
                destinationController.dispose();
                afterController.dispose();
                beforeController.dispose();
                Navigator.pop(context);
                _loadSchedules();
              },
              child: const Text('Aplicar'),
            ),
            if (_filters.hasFilters)
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters = BusScheduleFilters();
                  });
                  routeController.dispose();
                  destinationController.dispose();
                  afterController.dispose();
                  beforeController.dispose();
                  Navigator.pop(context);
                  _loadSchedules();
                },
                child: const Text('Limpar'),
              ),
          ],
        );
      },
    );
  }

  // Handler para edição
  Future<void> _handleEdit(BusSchedule schedule) async {
    final updatedSchedule = await Navigator.push<BusSchedule>(
      context,
      MaterialPageRoute(
        builder: (context) => EditSchedulePage(schedule: schedule),
      ),
    );

    if (updatedSchedule != null) {
      try {
        // Atualizar no DAO
        await _dao.upsertAll([updatedSchedule]);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Horário atualizado com sucesso')),
          );
          _loadSchedules(); // Recarregar lista
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar: $e')),
          );
        }
      }
    }
  }

  // Handler para remoção
  Future<void> _handleRemove(BusSchedule schedule) async {
    await RemoveConfirmationDialog.show(
      context: context,
      schedule: schedule,
      onConfirm: () async {
        try {
          // Remover do DAO usando filtro por ID
          final allSchedules = await _dao.listAll(pageSize: 10000);
          final filtered = allSchedules.data
              .where((s) => s.id != schedule.id)
              .toList();

          await _dao.clear();
          if (filtered.isNotEmpty) {
            await _dao.upsertAll(filtered);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Horário removido com sucesso')),
            );
            _loadSchedules(); // Recarregar lista
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao remover: $e')),
            );
          }
        }
      },
    );
  }

  // Handler para exibir diálogo de ações
  void _showActionsDialog(BusSchedule schedule) {
    ScheduleActionsDialog.show(
      context: context,
      schedule: schedule,
      onEdit: () => _handleEdit(schedule),
      onRemove: () => _handleRemove(schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horários de Ônibus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: 'Trocar tema',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _response == null || _response!.data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhum horário encontrado',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _showFilterDialog,
                        child: const Text('Ajustar filtros'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_filters.hasFilters)
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_alt, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Filtros ativos',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _filters = BusScheduleFilters());
                                _loadSchedules();
                              },
                              child: const Text('Limpar'),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Total: ${_response!.meta.total} horários',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _response!.data.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final schedule = _response!.data[index];
                          return _BusScheduleCard(
                            schedule: schedule,
                            onLongPress: () => _showActionsDialog(schedule),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _BusScheduleCard extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onLongPress;

  const _BusScheduleCard({
    required this.schedule,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = schedule.status == 'active'
        ? Colors.green
        : schedule.status == 'delayed'
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetailsDialog(context),
        onLongPress: onLongPress, // Adiciona long press
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (schedule.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        schedule.imageUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_bus),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.directions_bus,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                schedule.routeName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                schedule.status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Para: ${schedule.destination}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TimeInfo(
                    icon: Icons.access_time,
                    label: 'Partida',
                    time: schedule.departureTime,
                  ),
                  if (schedule.arrivalTime != null)
                    _TimeInfo(
                      icon: Icons.access_time_filled,
                      label: 'Chegada',
                      time: schedule.arrivalTime!,
                    ),
                  if (schedule.durationMinutes != null)
                    _InfoChip(
                      icon: Icons.timelapse,
                      label: '${schedule.durationMinutes} min',
                    ),
                ],
              ),
              if (schedule.stops != null && schedule.stops!.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${schedule.stops!.length} paradas',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showDetailsDialog(context),
                      child: const Text('Ver detalhes'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(schedule.routeName),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Destino', value: schedule.destination),
              if (schedule.origin != null)
                _DetailRow(label: 'Origem', value: schedule.origin!),
              _DetailRow(label: 'Partida', value: schedule.departureTime),
              if (schedule.arrivalTime != null)
                _DetailRow(label: 'Chegada', value: schedule.arrivalTime!),
              if (schedule.distanceKm != null)
                _DetailRow(
                  label: 'Distância',
                  value: '${schedule.distanceKm!.toStringAsFixed(1)} km',
                ),
              if (schedule.fare != null)
                _DetailRow(
                  label: 'Tarifa',
                  value: 'R\$ ${schedule.fare!.toStringAsFixed(2)}',
                ),
              if (schedule.accessibility == true)
                const _DetailRow(
                  label: 'Acessibilidade',
                  value: 'Veículo acessível',
                ),
              if (schedule.stops != null && schedule.stops!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Paradas (${schedule.stops!.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...schedule.stops!.map((stop) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${stop.order}. ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(stop.name),
                                Text(
                                  stop.street,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (stop.estimatedTime != null)
                                  Text(
                                    'Às ${stop.estimatedTime}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

class _TimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String time;

  const _TimeInfo({
    required this.icon,
    required this.label,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}