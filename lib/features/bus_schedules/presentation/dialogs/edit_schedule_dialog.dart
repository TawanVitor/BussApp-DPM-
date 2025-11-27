import 'package:flutter/material.dart';
import 'package:bussv1/features/bus_schedules/data/models/bus_schedule_model.dart';
import 'package:bussv1/features/bus_schedules/data/datasources/bus_schedules_local_dao.dart';

Future<void> showEditScheduleDialog(
  BuildContext context,
  BusScheduleModel schedule,
  VoidCallback onScheduleUpdated,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => _EditScheduleDialog(
      schedule: schedule,
      onScheduleUpdated: onScheduleUpdated,
    ),
  );
}

class _EditScheduleDialog extends StatefulWidget {
  final BusScheduleModel schedule;
  final VoidCallback onScheduleUpdated;

  const _EditScheduleDialog({
    required this.schedule,
    required this.onScheduleUpdated,
  });

  @override
  State<_EditScheduleDialog> createState() => _EditScheduleDialogState();
}

class _EditScheduleDialogState extends State<_EditScheduleDialog> {
  late TextEditingController _routeNameController;
  late TextEditingController _routeNumberController;
  late TextEditingController _destinationController;
  late TextEditingController _originController;
  late TextEditingController _departureTimeController;
  late TextEditingController _arrivalTimeController;
  late TextEditingController _distanceKmController;
  late TextEditingController _durationMinutesController;
  late TextEditingController _frequencyMinutesController;
  late TextEditingController _fareController;
  late String _selectedStatus;
  late bool _accessibility;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _routeNameController =
        TextEditingController(text: widget.schedule.routeName);
    _routeNumberController =
        TextEditingController(text: widget.schedule.routeNumber ?? '');
    _destinationController =
        TextEditingController(text: widget.schedule.destination);
    _originController =
        TextEditingController(text: widget.schedule.origin ?? '');
    _departureTimeController =
        TextEditingController(text: widget.schedule.departureTime);
    _arrivalTimeController =
        TextEditingController(text: widget.schedule.arrivalTime ?? '');
    _distanceKmController =
        TextEditingController(text: widget.schedule.distanceKm?.toString() ?? '');
    _durationMinutesController = TextEditingController(
        text: widget.schedule.durationMinutes?.toString() ?? '');
    _frequencyMinutesController = TextEditingController(
        text: widget.schedule.frequencyMinutes?.toString() ?? '');
    _fareController =
        TextEditingController(text: widget.schedule.fare?.toString() ?? '');
    _selectedStatus = widget.schedule.status;
    _accessibility = widget.schedule.accessibility ?? false;
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _routeNumberController.dispose();
    _destinationController.dispose();
    _originController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    _distanceKmController.dispose();
    _durationMinutesController.dispose();
    _frequencyMinutesController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final updatedSchedule = BusScheduleModel(
        id: widget.schedule.id,
        routeName: _routeNameController.text.trim(),
        routeNumber: _routeNumberController.text.trim().isEmpty
            ? null
            : _routeNumberController.text.trim(),
        destination: _destinationController.text.trim(),
        origin: _originController.text.trim().isEmpty
            ? null
            : _originController.text.trim(),
        departureTime: _departureTimeController.text.trim(),
        arrivalTime: _arrivalTimeController.text.trim().isEmpty
            ? null
            : _arrivalTimeController.text.trim(),
        distanceKm: _distanceKmController.text.trim().isEmpty
            ? null
            : double.tryParse(_distanceKmController.text.trim()),
        durationMinutes: _durationMinutesController.text.trim().isEmpty
            ? null
            : int.tryParse(_durationMinutesController.text.trim()),
        imageUrl: widget.schedule.imageUrl,
        status: _selectedStatus,
        stops: widget.schedule.stops,
        frequencyMinutes: _frequencyMinutesController.text.trim().isEmpty
            ? null
            : int.tryParse(_frequencyMinutesController.text.trim()),
        operatingDays: widget.schedule.operatingDays,
        accessibility: _accessibility,
        fare: _fareController.text.trim().isEmpty
            ? null
            : double.tryParse(_fareController.text.trim()),
        createdAt: widget.schedule.createdAt,
        updatedAt: DateTime.now(),
      );

      final dao = BusSchedulesLocalDao();
      await dao.upsertAll([updatedSchedule]);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agendamento atualizado com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        widget.onScheduleUpdated();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _validateForm() {
    if (_routeNameController.text.trim().isEmpty) {
      _showValidationError('Nome da rota é obrigatório');
      return false;
    }
    if (_destinationController.text.trim().isEmpty) {
      _showValidationError('Destino é obrigatório');
      return false;
    }
    if (_departureTimeController.text.trim().isEmpty) {
      _showValidationError('Horário de partida é obrigatório');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Editar Agendamento',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Nome da Rota',
                _routeNameController,
                Icons.route,
              ),
              _buildTextField(
                'Número da Rota',
                _routeNumberController,
                Icons.numbers,
              ),
              _buildTextField(
                'Destino',
                _destinationController,
                Icons.location_on,
              ),
              _buildTextField(
                'Origem',
                _originController,
                Icons.location_on_outlined,
              ),
              _buildTextField(
                'Horário de Partida',
                _departureTimeController,
                Icons.access_time,
              ),
              _buildTextField(
                'Horário de Chegada',
                _arrivalTimeController,
                Icons.access_time_filled,
              ),
              _buildTextField(
                'Distância (km)',
                _distanceKmController,
                Icons.straighten,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'Duração (minutos)',
                _durationMinutesController,
                Icons.schedule,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'Frequência (minutos)',
                _frequencyMinutesController,
                Icons.repeat,
                keyboardType: TextInputType.number,
              ),
              _buildTextField(
                'Tarifa (R\$)',
                _fareController,
                Icons.local_offer,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildStatusDropdown(),
              const SizedBox(height: 12),
              _buildAccessibilitySwitch(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveChanges,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Salvando...' : 'Salvar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Status',
        prefixIcon: const Icon(Icons.info),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: ['active', 'delayed', 'cancelled']
          .map((status) => DropdownMenuItem(
                value: status,
                child: Text(_getStatusLabel(status)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedStatus = value ?? 'active');
      },
    );
  }

  Widget _buildAccessibilitySwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Acessibilidade',
          style: TextStyle(fontSize: 16),
        ),
        Switch(
          value: _accessibility,
          onChanged: (value) {
            setState(() => _accessibility = value);
          },
        ),
      ],
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Ativo';
      case 'delayed':
        return 'Atrasado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return status;
    }
  }
}