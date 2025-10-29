import 'package:flutter/material.dart';
import '../Models/bus_route.dart';
import 'add_route_page.dart';

class RouteListPage extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const RouteListPage({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
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
          name: 'Casa → Campus',
          from: 'Casa',
          to: 'Campus',
          time: '07:00',
          stops: ['Ponto 1', 'Ponto 2'],
        ),
      );
    }
  }

  void _addRoute(BusRoute route) {
    setState(() => _routes.add(route));
  }

  void _editRoute(int index, BusRoute route) {
    setState(() => _routes[index] = route);
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF343437)
        : const Color.fromRGBO(40, 41, 136, 1);

    return Scaffold(
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
          ),
        ],
      ),
      body: _routes.isEmpty
          ? const Center(child: Text('Nenhuma rota cadastrada.'))
          : ListView.builder(
              itemCount: _routes.length,
              itemBuilder: (context, index) {
                final route = _routes[index];
                return Card(
                  color: highlightColor,
                  child: ListTile(
                    leading: Icon(Icons.directions_bus,
                        color: Theme.of(context).colorScheme.secondary),
                    title: Text(route.name,
                        style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      'De: ${route.from}  Para: ${route.to}\nHorário: ${route.time}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () async {
                        final edited = await Navigator.push<BusRoute>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddRoutePage(
                              initialRoute: route,
                              isEditing: true,
                            ),
                          ),
                        );
                        if (edited != null) _editRoute(index, edited);
                      },
                    ),
                  ),
                );
              },
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
      ),
    );
  }
}
