
# Buss App - Documentação de Features

## 📋 Visão Geral

O **Buss** é um aplicativo Flutter desenvolvido para auxiliar estudantes e usuários de transporte público a gerenciar suas rotas de ônibus. O aplicativo oferece cadastro manual de rotas, horários, trajetos e paradas de forma simples e intuitiva.

---

## 🎯 Features Principais

### 1. **Onboarding Flow**
Sistema de introdução ao aplicativo com múltiplas telas informativas.

#### Componentes:
- **Tela de Boas-vindas**: Apresenta o aplicativo e sua proposta
- **Tela "Como Funciona"**: Explica as funcionalidades principais
- **Tela de Termos de Uso**: Exibe os termos completos com scroll obrigatório
- **Tela LGPD**: Apresenta a política de privacidade

#### Características:
- Indicadores de progresso visuais
- Scroll obrigatório nos termos antes de aceitar
- Validação de aceitação dos termos
- Alternância de tema disponível em todas as telas
- Navegação sequencial com botão "Próximo"

#### Arquivos:
- `onboarding_flow.dart`
- `policy_viewer_screen.dart`

---

### 2. **Gerenciamento de Rotas**

Sistema completo para criar, visualizar, editar e organizar rotas de ônibus.

#### Funcionalidades:

**Listagem de Rotas (`RouteListPage`)**
- Visualização em cards coloridos
- Informações exibidas: nome, origem, destino e horário
- Rota padrão pré-cadastrada ("Casa → Campus")
- Cards com cores diferentes para tema claro/escuro
- Ícone de ônibus temático

**Adicionar/Editar Rota (`AddRoutePage`)**
- Formulário com validação de campos obrigatórios
- Campos disponíveis:
  - Nome da rota
  - Origem
  - Destino
  - Horário
- Preservação de paradas ao editar
- Modo de edição vs. criação

**Modelo de Dados (`BusRoute`)**
- Serialização JSON para persistência
- Campos: name, from, to, time, stops
- Lista de paradas (stops) configurável

#### Arquivos:
- `route_list_page.dart`
- `add_route_page.dart`
- `bus_route.dart`

---

### 3. **Sistema de Configurações**

Painel completo para personalização do aplicativo e perfil do usuário.

#### Funcionalidades:

**Perfil do Usuário**
- Foto de perfil personalizável via galeria
- Nome editável
- Persistência automática de alterações
- Visualização no drawer lateral

**Acessibilidade**
- Ajuste de tamanho do texto (80% a 140%)
- Modo de alto contraste
- Slider com divisões para tamanho de texto
- Switches para opções booleanas

**Gerenciamento de Tema**
- Alternância entre tema claro e escuro
- Ícone dinâmico que reflete o tema atual
- Disponível em toda a aplicação

**Visualização de Políticas**
- Acesso aos Termos de Uso completos
- Interface de leitura otimizada
- Scroll suave para textos longos

#### Arquivos:
- `settings_page.dart`
- `accessibility_page.dart`
- `policy_viewer_screen.dart`
- `user_settings.dart`

---

### 4. **Sistema de Temas**

Implementação de temas claro e escuro com cores personalizadas.

#### Paleta de Cores:

**Cores Principais:**
- Primary: `#4338CA` (Índigo)
- Secondary: `#84CC16` (Verde-limão)
- Background Light: Branco
- Background Dark: `#121212`

**Aplicação:**
- AppBar com cor primária
- FAB com cor secundária
- Cards com cores adaptativas
- Ícones temáticos em toda UI

#### Características:
- Suporte a ThemeMode.system, light e dark
- Transições suaves entre temas
- Cores consistentes em todos os componentes
- Alto contraste disponível nas configurações

#### Arquivos:
- `app_theme.dart`

---

### 5. **Persistência de Dados**

Sistema de armazenamento local usando SharedPreferences.

#### Dados Armazenados:

**UserSettings:**
- Nome do usuário
- Caminho da foto de perfil
- Preferência de tema escuro
- Tamanho do texto
- Uso de alto contraste

#### Características:
- Serialização/deserialização JSON
- Carregamento assíncrono na inicialização
- Salvamento automático ao modificar configurações
- Tratamento de erros com valores padrão
- Sem compartilhamento de dados com servidores externos

#### Arquivos:
- `user_settings.dart`

---

### 6. **Navegação e UI/UX**

Sistema de navegação intuitivo com drawer lateral.

#### Componentes:

**Drawer Lateral:**
- Cabeçalho com foto e nome do usuário
- Acesso rápido às configurações
- Design consistente com o tema

**AppBar:**
- Título contextual por tela
- Botão de alternância de tema
- Cores adaptativas

**FloatingActionButton:**
- Ação de adicionar nova rota
- Cor secundária destacada
- Tooltip descritivo

**Cards de Rota:**
- Layout informativo e limpo
- Botão de edição integrado
- Cores diferenciadas por tema

---

## 🔒 Conformidade Legal

### LGPD (Lei Geral de Proteção de Dados)

O aplicativo está em conformidade com a LGPD através de:

1. **Transparência**: Termos claros sobre coleta e uso de dados
2. **Consentimento**: Aceitação explícita necessária para uso
3. **Armazenamento Local**: Dados salvos apenas no dispositivo
4. **Sem Compartilhamento**: Nenhum dado é enviado a terceiros
5. **Controle do Usuário**: Possibilidade de apagar dados a qualquer momento

### Termos de Uso

Documento completo abordando:
- Descrição do serviço
- Uso adequado do aplicativo
- Privacidade e proteção de dados
- Responsabilidades (usuário e desenvolvedor)
- Limitações de responsabilidade
- Atualizações e modificações
- Suporte e contato

---

## 📱 Fluxo da Aplicação

```
Inicialização do App
    ↓
Carregamento das Configurações Salvas
    ↓
Onboarding Flow
    ↓ (Tela 1) Boas-vindas
    ↓ (Tela 2) Como Funciona
    ↓ (Tela 3) Termos de Uso → [Scroll obrigatório até o fim]
    ↓ (Tela 4) LGPD
    ↓
Tela Principal (Lista de Rotas)
    ├─→ Adicionar Nova Rota
    ├─→ Editar Rota Existente
    ├─→ Drawer (Menu Lateral)
    │       └─→ Configurações
    │               ├─→ Editar Perfil
    │               ├─→ Acessibilidade
    │               ├─→ Alternar Tema
    │               └─→ Ver Termos de Uso
    └─→ Alternar Tema (AppBar)
```

---

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework principal
- **Dart**: Linguagem de programação
- **SharedPreferences**: Persistência local
- **ImagePicker**: Seleção de foto de perfil
- **Material Design**: Sistema de design

---

## 📦 Estrutura de Pastas

```
lib/
├── core/
│   ├── Features/
│   │   ├── Onboarding/
│   │   │   └── pages/
│   │   │       ├── onboarding_flow.dart
│   │   │       └── policy_viewer_screen.dart
│   │   └── Settings/
│   │       └── pages/
│   │           ├── settings_page.dart
│   │           └── accessibility_page.dart
│   ├── Routes/
│   │   ├── Models/
│   │   │   └── bus_route.dart
│   │   └── Pages/
│   │       ├── route_list_page.dart
│   │       └── add_route_page.dart
│   ├── Models/
│   │   └── user_settings.dart
│   └── theme/
│       └── app_theme.dart
└── main.dart
```

---

## 🎨 Características de Design

### Responsividade
- Layout adaptável a diferentes tamanhos de tela
- Scroll para conteúdos extensos
- SafeArea para respeitar notches e barras do sistema

### Acessibilidade
- Tamanho de texto ajustável
- Alto contraste opcional
- Labels e tooltips descritivos
- Validação visual de formulários

### Feedback Visual
- SnackBars para ações concluídas
- Indicadores de progresso no onboarding
- Estados visuais para botões desabilitados
- Animações suaves de transição

---

## 💡 Melhorias Futuras Possíveis

1. Persistência das rotas (atualmente apenas em memória)
2. Sistema de notificações para horários de rotas
3. Mapa interativo com visualização de trajetos
4. Compartilhamento de rotas entre usuários
5. Integração com APIs de transporte público
6. Backup em nuvem opcional
7. Widget para tela inicial do dispositivo
8. Histórico de rotas utilizadas
9. Favoritos e organização por categorias
10. Modo offline completo

---

## 📄 Licença e Contato

**Suporte**: suporte@bussapp.com

**Uso**: Pessoal e não comercial

**Dados**: Armazenamento local apenas, sem compartilhamento externo