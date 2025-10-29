import 'package:flutter/material.dart';

class PolicyViewerScreen extends StatefulWidget {
  const PolicyViewerScreen({super.key});

  @override
  State<PolicyViewerScreen> createState() => _PolicyViewerScreenState();
}

class _PolicyViewerScreenState extends State<PolicyViewerScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollAvailability);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_checkScrollAvailability);
    _scrollController.dispose();
    super.dispose();
  }

  void _checkScrollAvailability() {
    final pos = _scrollController.position;
    final current = pos.pixels;
    final maxScroll = pos.maxScrollExtent;

    final canUp = current > 0.0;
    final canDown = current < maxScroll;

    if (canUp != _canScrollUp || canDown != _canScrollDown) {
      setState(() {
        _canScrollUp = canUp;
        _canScrollDown = canDown;
      });
    }
  }

  Future<void> _scrollPageUp() async {
    final pos = _scrollController.position;
    final target = (pos.pixels - pos.viewportDimension).clamp(
      0.0,
      pos.maxScrollExtent,
    );
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollPageDown() async {
    final pos = _scrollController.position;
    final target = (pos.pixels + pos.viewportDimension).clamp(
      0.0,
      pos.maxScrollExtent,
    );
    await _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
        actions: const [], // regra: sem botões duplicados aqui
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            child: const Text('''
# Política de Privacidade

Este é um exemplo de texto longo para simular a política de privacidade.
Role para baixo e observe os botões de navegação surgirem.
(Adicione mais conteúdo aqui para testar.)
''', style: TextStyle(fontSize: 16)),
          ),

          // Botão para descer
          if (_canScrollDown)
            Positioned(
              right: 16,
              bottom: 88,
              child: FloatingActionButton.small(
                heroTag: 'scroll_down',
                tooltip: 'Mostrar conteúdo abaixo',
                onPressed: _scrollPageDown,
                child: const Icon(Icons.arrow_downward),
              ),
            ),

          // Botão para subir
          if (_canScrollUp)
            Positioned(
              right: 16,
              top: 8,
              child: FloatingActionButton.small(
                heroTag: 'scroll_up_overlay',
                tooltip: 'Mostrar conteúdo acima',
                onPressed: _scrollPageUp,
                child: const Icon(Icons.arrow_upward),
              ),
            ),

          // Botão fixo na base (não altere)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Marcar como Lido'),
            ),
          ),
        ],
      ),
    );
  }
}
