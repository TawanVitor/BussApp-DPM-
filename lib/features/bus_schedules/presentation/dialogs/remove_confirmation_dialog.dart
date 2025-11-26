import 'package:flutter/material.dart';
import '../../domain/entities/bus_schedule.dart';

/// Diálogo de confirmação para remoção de horário
class RemoveConfirmationDialog extends StatelessWidget {
  final BusSchedule schedule;
  final VoidCallback onConfirm;

  const RemoveConfirmationDialog({
    super.key,
    required this.schedule,
    required this.onConfirm,
  });

  /// Método estático para facilitar a exibição do diálogo
  static Future<bool?> show({
    required BuildContext context,
    required BusSchedule schedule,
    required VoidCallback onConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Não fecha ao clicar fora
      builder: (context) => RemoveConfirmationDialog(
        schedule: schedule,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Confirmar Remoção'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tem certeza que deseja remover este horário?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.routeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Destino: ${schedule.destination}'),
                Text('Horário: ${schedule.departureTime}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Esta ação não pode ser desfeita.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      actions: [
        // Botão Cancelar
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Retorna false
          },
          child: const Text('Cancelar'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
        ),
        
        // Botão Confirmar Remoção
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(true); // Retorna true
            onConfirm(); // Executa a remoção
          },
          icon: const Icon(Icons.delete_forever),
          label: const Text('Remover'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}