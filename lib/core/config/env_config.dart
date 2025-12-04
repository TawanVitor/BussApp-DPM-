/// 🔐 Configuração de Ambiente - Variáveis do Supabase
///
/// **PROPÓSITO:**
/// Carrega e fornece acesso centralizado às variáveis de ambiente
/// definidas no arquivo `.env`
///
/// **FLUXO:**
/// ```
/// .env (arquivo raiz)
///   ↓
/// flutter_dotenv.load()
///   ↓
/// EnvConfig.supabaseUrl (acesso)
/// EnvConfig.supabaseAnonKey (acesso)
/// EnvConfig.environment (acesso)
/// ```
///
/// **SEGURANÇA:**
/// ⚠️ Nunca adicione valores hardcoded aqui
/// ⚠️ Sempre use `.env` para configurações sensíveis
/// ⚠️ Adicione `.env` ao `.gitignore` (já feito)
///
/// **CHECKLIST:**
/// ✅ Usar getter para acesso readonly
/// ✅ Retornar valor padrão se não encontrar variável
/// ✅ Registrar no console se em modo debug
/// ✅ Validar valores ao iniciar app

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 🔑 Configurações de Ambiente
///
/// Acesso centralizado às variáveis de ambiente carregadas do `.env`
///
/// **Exemplo de uso:**
/// ```dart
/// // Em main.dart:
/// print(EnvConfig.supabaseUrl);        // https://...
/// print(EnvConfig.supabaseAnonKey);    // sb_publishable_...
/// print(EnvConfig.environment);        // development
/// print(EnvConfig.debugMode);          // true
/// ```
class EnvConfig {
  /// 🌐 URL do Projeto Supabase
  ///
  /// **Valor esperado:** https://xxxxx.supabase.co
  /// **Uso:** Configuração do cliente Supabase
  /// **Crítico:** Deve estar preenchido para funcionar
  ///
  /// **Log:**
  /// ```
  /// [EnvConfig] Supabase URL: https://mitegevigjyvtxanmcie.supabase.co
  /// ```
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'] ?? '';

    if (kDebugMode && url.isEmpty) {
      print('[EnvConfig] ⚠️ SUPABASE_URL não configurado!');
    }

    if (kDebugMode && url.isNotEmpty) {
      print('[EnvConfig] ✅ SUPABASE_URL: $url');
    }

    return url;
  }

  /// 🔑 Chave Anônima (Pública) do Supabase
  ///
  /// **Valor esperado:** sb_publishable_xxxxx...
  /// **Uso:** Autenticação no frontend (Flutter)
  /// **Segurança:** Pode ser exposto (é chave pública)
  /// **Crítico:** Deve estar preenchido para funcionar
  ///
  /// **Log:**
  /// ```
  /// [EnvConfig] ✅ Anon Key carregada (20 chars): sb_publishable_cymP...
  /// ```
  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (kDebugMode && key.isEmpty) {
      print('[EnvConfig] ⚠️ SUPABASE_ANON_KEY não configurado!');
    }

    if (kDebugMode && key.isNotEmpty) {
      final preview = key.length > 30 ? '${key.substring(0, 30)}...' : key;
      print('[EnvConfig] ✅ Anon Key carregada: $preview');
    }

    return key;
  }

  /// 🔐 Chave de Serviço (Privada) do Supabase
  ///
  /// **Valor esperado:** eyJhbGciOiJIUzI1NiI...
  /// **Uso:** APENAS no backend (nunca no Flutter!)
  /// **Segurança:** ⚠️ NUNCA exponha ao cliente
  /// **Crítico:** Não é necessário no frontend
  ///
  /// **⚠️ AVISO:**
  /// Se precisar usar no backend, considere:
  /// - Cloud Functions (Supabase)
  /// - Edge Functions (Supabase)
  /// - Backend separado (Node.js, etc)
  ///
  /// **Log:**
  /// ```
  /// [EnvConfig] ⚠️ Service Role Key NÃO deve ser usado no frontend!
  /// ```
  static String get supabaseServiceRoleKey {
    final key = dotenv.env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

    if (kDebugMode && key.isNotEmpty) {
      print('[EnvConfig] ⚠️ Service Role Key detectado (não use no frontend!)');
    }

    return key;
  }

  /// 🌍 Ambiente Atual (development/staging/production)
  ///
  /// **Valor esperado:** development, staging, production
  /// **Padrão:** development
  /// **Uso:** Configurar comportamento por ambiente
  ///
  /// **Exemplo:**
  /// ```dart
  /// if (EnvConfig.environment == 'production') {
  ///   // Use valores mais conservadores
  ///   syncInterval = Duration(minutes: 30);
  /// } else {
  ///   // Modo debug, sync mais frequente
  ///   syncInterval = Duration(minutes: 5);
  /// }
  /// ```
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';

  /// 🐛 Modo Debug (ativa logs detalhados)
  ///
  /// **Valor esperado:** true ou false
  /// **Padrão:** false
  /// **Uso:** Ativar logs em desenvolvimento
  ///
  /// **Exemplo:**
  /// ```dart
  /// if (EnvConfig.debugMode) {
  ///   print('[App] Iniciando em modo DEBUG');
  /// }
  /// ```
  static bool get debugMode {
    final debugStr = dotenv.env['DEBUG_MODE'] ?? 'false';
    return debugStr.toLowerCase() == 'true';
  }

  /// ✅ Valida se todas as variáveis críticas estão configuradas
  ///
  /// **Retorna:** true se URL e Anon Key estão preenchidos
  /// **Uso:** Chamar em main.dart para validar antes de iniciar
  ///
  /// **Exemplo:**
  /// ```dart
  /// Future<void> main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///   await dotenv.load(fileName: ".env");
  ///
  ///   if (!EnvConfig.isValid()) {
  ///     throw Exception('Variáveis de ambiente inválidas!');
  ///   }
  ///
  ///   runApp(const BussApp());
  /// }
  /// ```
  static bool isValid() {
    final urlValid = supabaseUrl.isNotEmpty;
    final keyValid = supabaseAnonKey.isNotEmpty;

    if (kDebugMode) {
      print('[EnvConfig] ════════════════════════════════════════════');
      print('[EnvConfig] VALIDAÇÃO DE CONFIGURAÇÃO');
      print('[EnvConfig] ════════════════════════════════════════════');
      print('[EnvConfig] URL válida: ${urlValid ? '✅' : '❌'}');
      print('[EnvConfig] Anon Key válida: ${keyValid ? '✅' : '❌'}');
      print('[EnvConfig] Ambiente: $environment');
      print('[EnvConfig] Debug: ${debugMode ? '✅' : '❌'}');
      print('[EnvConfig] ════════════════════════════════════════════');
    }

    return urlValid && keyValid;
  }

  /// 📋 Retorna um resumo de todas as configurações (para logs)
  ///
  /// **Uso:** Debug e troubleshooting
  /// **Exemplo:**
  /// ```dart
  /// print(EnvConfig.summary());
  /// // Output:
  /// // Supabase URL: https://...
  /// // Environment: development
  /// // Debug Mode: true
  /// ```
  static String summary() {
    return '''
════════════════════════════════════════════
  🔐 CONFIGURAÇÃO DO AMBIENTE
════════════════════════════════════════════
  📍 URL: ${supabaseUrl.isEmpty ? '❌ NÃO CONFIGURADO' : '✅ Configurado'}
  🔑 Anon Key: ${supabaseAnonKey.isEmpty ? '❌ NÃO CONFIGURADO' : '✅ Configurado'}
  🌍 Ambiente: $environment
  🐛 Debug: ${debugMode ? '✅ Ativo' : '❌ Inativo'}
  ✅ Válido: ${isValid() ? '✅ Sim' : '❌ Não'}
════════════════════════════════════════════
    ''';
  }
}
