import 'package:bussv1/core/Routes/Pages/route_list_page.dart';
import 'package:flutter/material.dart';


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

// As classes auxiliares _OnboardingPage, _TermsOfUsePage, _LGPDPage
// permanecem aqui para manter a coesão do Onboarding
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

. Descrição do Serviço
O Buss é um aplicativo móvel desenvolvido para auxiliar estudantes e usuários de transporte público a gerenciar suas rotas de ônibus. O aplicativo permite:
- Cadastrar rotas personalizadas de ônibus
- Registrar horários de partida e chegada
- Salvar pontos de parada
- Organizar trajetos frequentes
- Personalizar nomes e descrições das rotas

2. Uso do Aplicativo
2.1. O aplicativo é destinado ao uso pessoal e não comercial.
2.2. Todas as informações cadastradas são armazenadas apenas localmente no dispositivo do usuário.
2.3. O usuário é responsável pela precisão dos dados inseridos.
2.4. O aplicativo não realiza rastreamento em tempo real ou fornece dados em tempo real do transporte público.

3. Privacidade e Proteção de Dados (LGPD)
Em conformidade com a Lei Geral de Proteção de Dados (Lei nº 13.709/2018):

3.1. Coleta de Dados
- O aplicativo não coleta dados pessoais sensíveis
- Todas as informações são fornecidas voluntariamente pelo usuário
- Os dados são armazenados exclusivamente no dispositivo do usuário
- Não há compartilhamento de dados com terceiros

3.2. Armazenamento
- Dados são salvos localmente no dispositivo
- Não há sincronização com servidores externos
- O usuário pode apagar seus dados a qualquer momento
- Não há backup automático das informações

3.3. Permissões do Aplicativo
O aplicativo solicita apenas as permissões essenciais para seu funcionamento:
- Armazenamento: para salvar as rotas cadastradas
- Tema do sistema: para ajustar a aparência do aplicativo

4. Responsabilidades
4.1. Do Usuário
- Fornecer informações precisas e atualizadas
- Utilizar o aplicativo de forma adequada e legal
- Manter a segurança do seu dispositivo
- Fazer backup dos dados importantes, se desejar

4.2. Do Desenvolvedor
- Manter o funcionamento básico do aplicativo
- Corrigir bugs e problemas técnicos
- Atualizar o aplicativo conforme necessário
- Respeitar a privacidade do usuário

5. Limitações de Responsabilidade
5.1. O aplicativo é fornecido "como está", sem garantias de:
- Precisão dos horários de ônibus
- Disponibilidade ininterrupta
- Compatibilidade com todos os dispositivos
- Backup ou recuperação de dados perdidos

5.2. O desenvolvedor não se responsabiliza por:
- Atrasos ou alterações nas rotas de ônibus
- Perdas de dados por problemas no dispositivo
- Uso inadequado do aplicativo
- Decisões tomadas com base nas informações registradas

6. Atualizações e Modificações
6.1. O desenvolvedor pode:
- Atualizar o aplicativo periodicamente
- Modificar funcionalidades existentes
- Adicionar ou remover recursos
- Alterar estes termos de uso

6.2. O usuário será notificado sobre:
- Mudanças significativas no aplicativo
- Alterações nos termos de uso
- Novas funcionalidades importantes

## 7. Suporte e Contato
Para suporte, dúvidas ou sugestões:
- Email: suporte@bussapp.com
- Relate problemas através do menu "Sobre" do aplicativo

8. Encerramento de Uso
8.1. O usuário pode:
- Desinstalar o aplicativo a qualquer momento
- Apagar todos os dados salvos localmente
- Cancelar seu uso sem aviso prévio

9. Aceitação dos Termos
Ao utilizar o Buss, o usuário declara que:
- Leu e compreendeu estes termos
- Concorda com todas as condições estabelecidas
- Aceita a política de privacidade
- Está ciente das limitações do aplicativo

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
                            'Abra e role até o fim do "Termos de Uso" para poder aceitar',
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
                        : 'Abra "Termos de Uso" e role até o fim para aceitar',
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