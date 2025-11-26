import 'package:flutter/material.dart';
import 'package:bussv1/features/routes/domain/entities/bus_route.dart';

class AddRoutePage extends StatefulWidget {
  final BusRoute? initialRoute;
  final bool isEditing;

  const AddRoutePage({super.key, this.initialRoute, this.isEditing = false});

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _fromController;
  late final TextEditingController _toController;
  late final TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialRoute?.name ?? '',
    );
    _fromController = TextEditingController(
      text: widget.initialRoute?.from ?? '',
    );
    _toController = TextEditingController(text: widget.initialRoute?.to ?? '');
    _timeController = TextEditingController(
      text: widget.initialRoute?.time ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fromController.dispose();
    _toController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final route = BusRoute(
        id: widget.initialRoute?.id ?? DateTime.now().toString(),
        name: _nameController.text.trim(),
        from: _fromController.text.trim(),
        to: _toController.text.trim(),
        time: _timeController.text.trim(),
        stops: widget.initialRoute?.stops ?? [],
        createdAt: widget.initialRoute?.createdAt ?? DateTime.now(),
      );
      Navigator.of(context).pop(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Rota' : 'Nova Rota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da rota'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fromController,
                decoration: const InputDecoration(labelText: 'Origem'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe a origem' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _toController,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o destino'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: const InputDecoration(
                  labelText: 'Horário (ex: 07:00)',
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o horário'
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.isEditing ? 'Salvar' : 'Adicionar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
