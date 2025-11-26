import 'package:flutter/material.dart';
import '../../domain/entities/bus_schedule.dart';

/// Diálogo de ações para um horário de ônibus selecionado
/// Apresenta três opções: Editar, Remover e Fechar
class ScheduleActionsDialog extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const ScheduleActionsDialog({
    super.key,
    required this.schedule,
    required this.onEdit,
    required this.onRemove,
  });

  /// Método estático para facilitar a exibição do diálogo
  static Future<void> show({
    required BuildContext context,
    required BusSchedule schedule,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Não fecha ao clicar fora
      builder: (context) => ScheduleActionsDialog(
        schedule: schedule,
        onEdit: onEdit,
        onRemove: onRemove,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule.routeName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Destino: ${schedule.destination}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Horário: ${schedule.departureTime}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Divider(height: 24),
          Text(
            'Escolha uma ação:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      actions: [
        // Botão Editar
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
            onEdit(); // Delega para o handler de edição
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
          ),
        ),
        
        // Botão Remover
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
            onRemove(); // Delega para o handler de remoção
          },
          icon: const Icon(Icons.delete),
          label: const Text('Remover'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        
        // Botão Fechar
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).pop(); // Apenas fecha o diálogo
          },
          icon: const Icon(Icons.close),
          label: const Text('Fechar'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceEvenly,
    );
  }
}