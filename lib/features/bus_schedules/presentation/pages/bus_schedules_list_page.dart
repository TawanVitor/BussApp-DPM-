import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bussv1/features/bus_schedules/presentation/dialogs/edit_schedule_dialog.dart';
import '../../data/datasources/bus_schedules_local_dao.dart';
import '../../data/models/bus_schedule_model.dart';
import '../../domain/entities/bus_schedule.dart';
import '../../domain/entities/bus_schedule_filters.dart';
import '../../domain/entities/bus_schedule_list_response.dart';
import '../../infrastructure/remote/supabase_bus_schedules_remote_datasource.dart';
import '../../infrastructure/repositories/bus_schedules_repository_impl.dart';
import '../dialogs/schedule_actions_dialog.dart';
import '../dialogs/remove_confirmation_dialog.dart';

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

  /// Carrega agendamentos com sincronização automática se cache está vazio
  ///
  /// **Fluxo:**
  /// 1. Carrega lista local do cache (DAO)
  /// 2. Se vazio: sincroniza com Supabase em background
  /// 3. Recarrega lista após sync
  /// 4. Mantém UX responsiva (não bloqueia com overlay)
  ///
  /// **Importante:** Sempre verificar `mounted` antes de setState para evitar
  /// erro "setState called after dispose" em operações assíncronas
  Future<void> _loadSchedules() async {
    if (kDebugMode) {
      print('BusSchedulesListPage._loadSchedules: iniciando carregamento');
    }

    setState(() => _isLoading = true);

    try {
      // ========== PASSO 1: Carregar cache local ==========
      // Sempre tentar carregar do cache primeiro (rápido, responsivo)
      final response = await _dao.listAll(
        filters: _filters,
        include: ['stops'],
      );

      if (kDebugMode) {
        print('BusSchedulesListPage._loadSchedules: carregados ${response.data.length} agendamentos do cache');
      }

      // ========== PASSO 2: Se cache vazio, sincronizar com Supabase ==========
      if (response.data.isEmpty) {
        if (kDebugMode) {
          print('BusSchedulesListPage._loadSchedules: cache vazio, iniciando sincronização com Supabase');
        }

        try {
          // Construir instâncias de remote API e repository
          // Nota: Em produção, isso deve vir do service locator (GetIt, Riverpod, etc)
          final remoteApi = SupabaseBusSchedulesRemoteDatasource();
          final repository = BusSchedulesRepositoryImpl(
            remoteApi: remoteApi,
            localDao: _dao,
          );

          // Sincronizar: busca do Supabase, converte, persiste no cache local
          final synced = await repository.syncFromServer();

          if (kDebugMode) {
            print('BusSchedulesListPage._loadSchedules: sincronizados $synced agendamentos');
          }

          // ========== PASSO 3: Recarregar lista após sync ==========
          // Buscar novamente do cache agora que foi atualizado
          final updatedResponse = await _dao.listAll(
            filters: _filters,
            include: ['stops'],
          );

          if (mounted) {
            setState(() {
              _response = updatedResponse;
              _isLoading = false;
            });
          }

          if (kDebugMode) {
            print('BusSchedulesListPage._loadSchedules: lista atualizada com ${updatedResponse.data.length} itens');
          }
        } catch (syncError) {
          // Erro na sincronização não é fatal - continuar com cache vazio
          if (kDebugMode) {
            print('BusSchedulesListPage._loadSchedules: erro ao sincronizar!');
            print('  erro: $syncError');
            print('  continuando com cache vazio');
          }

          if (mounted) {
            setState(() {
              _response = response;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao sincronizar: $syncError'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // Cache tem dados - usar direto (sincronização em background pode ser implementada depois)
        if (mounted) {
          setState(() {
            _response = response;
            _isLoading = false;
          });
        }

        if (kDebugMode) {
          print('BusSchedulesListPage._loadSchedules: usando dados do cache (sync em background opcional)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesListPage._loadSchedules: ERRO ao carregar!');
        print('  erro: $e');
      }

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

  Future<void> _handleEdit(BusSchedule schedule) async {
    // Convertendo para modelo para edição
    if (schedule is! BusScheduleModel) return;
    
    await showEditScheduleDialog(
      context,
      schedule,
      () => _loadSchedules(),
    );
  }

  Future<void> _handleRemove(BusSchedule schedule) async {
    await RemoveConfirmationDialog.show(
      context: context,
      schedule: schedule,
      onConfirm: () async {
        try {
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
            _loadSchedules();
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

  void _showActionsDialog(BusSchedule schedule) {
    ScheduleActionsDialog.show(
      context: context,
      schedule: schedule,
      onEdit: () => _handleEdit(schedule),
      onRemove: () => _handleRemove(schedule),
    );
  }

  Future<void> _handleEditSchedule(BusScheduleModel schedule) async {
    await showEditScheduleDialog(
      context,
      schedule,
      () => _loadSchedules(),
    );
  }

  /// Método para RefreshIndicator - sincroniza com Supabase
  ///
  /// **Propósito:** Permitir ao usuário puxar para baixo e forçar sincronização
  /// **Comportamento:** Sempre executa sync, mesmo que cache tenha dados
  /// **UX:** Mostra loading durante a sincronização
  Future<void> _handleRefresh() async {
    if (kDebugMode) {
      print('BusSchedulesListPage._handleRefresh: sincronização manual iniciada');
    }

    try {
      // Construir instâncias (deve vir do service locator em produção)
      final remoteApi = SupabaseBusSchedulesRemoteDatasource();
      final repository = BusSchedulesRepositoryImpl(
        remoteApi: remoteApi,
        localDao: _dao,
      );

      // Sincronizar com timeout
      final synced = await repository.syncFromServer().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            print('BusSchedulesListPage._handleRefresh: TIMEOUT na sincronização');
          }
          throw Exception('Timeout ao sincronizar');
        },
      );

      if (kDebugMode) {
        print('BusSchedulesListPage._handleRefresh: sincronizados $synced agendamentos');
      }

      // Recarregar lista
      await _loadSchedules();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sincronizados $synced agendamentos')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('BusSchedulesListPage._handleRefresh: erro!');
        print('  erro: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sincronizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ônibus na Região'),
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _response == null || _response!.data.isEmpty
                ? ListView(
                    // ⚠️ IMPORTANTE: AlwaysScrollableScrollPhysics permite pull-to-refresh
                    // mesmo sem items na lista. Sem isso, o usuário não consegue puxar
                    // para sincronizar quando a lista está vazia!
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Center(
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
                              Text(
                                'Puxe para sincronizar dados do servidor',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: _showFilterDialog,
                                child: const Text('Ajustar filtros'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
                          // AlwaysScrollableScrollPhysics também aqui para consistência
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _response!.data.length,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final schedule = _response!.data[index];
                            return _BusScheduleCard(
                              schedule: schedule,
                              onLongPress: () => _showActionsDialog(schedule),
                              onEdit: (scheduleModel) =>
                                  _handleEditSchedule(scheduleModel),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _BusScheduleCard extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onLongPress;
  final Function(BusScheduleModel)? onEdit;

  const _BusScheduleCard({
    required this.schedule,
    required this.onLongPress,
    this.onEdit,
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
        onLongPress: onLongPress,
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
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      if (schedule is BusScheduleModel && onEdit != null) {
                        onEdit!(schedule as BusScheduleModel);
                      }
                    },
                    tooltip: 'Editar agendamento',
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
                ...schedule.stops!
                    .map((stop) => Padding(
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
                        ))
                    .toList(),
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