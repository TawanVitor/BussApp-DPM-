# 🔐 Supabase Configuration Setup Guide

## 📋 Status Atual

✅ `.env` criado  
✅ `.gitignore` atualizado para proteger credenciais  
⏳ Aguardando Supabase API keys  

---

## 🚀 Próximos Passos

### PASSO 1️⃣ : Obtenha as Chaves do Supabase

1. Acesse [Supabase Dashboard](https://app.supabase.com/projects)
2. Selecione seu projeto
3. Vá para **Settings** → **API**
4. Copie:
   - **Project URL** (exemplo: `https://xyzabc.supabase.co`)
   - **Anon key** (chave pública para Flutter)
   - **Service role key** (chave de serviço, apenas backend)

### PASSO 2️⃣ : Preencha o Arquivo `.env`

Abra `BussApp-DPM-/.env` e preencha:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=seu_anon_key_aqui
SUPABASE_SERVICE_ROLE_KEY=seu_service_role_key_aqui
ENVIRONMENT=development
DEBUG_MODE=true
```

### PASSO 3️⃣ : Implemente o Carregamento no Flutter

Crie um arquivo de configuração em `lib/core/config/env_config.dart`:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseServiceRoleKey => 
    dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  static bool get debugMode => 
    dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
}
```

### PASSO 4️⃣ : Configure no `pubspec.yaml`

Adicione a dependência:

```yaml
dev_dependencies:
  flutter_dotenv: ^5.1.0

flutter:
  assets:
    - .env
```

### PASSO 5️⃣ : Inicialize no `main.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env");
  
  runApp(const BussApp());
}
```

### PASSO 6️⃣ : Use nas Datasources

Em `supabase_providers_remote_datasource.dart`:

```dart
import 'package:flutter_supabase/core/config/env_config.dart';

class SupabaseProvidersRemoteDatasource implements IProvidersRemoteApi {
  late final SupabaseClient supabase;
  
  SupabaseProvidersRemoteDatasource() {
    supabase = SupabaseClient(
      EnvConfig.supabaseUrl,
      EnvConfig.supabaseAnonKey,
    );
  }
  
  // Usar em todos os métodos agora...
}
```

---

## ⚠️ SEGURANÇA - IMPORTANTE!

### ✅ FAZER

- ✅ Adicionar `.env` ao `.gitignore` (já feito)
- ✅ Nunca fazer commit do `.env`
- ✅ Usar `SUPABASE_ANON_KEY` no frontend
- ✅ Usar `SUPABASE_SERVICE_ROLE_KEY` apenas no backend
- ✅ Rotacionar chaves periodicamente
- ✅ Usar RLS (Row-Level Security) no Supabase

### ❌ NÃO FAZER

- ❌ Hardcodear chaves no código
- ❌ Commitar `.env` no git
- ❌ Usar service role key no frontend
- ❌ Compartilhar chaves publicamente
- ❌ Usar mesma chave em dev e production

---

## 🔄 Fluxo de Carregamento

```
main.dart
   ↓
dotenv.load(".env")
   ↓
EnvConfig (singleton)
   ↓
SupabaseProvidersRemoteDatasource
   ↓
SupabaseClient (inicializado)
   ↓
API Calls (PUSH/PULL)
```

---

## 🧪 Testando a Configuração

```dart
// Em main.dart ou em um teste:
void testEnvConfig() {
  print('URL: ${EnvConfig.supabaseUrl}');
  print('Anon Key: ${EnvConfig.supabaseAnonKey.substring(0, 20)}...');
  print('Environment: ${EnvConfig.environment}');
  print('Debug: ${EnvConfig.debugMode}');
}
```

---

## 📝 Estrutura Final do Projeto

```
BussApp-DPM-/
├── .env                          ← 🔐 Credenciais (NÃO commitar)
├── .gitignore                    ← ✅ Contém .env
├── pubspec.yaml                  ← ✅ flutter_dotenv
├── lib/
│   ├── main.dart                 ← dotenv.load()
│   ├── core/
│   │   └── config/
│   │       └── env_config.dart   ← EnvConfig classe
│   └── features/
│       └── providers/
│           └── infrastructure/
│               └── remote/
│                   └── supabase_providers_remote_datasource.dart ← usa EnvConfig
```

---

## 🔧 Variáveis Disponíveis

| Variável | Tipo | Descrição | Exemplo |
|----------|------|-----------|---------|
| `SUPABASE_URL` | String | URL do projeto | `https://xyzabc.supabase.co` |
| `SUPABASE_ANON_KEY` | String | Chave pública (frontend) | `eyJhbGc...` |
| `SUPABASE_SERVICE_ROLE_KEY` | String | Chave serviço (backend) | `eyJhbGc...` |
| `ENVIRONMENT` | String | dev/staging/prod | `development` |
| `DEBUG_MODE` | Boolean | Ativa logs | `true` |

---

## 💡 Dicas

1. **Múltiplos Ambientes:**
   ```
   .env                  ← development
   .env.staging          ← staging
   .env.production       ← production
   ```

2. **Local Testing:**
   ```dart
   // No teste, carregue do arquivo específico:
   await dotenv.load(fileName: ".env.test");
   ```

3. **CI/CD Integration:**
   ```yaml
   # No GitHub Actions, adicione secrets:
   env:
     SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
     SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
   ```

---

## ✅ Checklist de Setup

- [ ] `.env` criado com valores preenchidos
- [ ] `.gitignore` contém `.env`
- [ ] `flutter_dotenv` adicionado ao `pubspec.yaml`
- [ ] `lib/core/config/env_config.dart` criado
- [ ] `main.dart` chama `dotenv.load()`
- [ ] `supabase_providers_remote_datasource.dart` usa `EnvConfig`
- [ ] Credenciais testadas (verificar logs)
- [ ] `.env` não foi commitado no git

---

## 🆘 Troubleshooting

### Erro: "Missing .env file"
**Solução:** Verifique se `.env` está na raiz do projeto

### Erro: "EnvConfig values are empty"
**Solução:** Verifique se `dotenv.load()` foi chamado antes de usar valores

### Erro: "Key not found in .env"
**Solução:** Verifique se a chave está escrita corretamente (case-sensitive)

### Erro: "Unhandled Exception: SupabaseClient is null"
**Solução:** Verifique se `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão preenchidos

---

## 📚 Referências

- [Flutter Dotenv Docs](https://pub.dev/packages/flutter_dotenv)
- [Supabase Flutter Guide](https://supabase.com/docs/reference/flutter/introduction)
- [Supabase API Keys](https://supabase.com/docs/guides/api/api-keys)
- [Environment Variables Best Practices](https://12factor.net/config)

---

**Próximo Passo:** Passe as Supabase API keys para preencher o `.env` 🔑
