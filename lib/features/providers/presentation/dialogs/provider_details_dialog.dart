import 'package:flutter/material.dart';
import '../../domain/entities/provider.dart';

/// 📖 Dialog para exibir detalhes completos de um provider
///
/// **Responsabilidade:**
/// - Mostrar informações do provider de forma detalhada
/// - Permitir visualização em modo read-only
/// - Opcional: botões de ação (editar, deletar)
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Recebe Provider (domain entity)
/// - Não faz nenhuma modificação ou persistência
/// - Apenas apresenta informações
///
/// **Uso:**
/// ```dart
/// await showDialog(
///   context: context,
///   builder: (context) => ProviderDetailsDialog(provider: selectedProvider),
/// );
/// ```
class ProviderDetailsDialog extends StatelessWidget {
  /// Provider a exibir (entidade de domínio)
  final Provider provider;

  /// Callback quando usuário clica editar (opcional)
  final VoidCallback? onEdit;

  /// Callback quando usuário clica deletar (opcional)
  final VoidCallback? onDelete;

  const ProviderDetailsDialog({
    required this.provider,
    this.onEdit,
    this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔷 Header com imagem e nome
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Imagem grande
                  if (provider.imageUri != null && provider.imageUri!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        provider.imageUri!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(theme, 120),
                      ),
                    )
                  else
                    _buildPlaceholder(theme, 120),
                  const SizedBox(height: 12),
                  // Nome e status
                  Text(
                    provider.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Status chip
                  Chip(
                    label: Text(provider.isActive ? 'Ativo' : 'Inativo'),
                    backgroundColor: provider.isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: provider.isActive ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // 🔷 Conteúdo (detalhes)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(theme, '🆔 ID', provider.id),
                  const Divider(),
                  _buildDetailRow(
                    theme,
                    '📍 Distância',
                    '${provider.distanceKm.toStringAsFixed(2)} km',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    theme,
                    '📅 Criado em',
                    _formatDateTime(provider.createdAt),
                  ),
                  const Divider(),
                  _buildDetailRow(
                    theme,
                    '🔄 Atualizado em',
                    _formatDateTime(provider.updatedAt),
                  ),
                  if (provider.imageUri != null && provider.imageUri!.isNotEmpty) ...[
                    const Divider(),
                    _buildDetailRow(theme, '🖼️ Imagem', provider.imageUri!,
                        isUrl: true),
                  ],
                ],
              ),
            ),
            // 🔷 Botões de ação
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ),
                  if (onEdit != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onEdit!();
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Editar'),
                      ),
                    ),
                  ],
                  if (onDelete != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete!();
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('Deletar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔷 Constrói uma linha de detalhe
  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value, {
    bool isUrl = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        if (isUrl)
          GestureDetector(
            onTap: () {
              // Copia para clipboard (opcional)
            },
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(
            value,
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  /// 🔷 Placeholder para imagem não carregada
  Widget _buildPlaceholder(ThemeData theme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: theme.colorScheme.primary,
      ),
    );
  }

  /// 📅 Formata DateTime para exibição
  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
