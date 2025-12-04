import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/datasources/providers_local_dao.dart';
import '../../domain/entities/provider.dart';
import '../../infrastructure/remote/supabase_providers_remote_datasource.dart';
import '../../infrastructure/repositories/providers_repository_impl.dart';
import '../dialogs/provider_details_dialog.dart';
import '../dialogs/provider_form_dialog.dart';
import '../widgets/provider_list_view.dart';

/// 📱 Página Principal de Providers
///
/// **Responsabilidades:**
/// 1. Gerenciar estado (providers list, loading, sync status)
/// 2. Carregar providers do cache (com auto-sync se vazio)
/// 3. Permitir CRUD (Create, Read, Update, Delete)
/// 4. Sincronizar com Supabase (pull-to-refresh)
/// 5. Mostrar UI feedback (loading, sync progress, messages)
///
/// **Fluxo didático:**
/// ```
/// initState()
///   ↓
/// _loadProviders()
///   ├─ Cache vazio? → _syncFromServer()
///   └─ Cache tem dados? → Mostrar lista
///   ↓
/// User actions → Create/Edit/Delete/Sync
///   ↓
/// Repository (com conversão Domain/DTO)
///   ↓
/// DAO (persiste DTOs)
///   ↓
/// UI atualiza
/// ```
///
/// **Padrão aplicado:**
/// - ✅ RefreshIndicator para pull-to-refresh
/// - ✅ AlwaysScrollableScrollPhysics para empty state
/// - ✅ LinearProgressIndicator durante sync
/// - ✅ Auto-sync quando cache vazio
/// - ✅ kDebugMode logging em pontos críticos
/// - ✅ if(mounted) antes de setState
/// - ✅ Conversão Domain/DTO na fronteira (Mapper)
///
/// **Exemplo de logs esperados:**
/// ```
/// [ProvidersPage] iniciando carregamento...
/// [ProvidersPage] cache vazio, sincronizando...
/// [ProvidersRepository] Iniciando sync com Supabase...
/// [ProvidersRepository] Buscados 42 providers remotos
/// [ProvidersPage] 42 providers sincronizados!
/// ```
class ProvidersPage extends StatefulWidget {
  const ProvidersPage({super.key});

  @override
  State<ProvidersPage> createState() => _ProvidersPageState();
}

class _ProvidersPageState extends State<ProvidersPage> {
  /// Lista de providers (DOMAIN ENTITIES, não DTOs!)
  List<Provider> _providers = [];

  /// Flag de carregamento inicial
  bool _isLoading = false;

  /// Flag de sincronização (mostra progress bar)
  bool _isSyncing = false;

  /// Repository instância
  late ProvidersRepositoryImpl _repository;

  /// DAO instância
  late ProvidersLocalDaoSharedPrefs _dao;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  /// 🔵 Inicializa repository e carrega dados
  Future<void> _initializeRepository() async {
    try {
      if (kDebugMode) {
        print('[ProvidersPage] Inicializando repository...');
      }

      // 🔵 PASSO 1: Criar DAO e inicializar
      _dao = ProvidersLocalDaoSharedPrefs();
      await _dao.init();

      // 🔵 PASSO 2: Criar Repository com dependências
      _repository = ProvidersRepositoryImpl(
        remoteApi: SupabaseProvidersRemoteDatasource(),
        localDao: _dao,
      );

      // 🔵 PASSO 3: Carregar providers (com auto-sync se cache vazio)
      await _loadProviders();
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersPage] ❌ Erro ao inicializar: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    }
  }

  /// 📥 Carrega providers (com auto-sync se vazio)
  ///
  /// **Fluxo:**
  /// 1. Mostrar loading
  /// 2. Carregar do cache
  /// 3. Se vazio → auto-sync com Supabase
  /// 4. Recarregar
  /// 5. Atualizar UI
  /// 📱 Carrega providers com sincronização bidirecional automática
  ///
  /// **MUDANÇA: Agora SEMPRE sincroniza (não apenas se vazio)**
  ///
  /// **NOVO FLUXO (Push-Then-Pull):**
  ///
  /// ```
  /// ┌──────────────────────────────────────────┐
  /// │ 1️⃣  Load Cache (rápido, sem bloqueio)    │
  /// │  └─ Mostra dados locais imediatamente    │
  /// └──────────┬───────────────────────────────┘
  ///            │
  /// ┌──────────▼───────────────────────────────┐
  /// │ 2️⃣  SEMPRE Sync (bidirecional)           │
  /// │  ├─ PUSH: enviar cache local → Supabase  │
  /// │  ├─ PULL: receber remoto → cache local   │
  /// │  └─ UI respira com LinearProgressIndicator
  /// └──────────┬───────────────────────────────┘
  ///            │
  /// ┌──────────▼───────────────────────────────┐
  /// │ 3️⃣  Reload Cache (dados atualizados)     │
  /// │  └─ Mostra resultados da sync            │
  /// └──────────────────────────────────────────┘
  /// ```
  ///
  /// **Diferenças da versão anterior:**
  /// - ❌ Antigo: Só sincronizava se cache vazio (passivo)
  /// - ✅ Novo: Sempre sincroniza (ativo, bidirecional)
  /// - ✅ Novo: Push envia mudanças locais
  /// - ✅ Novo: Pull recebe mudanças remotas
  ///
  /// **User Experience:**
  /// 1. Página abre → mostra dados locais (instantâneo)
  /// 2. LinearProgressIndicator aparece no topo
  /// 3. Sync ocorre em background (push + pull)
  /// 4. Dados atualizados aparecem
  /// 5. LinearProgressIndicator desaparece
  ///
  /// **Casos de teste:**
  /// ✅ Primeira abertura (cache vazio) → mostra placeholder, sync, carrega remoto
  /// ✅ Abertura posterior (cache com dados) → mostra cache, sync, atualiza
  /// ✅ Sem conexão → mostra cache, sync falha com erro, mostra snackbar
  /// ✅ Mudança offline → cache preservado, envia no próximo sync
  ///
  /// **Log esperado:**
  /// ```
  /// [ProvidersPage] iniciando carregamento...
  /// [ProvidersPage] carregados 3 do cache
  /// [ProvidersPage] iniciando auto-sync BIDIRECIONAL...
  /// [ProvidersRepository] Iniciando SYNC BIDIRECIONAL...
  /// [ProvidersRepository] PUSH: enviando 2 items locais
  /// [ProvidersRepository] PULL: buscando atualizações remotas
  /// [ProvidersRepository] Sync concluído: 5 total
  /// [ProvidersPage] sincronizados 5 providers!
  /// [ProvidersPage] UI atualizada com 5 providers
  /// ```
  Future<void> _loadProviders() async {
    try {
      if (kDebugMode) {
        print('[ProvidersPage] iniciando carregamento de providers...');
      }

      if (!mounted) return;
      setState(() => _isLoading = true);

      // 🔵 PASSO 1: Carregar do cache (rápido, sem esperar sync)
      var providers = await _repository.getAll();

      if (kDebugMode) {
        print('[ProvidersPage] carregados ${providers.length} providers do cache');
      }

      // 🔵 PASSO 2: MUDANÇA IMPORTANTE - SEMPRE sincronizar (não condicional)
      // Isso garante que:
      // - Local → Remoto: mudanças offline são enviadas (PUSH)
      // - Remoto → Local: mudanças de outros usuários são recebidas (PULL)
      if (kDebugMode) {
        print('[ProvidersPage] iniciando auto-sync BIDIRECIONAL (sempre, não condicional)...');
      }

      if (!mounted) return;
      setState(() => _isSyncing = true);

      try {
        final synced = await _repository.syncFromServer();

        if (kDebugMode) {
          print('[ProvidersPage] ✅ sincronizados $synced providers (PUSH + PULL)!');
        }

        // 🔵 PASSO 3: Recarregar após sync (dados atualizados)
        providers = await _repository.getAll();

        if (kDebugMode) {
          print('[ProvidersPage] recarregados ${providers.length} providers após sync');
        }
      } catch (syncError) {
        if (kDebugMode) {
          print('[ProvidersPage] ⚠️ erro ao sincronizar: $syncError');
        }
        // Continua com dados do cache mesmo com erro
        // (tipo push falhou, mas pull pode ter tido sucesso)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao sincronizar: $syncError')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSyncing = false);
        }
      }

      // 🔵 PASSO 4: Atualizar UI com dados finais
      if (mounted) {
        setState(() {
          _providers = providers;
          _isLoading = false;
        });

        if (kDebugMode) {
          print('[ProvidersPage] UI atualizada com ${providers.length} providers');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersPage] ❌ erro fatal ao carregar: $e');
      }
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar: $e')),
        );
      }
    }
  }

  /// 🔄 Pull-to-refresh manual (força sync)
  ///
  /// **Fluxo:**
  /// 1. Sincroniza com servidor (ignore cache)
  /// 2. Recarrega lista
  /// 3. Mostra resultado
  Future<void> _handleRefresh() async {
    try {
      if (kDebugMode) {
        print('[ProvidersPage] iniciando refresh manual...');
      }

      if (!mounted) return;
      setState(() => _isSyncing = true);

      try {
        // Força sync com timeout
        final synced = await _repository.syncFromServer().timeout(
              const Duration(seconds: 30),
              onTimeout: () => throw Exception('Sync timeout'),
            );

        if (kDebugMode) {
          print('[ProvidersPage] refresh: sincronizados $synced providers');
        }

        // Recarrega lista
        final providers = await _repository.getAll();

        if (mounted) {
          setState(() {
            _providers = providers;
            _isSyncing = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sincronizados $synced providers'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('[ProvidersPage] ❌ erro no refresh: $e');
        }

        if (mounted) {
          setState(() => _isSyncing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sincronizar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  /// ➕ Criar novo provider
  Future<void> _handleCreate() async {
    final newProvider = await showDialog<Provider>(
      context: context,
      builder: (context) => const ProviderFormDialog(),
    );

    if (newProvider != null) {
      try {
        if (kDebugMode) {
          print('[ProvidersPage] criando provider: ${newProvider.name}');
        }

        await _repository.create(newProvider);

        if (mounted) {
          setState(() {
            _providers.add(newProvider);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Provider criado com sucesso')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('[ProvidersPage] ❌ erro ao criar: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao criar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// ✏️ Editar provider
  Future<void> _handleEdit(Provider provider) async {
    final updated = await showDialog<Provider>(
      context: context,
      builder: (context) => ProviderFormDialog(initialValue: provider),
    );

    if (updated != null) {
      try {
        if (kDebugMode) {
          print('[ProvidersPage] atualizando provider: ${updated.id}');
        }

        await _repository.update(updated);

        if (mounted) {
          setState(() {
            final index = _providers.indexWhere((p) => p.id == updated.id);
            if (index >= 0) {
              _providers[index] = updated;
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Provider atualizado com sucesso')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('[ProvidersPage] ❌ erro ao editar: $e');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao editar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 🗑️ Deletar provider
  Future<void> _handleDelete(String providerId) async {
    try {
      if (kDebugMode) {
        print('[ProvidersPage] deletando provider: $providerId');
      }

      final deleted = await _repository.delete(providerId);

      if (deleted && mounted) {
        setState(() {
          _providers.removeWhere((p) => p.id == providerId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider deletado com sucesso')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('[ProvidersPage] ❌ erro ao deletar: $e');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao deletar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 👁️ Ver detalhes
  void _handleShowDetails(Provider provider) {
    showDialog(
      context: context,
      builder: (context) => ProviderDetailsDialog(
        provider: provider,
        onEdit: () => _handleEdit(provider),
        onDelete: () => _handleDelete(provider.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provedores'),
        centerTitle: true,
        actions: [
          // ➕ Botão adicionar
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _handleCreate,
            tooltip: 'Adicionar provider',
          ),
        ],
      ),
      body: Column(
        children: [
          // ⚠️ Progress bar de sync (topo)
          if (_isSyncing)
            const LinearProgressIndicator(
              minHeight: 4,
            ),

          // 📋 Conteúdo principal
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _providers.isEmpty
                      ? ListView(
                          // AlwaysScrollable para pull-to-refresh no empty state
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 80,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Nenhum provider',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Puxe para sincronizar dados',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _handleCreate,
                                      icon: const Icon(Icons.add),
                                      label: const Text('Criar provider'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ProvidersListView(
                          providers: _providers,
                          onEdit: _handleEdit,
                          onDelete: _handleDelete,
                          onTap: _handleShowDetails,
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
