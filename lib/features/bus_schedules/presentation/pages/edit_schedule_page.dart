import 'package:flutter/material.dart';
import '../../domain/entities/bus_schedule.dart';

/// Página de edição de horário de ônibus
class EditSchedulePage extends StatefulWidget {
  final BusSchedule schedule;

  const EditSchedulePage({
    super.key,
    required this.schedule,
  });

  @override
  State<EditSchedulePage> createState() => _EditSchedulePageState();
}

class _EditSchedulePageState extends State<EditSchedulePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _routeNameController;
  late final TextEditingController _routeNumberController;
  late final TextEditingController _destinationController;
  late final TextEditingController _originController;
  late final TextEditingController _departureTimeController;
  late final TextEditingController _arrivalTimeController;
  late String _status;

  @override
  void initState() {
    super.initState();
    _routeNameController = TextEditingController(
      text: widget.schedule.routeName,
    );
    _routeNumberController = TextEditingController(
      text: widget.schedule.routeNumber ?? '',
    );
    _destinationController = TextEditingController(
      text: widget.schedule.destination,
    );
    _originController = TextEditingController(
      text: widget.schedule.origin ?? '',
    );
    _departureTimeController = TextEditingController(
      text: widget.schedule.departureTime,
    );
    _arrivalTimeController = TextEditingController(
      text: widget.schedule.arrivalTime ?? '',
    );
    _status = widget.schedule.status;
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _routeNumberController.dispose();
    _destinationController.dispose();
    _originController.dispose();
    _departureTimeController.dispose();
    _arrivalTimeController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedSchedule = widget.schedule.copyWith(
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
        status: _status,
        updatedAt: DateTime.now(),
      );

      Navigator.of(context).pop(updatedSchedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Horário'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _routeNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Rota *',
                hintText: 'Ex: Linha 250 - Centro/Terminal',
                prefixIcon: Icon(Icons.directions_bus),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _routeNumberController,
              decoration: const InputDecoration(
                labelText: 'Número da Linha',
                hintText: 'Ex: 250',
                prefixIcon: Icon(Icons.numbers),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origem',
                hintText: 'Ex: Centro',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destino *',
                hintText: 'Ex: Terminal Central',
                prefixIcon: Icon(Icons.place),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departureTimeController,
              decoration: const InputDecoration(
                labelText: 'Horário de Partida *',
                hintText: 'Ex: 14:30',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
                if (!regex.hasMatch(v.trim())) {
                  return 'Formato inválido (use HH:mm)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _arrivalTimeController,
              decoration: const InputDecoration(
                labelText: 'Horário de Chegada',
                hintText: 'Ex: 15:10',
                prefixIcon: Icon(Icons.access_time_filled),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  final regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
                  if (!regex.hasMatch(v.trim())) {
                    return 'Formato inválido (use HH:mm)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status *',
                prefixIcon: Icon(Icons.info),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Ativo'),
                ),
                DropdownMenuItem(
                  value: 'delayed',
                  child: Text('Atrasado'),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child: Text('Cancelado'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Alterações'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}