import 'package:flutter/material.dart';

import '../../domain/entities/provider.dart';

/// 🎴 Card que exibe um provider individual
///
/// **Responsabilidade:** Apresentar um único Provider de forma visual atraente
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Recebe Provider (domain entity), não ProviderModel (DTO)
/// - Não faz nenhuma persistência
/// - Todos os callbacks (edit, delete, tap) retornam para a parent
/// - Usa design consistente com o app (Material 3)
///
/// **Exemplo visual:**
/// ```
/// ┌──────────────────────────────────────┐
/// │  [IMG]  João Silva                   │
/// │         ⭐ 5.2 km distante       ✓  │
/// │         Última atualização há 2h     │
/// │                                      │
/// │    [Editar]  [Deletar]  [+ Info]     │
/// └──────────────────────────────────────┘
/// ```
class ProviderListItem extends StatelessWidget {
  /// Provider a exibir (entidade de domínio)
  final Provider provider;

  /// Callback ao clicar editar
  final VoidCallback onEdit;

  /// Callback ao clicar deletar
  final VoidCallback onDelete;

  /// Callback ao toque no card
  final VoidCallback? onTap;

  /// Construtor
  const ProviderListItem({
    required this.provider,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔷 Primeira linha: Nome + Status + Distância
              Row(
                children: [
                  // Imagem de perfil (placeholder se não houver)
                  if (provider.imageUri != null && provider.imageUri!.isNotEmpty)
                    CircleAvatar(
                      backgroundImage: NetworkImage(provider.imageUri!),
                      radius: 24,
                      onBackgroundImageError: (_, __) {},
                    )
                  else
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Nome e distância
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📌 Nome do provider
                        Text(
                          provider.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // 📍 Distância
                        Text(
                          '📍 ${provider.distanceKm.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ✅ Indicador de status (ativo/inativo)
                  if (provider.isActive)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    )
                  else
                    Icon(
                      Icons.cancel,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // 🔷 Divider
              Divider(height: 1, color: Colors.grey[300]),
              const SizedBox(height: 12),
              // 🔷 Segunda linha: Timestamps
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📅 Criado',
                          style: theme.textTheme.labelSmall,
                        ),
                        Text(
                          _formatDate(provider.createdAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔄 Atualizado',
                          style: theme.textTheme.labelSmall,
                        ),
                        Text(
                          _formatDate(provider.updatedAt),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 🔷 Botões de ação
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ✏️ Botão Editar
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar'),
                  ),
                  const SizedBox(width: 8),
                  // 🗑️ Botão Deletar
                  TextButton.icon(
                    onPressed: () {
                      _showDeleteConfirmation(context);
                    },
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Deletar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📅 Formata uma data para exibição
  ///
  /// **Exemplo:**
  /// - Hoje → "10:30"
  /// - Ontem → "Ontem"
  /// - Há dias → "10/01"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      // Hoje → mostra hora
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Ontem';
    } else {
      // Outros dias → mostra data
      return '${date.day}/${date.month}';
    }
  }

  /// 🗑️ Mostra dialog de confirmação antes de deletar
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Provider?'),
        content: Text(
          'Tem certeza que deseja deletar "${provider.name}"?\n\n'
          'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }
}
