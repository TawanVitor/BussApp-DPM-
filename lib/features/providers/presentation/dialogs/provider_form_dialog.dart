import 'package:flutter/material.dart';
import '../../domain/entities/provider.dart';

/// 📝 Dialog para criar/editar um provider
///
/// **Modos:**
/// - CREATE: Cria novo provider (sem ID, gera automaticamente)
/// - EDIT: Edita provider existente (usa ID existente)
///
/// **Responsabilidade:**
/// - Coletar dados do usuário via formulário
/// - Validar dados
/// - Retornar Provider (domain entity) preenchido
/// - NÃO persiste (fica a cargo da parent page)
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Este dialog RETORNA Provider (entidade de domínio)
/// - A parent é responsável por chamar Repository.create/update
/// - Dialog não conhece DTO nem DAO
///
/// **Uso (CREATE):**
/// ```dart
/// final newProvider = await showDialog<Provider>(
///   context: context,
///   builder: (context) => ProviderFormDialog(),  // Sem initialValue
/// );
/// if (newProvider != null) {
///   await _repository.create(newProvider);
/// }
/// ```
///
/// **Uso (EDIT):**
/// ```dart
/// final updated = await showDialog<Provider>(
///   context: context,
///   builder: (context) => ProviderFormDialog(
///     initialValue: existingProvider,
///   ),
/// );
/// if (updated != null) {
///   await _repository.update(updated);
/// }
/// ```
class ProviderFormDialog extends StatefulWidget {
  /// Provider inicial (para modo EDIT)
  /// Se null, cria novo provider (modo CREATE)
  final Provider? initialValue;

  /// Modo: "Criar" ou "Editar"
  String get _mode => initialValue != null ? 'Editar' : 'Criar';

  const ProviderFormDialog({
    this.initialValue,
    super.key,
  });

  @override
  State<ProviderFormDialog> createState() => _ProviderFormDialogState();
}

class _ProviderFormDialogState extends State<ProviderFormDialog> {
  /// Controllers dos campos
  late TextEditingController _nameController;
  late TextEditingController _imageUriController;
  late TextEditingController _distanceKmController;

  /// Flag para indicar se o provider está ativo
  late bool _isActive;

  /// Form key para validação
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // 🔵 Se está editando, preenche com dados existentes
    if (widget.initialValue != null) {
      _nameController = TextEditingController(text: widget.initialValue!.name);
      _imageUriController =
          TextEditingController(text: widget.initialValue!.imageUri ?? '');
      _distanceKmController = TextEditingController(
          text: widget.initialValue!.distanceKm.toString());
      _isActive = widget.initialValue!.isActive;
    }
    // 🔵 Se está criando, campos vazios
    else {
      _nameController = TextEditingController();
      _imageUriController = TextEditingController();
      _distanceKmController = TextEditingController(text: '0.0');
      _isActive = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUriController.dispose();
    _distanceKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget._mode} Provider'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔷 Nome (obrigatório)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome *',
                  hintText: 'Ex: João Silva',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Nome é obrigatório';
                  }
                  if (value!.length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔷 Image URI (opcional)
              TextFormField(
                controller: _imageUriController,
                decoration: const InputDecoration(
                  labelText: 'URL da Imagem (opcional)',
                  hintText: 'https://example.com/image.jpg',
                  prefixIcon: Icon(Icons.image),
                ),
                validator: (value) {
                  if (value?.isNotEmpty ?? false) {
                    // Se preenchido, valida como URL
                    try {
                      Uri.parse(value!);
                    } catch (e) {
                      return 'URL inválida';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔷 Distance em KM
              TextFormField(
                controller: _distanceKmController,
                decoration: const InputDecoration(
                  labelText: 'Distância (km)',
                  hintText: '5.2',
                  prefixIcon: Icon(Icons.location_on),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Distância é obrigatória';
                  }
                  try {
                    double.parse(value!);
                  } catch (e) {
                    return 'Distância deve ser um número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 🔷 Status (Ativo/Inativo)
              CheckboxListTile(
                value: _isActive,
                onChanged: (value) {
                  setState(() => _isActive = value ?? true);
                },
                title: const Text('Ativo'),
                subtitle: const Text(
                    'Se desmarcado, o provider não aparecerá na lista'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        // ❌ Botão Cancelar
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // ✅ Botão Salvar
        ElevatedButton(
          onPressed: _submit,
          child: Text(widget._mode),
        ),
      ],
    );
  }

  /// ✅ Valida e retorna o Provider preenchido
  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 🔵 Cria ou atualiza Provider
    final now = DateTime.now();
    
    // 📌 Gera ID único para novo provider usando timestamp + random
    String generateId() {
      return 'prov_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecond % 1000)}';
    }

    final provider = Provider(
      // 📌 Se está criando, gera novo ID; se está editando, mantém ID
      id: widget.initialValue?.id ?? generateId(),
      name: _nameController.text,
      imageUri: _imageUriController.text.isEmpty
          ? null
          : _imageUriController.text,
      distanceKm: double.parse(_distanceKmController.text),
      // 📌 Se criando, usa data atual; se editando, mantém original
      createdAt: widget.initialValue?.createdAt ?? now,
      // 📌 Sempre atualiza updatedAt
      updatedAt: now,
      isActive: _isActive,
    );

    Navigator.pop(context, provider);
  }
}
