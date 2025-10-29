import 'package:flutter/material.dart';
import '../Models/bus_route.dart';

class AddRoutePage extends StatefulWidget {
  final BusRoute? initialRoute;
  final bool isEditing;

  const AddRoutePage({
    super.key,
    this.initialRoute,
    this.isEditing = false,
  });

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _scheduleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.initialRoute;
    if (r != null) {
      _nameController.text = r.name;
      _originController.text = r.from;
      _destinationController.text = r.to;
      _scheduleController.text = r.time;
    }
  }

  void _saveRoute() {
    if (_formKey.currentState!.validate()) {
      final newRoute = BusRoute(
        name: _nameController.text,
        from: _originController.text,
        to: _destinationController.text,
        time: _scheduleController.text,
        stops: widget.initialRoute?.stops ?? [],
      );
      Navigator.pop(context, newRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'Editar Rota' : 'Adicionar Nova Rota')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Rota'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o nome da rota' : null,
              ),
              TextFormField(
                controller: _originController,
                decoration: const InputDecoration(labelText: 'Origem'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe a origem' : null,
              ),
              TextFormField(
                controller: _destinationController,
                decoration: const InputDecoration(labelText: 'Destino'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o destino' : null,
              ),
              TextFormField(
                controller: _scheduleController,
                decoration: const InputDecoration(labelText: 'Horário'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Informe o horário' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRoute,
                child: Text(widget.isEditing ? 'Salvar Alterações' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
