import 'package:flutter/material.dart';

import '../../domain/entities/provider.dart';
import 'provider_list_item.dart';

/// 📋 Widget que exibe a lista de providers
///
/// **Responsabilidade:** Apenas apresentar uma lista de Domain Entities (Provider)
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Este widget recebe List<Provider> (não ProviderModel!)
/// - Não faz nenhuma conversão ou persistência
/// - Apenas delega cada item para ProviderListItem
/// - Callbacks de ação (edit, delete) são passados para a parent page
///
/// **Padrão:**
/// ```dart
/// ProvidersListView(
///   providers: providers,  // List<Provider>
///   onEdit: (provider) => _handleEdit(provider),
///   onDelete: (providerId) => _handleDelete(providerId),
///   onTap: (provider) => _showDetails(provider),
/// )
/// ```
class ProvidersListView extends StatelessWidget {
  /// Lista de providers a exibir (entidades de domínio)
  final List<Provider> providers;

  /// Callback quando usuário edita um provider
  final Function(Provider) onEdit;

  /// Callback quando usuário quer deletar um provider
  final Function(String) onDelete;

  /// Callback quando usuário toca um provider
  final Function(Provider)? onTap;

  /// Construtor
  const ProvidersListView({
    required this.providers,
    required this.onEdit,
    required this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ⚠️ IMPORTANTE: AlwaysScrollableScrollPhysics permite pull-to-refresh
      // mesmo com poucos items na lista
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: providers.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final provider = providers[index];

        return ProviderListItem(
          provider: provider,  // ← Passa Provider (domain entity), não DTO!
          onEdit: () => onEdit(provider),
          onDelete: () => onDelete(provider.id),
          onTap: () => onTap?.call(provider),
        );
      },
    );
  }
}
