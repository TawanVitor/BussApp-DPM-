import 'package:flutter/material.dart';
import 'route_list_page.dart';

class OnboardingFlow extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  const OnboardingFlow({
    super.key,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int _page = 0;
  bool _termsAccepted = false;
  bool _lgpdAccepted = false;

  void _next() {
    if (_page < 3) {
      setState(() => _page++);
    }
  }

  void _acceptTerms(bool? value) {
    setState(() {
      _termsAccepted = value ?? false;
    });
  }

  void _acceptLGPD(bool? value) {
    setState(() {
      _lgpdAccepted = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingPage(
        title: 'Bem-vindo ao Buss!',
        description:
            'Registre e visualize suas rotas de ônibus facilmente. Ideal para estudantes que dependem de transporte público.',
        icon: Icons.directions_bus,
        color: Theme.of(context).colorScheme.primary,
        onNext: _next,
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
        pageIndex: 0,
        currentPage: _page,
        totalPages: 4,
      ),
      _OnboardingPage(
        title: 'Como funciona?',
        description:
            'Cadastre manualmente suas rotas, horários, trajetos e paradas. A localização é opcional e você pode adicionar quantas rotas quiser!',
        icon: Icons.route,
        color: Theme.of(context).colorScheme.secondary,
        onNext: _next,
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
        pageIndex: 1,
        currentPage: _page,
        totalPages: 4,
      ),
      _TermsOfUsePage(
        accepted: _termsAccepted,
        onAccept: _acceptTerms,
        onContinue: _termsAccepted ? _next : null,
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
      ),
      _LGPDPage(
        accepted: _lgpdAccepted,
        onAccept: _acceptLGPD,
        onContinue: _lgpdAccepted
            ? () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => RouteListPage(
                      onThemeToggle: widget.onThemeToggle,
                      themeMode: widget.themeMode,
                    ),
                  ),
                );
              }
            : null,
        onThemeToggle: widget.onThemeToggle,
        themeMode: widget.themeMode,
      ),
    ];

    return pages[_page];
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onNext;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;
  final int pageIndex;
  final int currentPage;
  final int totalPages;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onNext,
    required this.onThemeToggle,
    required this.themeMode,
    required this.pageIndex,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            tooltip: 'Trocar tema',
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 80, color: color),
              const SizedBox(height: 32),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(totalPages - 1, (index) {
                  final isActive = currentPage == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: isActive ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: onNext,
                child: const Text('Próximo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsOfUsePage extends StatefulWidget {
  final bool accepted;
  final ValueChanged<bool?> onAccept;
  final VoidCallback? onContinue;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const _TermsOfUsePage({
    required this.accepted,
    required this.onAccept,
    required this.onContinue,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  State<_TermsOfUsePage> createState() => _TermsOfUsePageState();
}

class _TermsOfUsePageState extends State<_TermsOfUsePage> {
  bool _hasReachedEnd = false;

  final String termsText = '''
Termos de Uso do Aplicativo Buss

1. Aceitação dos Termos  
Ao utilizar o aplicativo Buss, o usuário declara ter lido, compreendido e aceitado integralmente estes Termos de Uso. Caso não concorde com qualquer condição aqui descrita, o usuário não deverá utilizar o aplicativo.

2. Finalidade do Aplicativo  
O Buss tem como objetivo auxiliar estudantes e demais usuários de transporte público a registrar, organizar e visualizar suas rotas de ônibus, horários e paradas.  
O aplicativo não coleta dados pessoais sensíveis, sendo as informações cadastradas exclusivamente aquelas fornecidas voluntariamente pelo usuário.

3. Responsabilidade do Usuário  
O usuário é o único responsável pelas informações cadastradas, incluindo nomes de rotas, horários e locais.  
É proibido utilizar o aplicativo para armazenar ou divulgar conteúdo ofensivo, ilegal, difamatório ou que viole direitos de terceiros.

4. Privacidade e Proteção de Dados  
O Buss respeita a privacidade do usuário e segue as diretrizes da Lei Geral de Proteção de Dados (Lei nº 13.709/2018).  
Nenhum dado é compartilhado com terceiros. As informações permanecem armazenadas apenas localmente no dispositivo do usuário.

5. Atualizações e Modificações  
Os desenvolvedores poderão atualizar o aplicativo, modificar funcionalidades ou alterar estes Termos de Uso a qualquer momento, visando melhorias na experiência e segurança.  
Sempre que houver alterações significativas, o usuário será informado e poderá optar por continuar ou não utilizando o aplicativo.

6. Limitação de Responsabilidade  
O aplicativo é disponibilizado “como está”, sem garantias de funcionamento ininterrupto ou livre de falhas.  
Os desenvolvedores não se responsabilizam por perdas de dados, mau uso do aplicativo, ou danos decorrentes de seu uso indevido.

7. Contato  
Para dúvidas, sugestões ou solicitações relacionadas a estes Termos, o usuário pode entrar em contato pelo e-mail: suporte@bussapp.com.

Ao marcar a opção “Li e aceito os Termos de Uso”, o usuário confirma que leu, compreendeu e concorda com todas as condições apresentadas neste documento, bem como com a Política de Privacidade.
''';

  Future<void> _openFullTermsDialog() async {
    final ScrollController dialogScroll = ScrollController();
    bool dialogReachedEnd = false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            // adiciona listener ao controller (criado fora do builder)
            dialogScroll.addListener(() {
              if (!dialogScroll.hasClients) return;
              final max = dialogScroll.position.maxScrollExtent;
              final offset = dialogScroll.offset;
              final reached = max <= 0 || offset >= (max - 10);
              if (reached != dialogReachedEnd) {
                dialogReachedEnd = reached;
                setStateDialog(() {});
              }
            });

            // verifica após frame inicial se o conteúdo cabe inteiro
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!dialogScroll.hasClients) return;
              final max = dialogScroll.position.maxScrollExtent;
              if (max <= 0 && !dialogReachedEnd) {
                dialogReachedEnd = true;
                setStateDialog(() {});
              }
            });

            return AlertDialog(
              title: const Text('Termos de Uso'),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: SingleChildScrollView(
                  controller: dialogScroll,
                  child: Text(
                    termsText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Fechar'),
                ),
                TextButton(
                  onPressed: dialogReachedEnd
                      ? () => Navigator.of(context).pop(true)
                      : null,
                  child: const Text('Já li'),
                ),
              ],
            );
          },
        );
      },
    );

    // remove listener e dispose (seguro mesmo se dialogScroll não usado depois)
    try {
      dialogScroll.dispose();
    } catch (_) {}

    if (result == true) {
      setState(() {
        _hasReachedEnd = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você leu o Termos de Uso. Agora pode aceitar.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Termos de Uso'),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Antes de continuar, leia atentamente os Termos de Uso.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.article,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: GestureDetector(
                onTap: _openFullTermsDialog,
                child: Text(
                  'Termos de Uso',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              subtitle: const Text('Toque para ver o texto completo'),
              onTap: _openFullTermsDialog,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: widget.accepted,
                  onChanged: (value) {
                    if (_hasReachedEnd) {
                      widget.onAccept(value);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Abra e role até o fim do "teermos de uso" para poder aceitar',
                          ),
                        ),
                      );
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                Expanded(
                  child: Text(
                    _hasReachedEnd
                        ? 'Li e aceito os Termos de Uso'
                        : 'Abra "teermos de uso" e role até o fim para aceitar',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LGPDPage extends StatelessWidget {
  final bool accepted;
  final ValueChanged<bool?> onAccept;
  final VoidCallback? onContinue;
  final VoidCallback onThemeToggle;
  final ThemeMode themeMode;

  const _LGPDPage({
    required this.accepted,
    required this.onAccept,
    required this.onContinue,
    required this.onThemeToggle,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LGPD'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onThemeToggle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.privacy_tip,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            Text(
              'Termos de Privacidade (LGPD)',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  'Este aplicativo armazena apenas as rotas, horários e paradas que você cadastrar manualmente. Nenhum dado pessoal sensível é coletado ou compartilhado. '
                  'Ao continuar, você concorda com o uso das informações fornecidas para funcionamento do app, conforme a Lei Geral de Proteção de Dados (LGPD).',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: accepted,
                  onChanged: onAccept,
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const Expanded(
                  child: Text('Li e aceito os termos de privacidade'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
