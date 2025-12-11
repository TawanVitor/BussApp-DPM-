import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bussv1/features/routes/domain/entities/bus_route.dart';
import 'package:bussv1/features/routes/presentation/pages/add_route_page.dart';
import 'package:bussv1/features/settings/presentation/pages/settings_page.dart';
import 'package:bussv1/features/settings/domain/entities/user_settings.dart';
import 'package:bussv1/features/bus_schedules/presentation/pages/bus_schedules_list_page.dart';

class RouteListPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final UserSettings settings;
  final Function(UserSettings) onSettingsChanged;

  const RouteListPage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<RouteListPage> createState() => _RouteListPageState();
}

class _RouteListPageState extends State<RouteListPage> {
  final List<BusRoute> _routes = [];

  @override
  void initState() {
    super.initState();
    if (_routes.isEmpty) {
      _routes.add(
        BusRoute(
          id: '1',
          name: 'Casa → Campus',
          from: 'Casa',
          to: 'Campus',
          time: '07:00',
          stops: ['Ponto 1', 'Ponto 2'],
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  void _addRoute(BusRoute route) => setState(() => _routes.add(route));

  void _editRoute(int index, BusRoute route) =>
      setState(() => _routes[index] = route);

  void _deleteRoute(int index) => setState(() => _routes.removeAt(index));

  void _showDeleteConfirmation(BuildContext context, int index, String routeName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Rota'),
        content: Text('Tem certeza que deseja deletar a rota "$routeName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              _deleteRoute(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Rota deletada com sucesso'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  /// Constrói a imagem de perfil com fallback
  Widget _buildProfileImage() {
    final photoPath = widget.settings.photoPath;
    
    // Se não tem foto, mostra ícone padrão
    if (photoPath == null || photoPath.isEmpty) {
      return CircleAvatar(
        backgroundColor: Colors.white.withAlpha(51),
        child: Icon(
          Icons.person,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
      );
    }

    // Verifica se arquivo existe
    final file = File(photoPath);
    if (!file.existsSync()) {
      return CircleAvatar(
        backgroundColor: Colors.white.withAlpha(51),
        child: Icon(
          Icons.broken_image,
          color: Colors.red[300],
          size: 28,
        ),
      );
    }

    // Mostra a imagem se arquivo existe
    return CircleAvatar(
      backgroundImage: FileImage(file),
      backgroundColor: Colors.white.withAlpha(51),
      onBackgroundImageError: (exception, stackTrace) {
        debugPrint('Erro ao carregar imagem de perfil: $exception');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: _buildProfileImage(),
              accountName: Text(
                widget.settings.name.isNotEmpty 
                    ? widget.settings.name 
                    : 'Usuário',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              accountEmail: Text(
                'Configurações de Perfil',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(180),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              onDetailsPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      settings: widget.settings,
                      onSettingsChanged: widget.onSettingsChanged,
                      onThemeToggle: widget.onThemeToggle,
                      themeMode: widget.themeMode,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurações'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      settings: widget.settings,
                      onSettingsChanged: widget.onSettingsChanged,
                      onThemeToggle: widget.onThemeToggle,
                      themeMode: widget.themeMode,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Horários de Ônibus'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusSchedulesListPage(
                      onThemeToggle: widget.onThemeToggle,
                      themeMode: widget.themeMode,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Minhas Rotas'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: widget.onThemeToggle,
            tooltip: 'Trocar tema',
          ),
        ],
      ),
      body: _routes.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_bus,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma rota cadastrada',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Toque o botão + para adicionar uma rota',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Total: ${_routes.length} rota${_routes.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _routes.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      return _RouteCard(
                        route: route,
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddRoutePage(
                                initialRoute: route,
                                isEditing: true,
                              ),
                            ),
                          ).then((edited) {
                            if (edited != null) {
                              _editRoute(index, edited);
                            }
                          });
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, index, route.name);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newRoute = await Navigator.push<BusRoute>(
            context,
            MaterialPageRoute(builder: (context) => AddRoutePage()),
          );
          if (newRoute != null) _addRoute(newRoute);
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar rota',
      ),
    );
  }
}

/// Card visual para exibir rota com informações de forma elegante
class _RouteCard extends StatelessWidget {
  final BusRoute route;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RouteCard({
    required this.route,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== Header: Nome da Rota ==========
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.directions_bus,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        route.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${route.from} → ${route.to}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: onEdit,
                  tooltip: 'Editar rota',
                ),
              ],
            ),
            
            const Divider(height: 20),
            
            // ========== Horário ==========
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Partida: ${route.time}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            
            if (route.stops.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${route.stops.length} paradas',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // ========== Ações ==========
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(route.name),
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DetailRow(label: 'Origem', value: route.from),
                              _DetailRow(label: 'Destino', value: route.to),
                              _DetailRow(label: 'Horário', value: route.time),
                              if (route.stops.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Paradas (${route.stops.length}):',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...route.stops.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(left: 8, bottom: 4),
                                  child: Text('${e.key + 1}. ${e.value}'),
                                )),
                              ],
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Fechar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Detalhes'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Deletar'),
                  onPressed: onDelete,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para exibir detalhe (linha com label e valor)
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}