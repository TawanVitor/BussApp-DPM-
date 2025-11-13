# 🚌 Buss - Gerenciador de Rotas de Ônibus

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)

**Um aplicativo intuitivo para gerenciar suas rotas de transporte público**

[Sobre](#-sobre) • [Features](#-features) • [Instalação](#-instalação) • [Como Usar](#-como-usar) • [Screenshots](#-screenshots) • [Tecnologias](#-tecnologias)

</div>

---

## 📖 Sobre

O **Buss** é um aplicativo mobile desenvolvido em Flutter que auxilia estudantes e usuários de transporte público a organizarem suas rotas de ônibus. Com uma interface limpa e intuitiva, você pode cadastrar manualmente suas rotas favoritas, horários, pontos de parada e trajetos, tudo armazenado de forma segura no seu dispositivo.

### 🎯 Objetivo

Facilitar o dia a dia de quem depende do transporte público, oferecendo uma ferramenta simples para registrar e consultar informações importantes sobre rotas de ônibus.

### 👥 Público-Alvo

- Estudantes universitários
- Trabalhadores que usam transporte público
- Qualquer pessoa que precise organizar rotas de ônibus

---

## ✨ Features

### 🔐 Onboarding Completo
- ✅ Introdução interativa ao aplicativo
- ✅ Termos de Uso com scroll obrigatório
- ✅ Política de Privacidade (LGPD)
- ✅ Validação de aceite dos termos

### 🚍 Gerenciamento de Rotas
- ➕ Adicionar novas rotas personalizadas
- ✏️ Editar rotas existentes
- 📍 Cadastrar origem, destino e horários
- 🛑 Registrar pontos de parada
- 📋 Visualizar todas as rotas em cards organizados

### ⚙️ Configurações Personalizáveis
- 👤 Perfil com foto e nome editáveis
- 🌓 Alternância entre tema claro e escuro
- ♿ Ajuste de tamanho de texto (80% - 140%)
- 🎨 Modo de alto contraste
- 📄 Acesso aos Termos de Uso e Políticas

### 🔒 Privacidade e Segurança
- 🏠 Dados armazenados apenas localmente
- 🚫 Sem compartilhamento com terceiros
- ✅ Conformidade com LGPD
- 🗑️ Controle total sobre seus dados

---

## 📥 Instalação

### Pré-requisitos

- Flutter SDK (versão 3.0 ou superior)
- Dart SDK (versão 2.17 ou superior)
- Android Studio / Xcode (para emuladores)
- Git

### Passos

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/buss-app.git
cd buss-app
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

### Dependências Principais

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  image_picker: ^1.0.7
```

---

## 📱 Como Usar

### 1️⃣ Primeiro Acesso

1. Abra o aplicativo
2. Navegue pelas telas de boas-vindas
3. Leia e aceite os Termos de Uso
4. Aceite a Política de Privacidade (LGPD)

### 2️⃣ Adicionando uma Rota

1. Na tela principal, toque no botão **+** (flutuante)
2. Preencha os campos:
   - Nome da rota (ex: "Casa → Faculdade")
   - Origem
   - Destino
   - Horário
3. Toque em **Adicionar**

### 3️⃣ Editando uma Rota

1. Toque no ícone de **edição** (✏️) no card da rota
2. Modifique os campos desejados
3. Toque em **Salvar**

### 4️⃣ Personalizando o App

1. Abra o menu lateral (☰)
2. Toque em **Configurações**
3. Personalize:
   - Seu perfil (foto e nome)
   - Tema (claro/escuro)
   - Acessibilidade (tamanho do texto e contraste)


---

## 🛠️ Tecnologias

### Framework e Linguagem
- **Flutter** - Framework UI multiplataforma
- **Dart** - Linguagem de programação

### Pacotes Utilizados
- **shared_preferences** - Persistência de dados local
- **image_picker** - Seleção de imagens da galeria
- **Material Design** - Sistema de design

### Arquitetura
- **Stateful Widgets** - Gerenciamento de estado
- **MVC Pattern** - Separação de responsabilidades
- **Clean Architecture** - Organização modular

---

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                          # Ponto de entrada
├── core/
│   ├── Features/
│   │   ├── Onboarding/               # Fluxo de introdução
│   │   │   └── pages/
│   │   │       ├── onboarding_flow.dart
│   │   │       └── policy_viewer_screen.dart
│   │   └── Settings/                 # Configurações
│   │       └── pages/
│   │           ├── settings_page.dart
│   │           └── accessibility_page.dart
│   ├── Routes/                       # Gerenciamento de rotas
│   │   ├── Models/
│   │   │   └── bus_route.dart
│   │   └── Pages/
│   │       ├── route_list_page.dart
│   │       └── add_route_page.dart
│   ├── Models/                       # Modelos de dados
│   │   └── user_settings.dart
│   └── theme/                        # Temas e cores
│       └── app_theme.dart
```

---

## 🎨 Paleta de Cores

| Cor | Hex | Uso |
|-----|-----|-----|
| **Primary** | `#4338CA` | AppBar, elementos principais |
| **Secondary** | `#84CC16` | FAB, ícones de destaque |
| **Background Light** | `#FFFFFF` | Fundo tema claro |
| **Background Dark** | `#121212` | Fundo tema escuro |

---

## 🔐 Privacidade e Segurança

### Conformidade com LGPD

O Buss respeita integralmente a Lei Geral de Proteção de Dados (Lei nº 13.709/2018):

✅ **Transparência**: Todos os termos são apresentados claramente  
✅ **Consentimento**: Aceitação explícita necessária  
✅ **Minimização**: Coletamos apenas dados essenciais  
✅ **Segurança**: Dados armazenados apenas localmente  
✅ **Controle**: Você pode apagar seus dados a qualquer momento  

### O que Coletamos

- ✍️ Nome do usuário (opcional)
- 📷 Foto de perfil (opcional)
- 🚌 Rotas cadastradas manualmente
- ⚙️ Preferências de configuração

### O que NÃO Coletamos

- ❌ Localização em tempo real
- ❌ Dados de navegação
- ❌ Informações sensíveis
- ❌ Contatos ou arquivos do dispositivo

---

## 🚀 Roadmap

### Em Desenvolvimento
- [ ] Persistência de rotas (SharedPreferences)
- [ ] Sistema de notificações

### Planejado
- [ ] Widget para tela inicial
- [ ] Modo offline completo
- [ ] Exportar/Importar rotas
- [ ] Temas personalizáveis
- [ ] Integração com APIs de transporte público
- [ ] Mapa interativo de trajetos
- [ ] Histórico de viagens

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/NovaFeature`)
5. Abra um Pull Request

### Diretrizes

- Mantenha o código limpo e comentado
- Siga o padrão de código Dart/Flutter
- Teste suas alterações antes de enviar
- Atualize a documentação quando necessário

---

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

## 👨‍💻 Autor

Desenvolvido com ❤️ para facilitar o uso do transporte público.

---

## 📞 Suporte

Tem dúvidas ou sugestões? Entre em contato!

📧 Email: suporte@bussapp.com  
🐛 Issues: [GitHub Issues](https://github.com/seu-usuario/buss-app/issues)

---

## ⭐ Agradecimentos

- Flutter Community
- Material Design Guidelines
- Todos os contribuidores do projeto

---

<div align="center">

**Se este projeto foi útil para você, considere dar uma ⭐!**

Made with Flutter 💙

</div>
