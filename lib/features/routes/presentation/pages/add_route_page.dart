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
  bool _isLoading = false;

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

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final route = BusRoute(
        id: widget.initialRoute?.id ?? DateTime.now().toString(),
        name: _nameController.text.trim(),
        from: _fromController.text.trim(),
        to: _toController.text.trim(),
        time: _timeController.text.trim(),
        stops: widget.initialRoute?.stops ?? [],
        createdAt: widget.initialRoute?.createdAt ?? DateTime.now(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? '✓ Rota atualizada com sucesso'
                  : '✓ Rota criada com sucesso',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(route);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aguarde... salvando dados')),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Editar Rota' : 'Nova Rota'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========== Seção: Informações Básicas ==========
                    Text(
                      'Informações da Rota',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Nome da Rota
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Nome da Rota',
                        hintText: 'Ex: Casa → Campus',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_bus),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Informe um nome' : null,
                    ),
                    const SizedBox(height: 16),

                    // Origem e Destino (lado a lado)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _fromController,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Origem',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe a origem'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _toController,
                            enabled: !_isLoading,
                            decoration: const InputDecoration(
                              labelText: 'Destino',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Informe o destino'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Horário
                    TextFormField(
                      controller: _timeController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Horário de Partida',
                        hintText: 'Ex: 07:00',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o horário'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // ========== Botões de Ação ==========
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton.icon(
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                          onPressed: _isLoading ? null : () => Navigator.pop(context),
                        ),
                        FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: Text(widget.isEditing ? 'Salvar' : 'Adicionar'),
                          onPressed: _isLoading ? null : _save,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Loading Indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
