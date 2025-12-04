import '../../data/models/provider_model.dart';

/// 🌐 Interface para acesso remoto a providers (Supabase)
///
/// Define o contrato para sincronização com backend remoto.
abstract class IProvidersRemoteApi {
  /// 📡 Busca providers remotos do Supabase
  ///
  /// Retorna lista de DTOs vindos do servidor.
  /// A conversão para entidades de domínio é feita pelo Mapper.
  ///
  /// **Fluxo:**
  /// 1. Conecta ao Supabase
  /// 2. Busca da tabela 'providers'
  /// 3. Decodifica JSON → List<ProviderModel>
  /// 4. Retorna para o Repository
  ///
  /// **Log esperado:**
  /// ```
  /// [SupabaseRemoteAPI] Buscados 42 providers do servidor
  /// ```
  ///
  /// **Erros possíveis:**
  /// - Sem conexão internet
  /// - Erro de autenticação (RLS ou token inválido)
  /// - Tabela não existe
  Future<List<ProviderModel>> fetchAll();

  /// 🔍 Busca um provider remoto pelo ID
  ///
  /// **Retorna:**
  /// - ProviderModel se encontrado
  /// - null se não encontrado
  Future<ProviderModel?> fetchById(String id);

  /// ➕ Cria um novo provider no servidor
  ///
  /// Envia ProviderModel para Supabase.
  /// Retorna o modelo com ID gerado pelo servidor.
  ///
  /// **Exemplo:**
  /// ```dart
  /// final newModel = ProviderModel(...);
  /// final created = await remoteApi.create(newModel);
  /// print('Criado com ID: ${created.id}');
  /// ```
  Future<ProviderModel> create(ProviderModel model);

  /// ✏️ Atualiza um provider no servidor
  Future<ProviderModel> update(ProviderModel model);

  /// 🗑️ Deleta um provider do servidor pelo ID
  Future<bool> delete(String id);

  /// 📦 Faz upsert (insert ou update) de múltiplos providers em lote
  ///
  /// **Sincronização Bidirecional - PUSH:**
  /// Este é o primeiro passo do fluxo push-then-pull.
  /// Envia todos os providers do cache local para o Supabase.
  ///
  /// **Fluxo:**
  /// 1. Recebe lista de DTOs do cache local
  /// 2. Converte cada DTO para JSON
  /// 3. Chama `upsert()` do Supabase (insert ou update, não delete)
  /// 4. Retorna quantidade de linhas afetadas
  ///
  /// **Por que upsert?**
  /// - Não precisa saber se o item já existe remotamente
  /// - Preserva o ID local mesmo se foi criado offline
  /// - Melhor esforço: se falhar na rede, continua tentando no próximo sync
  ///
  /// **Importante:**
  /// - Este método é "melhor esforço": erros de rede são ignorados pelo Repository
  /// - O Repository continua com o pull mesmo se o push falhar
  /// - Detalhes do erro são registrados em log para debug
  ///
  /// **Log esperado:**
  /// ```
  /// [SupabaseRemoteDatasource] upsertProviders: enviando 5 itens
  /// [SupabaseRemoteDatasource] upsert response: 5 linhas, error: null
  /// ```
  ///
  /// **Erros possíveis:**
  /// - RLS error: usuário não autenticado ou sem permissão
  /// - Schema error: coluna não existe ou tipo incompat ível
  /// - Network error: sem conexão com Supabase
  Future<int> upsertProviders(List<ProviderModel> models);
}

/// 🔌 Implementação Supabase
///
/// Conecta ao Supabase para sincronizar providers.
/// Requer configuração: SUPABASE_URL + SUPABASE_ANON_KEY em environment.
///
/// ⚠️ IMPORTANTE DIDÁTICO:
/// - Este datasource trabalha com DTOs (ProviderModel)
/// - Não faz conversão para domínio (é responsabilidade do Repository + Mapper)
/// - Conecta lazy: cria instância do cliente sob demanda
///
/// **Tabela esperada no Supabase:**
/// ```sql
/// CREATE TABLE providers (
///   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   name TEXT NOT NULL,
///   image_uri TEXT,
///   distance_km DOUBLE PRECISION DEFAULT 0,
///   created_at TIMESTAMP DEFAULT NOW(),
///   updated_at TIMESTAMP DEFAULT NOW(),
///   is_active BOOLEAN DEFAULT true
/// );
/// ```
///
/// **RLS (Row-Level Security) recomendada:**
/// ```sql
/// -- Qualquer um pode ler
/// CREATE POLICY "Allow SELECT for all" ON providers
///   FOR SELECT USING (true);
///
/// -- Apenas autenticados podem inserir/atualizar
/// CREATE POLICY "Allow INSERT/UPDATE for authenticated" ON providers
///   FOR INSERT WITH CHECK (auth.role() = 'authenticated');
/// CREATE POLICY "Allow UPDATE for authenticated" ON providers
///   FOR UPDATE USING (auth.role() = 'authenticated');
/// ```
class SupabaseProvidersRemoteDatasource implements IProvidersRemoteApi {
  /// ⚠️ AVISO: Em produção, use injeção de dependência
  /// Aqui criamos instância direta para simplicidade didática.
  /// Para um app real, passe o cliente via construtor.

  /// Busca todos os providers do Supabase
  ///
  /// **Fluxo:**
  /// 1. SELECT * FROM providers
  /// 2. Mapeia cada linha para ProviderModel
  /// 3. Retorna lista
  ///
  /// **Log esperado:**
  /// ```
  /// [SupabaseAPI] Iniciando fetch de providers...
  /// [SupabaseAPI] Buscados 42 providers do servidor
  /// ```
  ///
  /// **Tratamento de erros:**
  /// - Sem conexão → Exception re-lançada com contexto
  /// - Erro de RLS → Exception com detalhes de permissão
  /// - JSON inválido → Exception durante fromJson()
  @override
  Future<List<ProviderModel>> fetchAll() async {
    try {
      // ⚠️ IMPORTANTE: Aqui você precisará configurar seu cliente Supabase
      // Exemplo com supabase_flutter package:
      //
      // ```dart
      // final supabase = Supabase.instance.client;
      // final response = await supabase.from(_tableName).select();
      // ```
      //
      // Para esta versão didática, retornamos lista vazia.
      // Em produção, implemente com seu cliente real.

      print('[SupabaseProvidersRemoteDatasource] Iniciando fetch de providers...');

      // 🔴 TODO: Implementar com supabase_flutter
      // Exemplo de como ficaria:
      // final response = await supabase.from(_tableName).select();
      // final models = (response as List)
      //     .map((json) => ProviderModel.fromJson(json))
      //     .toList();
      // print('[SupabaseProvidersRemoteDatasource] Buscados ${models.length} providers do servidor');
      // return models;

      // Por enquanto, retorna lista vazia para não quebrar a compilação
      return [];
    } catch (e) {
      print('[SupabaseProvidersRemoteDatasource] ❌ Erro ao buscar providers: $e');
      rethrow;
    }
  }

  /// 🔍 Busca um provider pelo ID
  @override
  Future<ProviderModel?> fetchById(String id) async {
    try {
      print('[SupabaseProvidersRemoteDatasource] Buscando provider: $id');

      // 🔴 TODO: Implementar com supabase_flutter
      // final response = await supabase
      //     .from(_tableName)
      //     .select()
      //     .eq('id', id)
      //     .maybeSingle();
      // return response != null ? ProviderModel.fromJson(response) : null;

      return null;
    } catch (e) {
      print('[SupabaseProvidersRemoteDatasource] ❌ Erro ao buscar provider $id: $e');
      rethrow;
    }
  }

  /// ➕ Cria um novo provider
  @override
  Future<ProviderModel> create(ProviderModel model) async {
    try {
      print('[SupabaseProvidersRemoteDatasource] Criando provider: ${model.name}');

      // 🔴 TODO: Implementar com supabase_flutter
      // final response = await supabase
      //     .from(_tableName)
      //     .insert([model.toJson()])
      //     .select()
      //     .single();
      // return ProviderModel.fromJson(response);

      return model; // Por enquanto retorna o modelo como está
    } catch (e) {
      print('[SupabaseProvidersRemoteDatasource] ❌ Erro ao criar provider: $e');
      rethrow;
    }
  }

  /// ✏️ Atualiza um provider
  @override
  Future<ProviderModel> update(ProviderModel model) async {
    try {
      print('[SupabaseProvidersRemoteDatasource] Atualizando provider: ${model.id}');

      // 🔴 TODO: Implementar com supabase_flutter
      // final response = await supabase
      //     .from(_tableName)
      //     .update(model.toJson())
      //     .eq('id', model.id)
      //     .select()
      //     .single();
      // return ProviderModel.fromJson(response);

      return model;
    } catch (e) {
      print('[SupabaseProvidersRemoteDatasource] ❌ Erro ao atualizar provider: $e');
      rethrow;
    }
  }

  /// 🗑️ Deleta um provider
  @override
  Future<bool> delete(String id) async {
    try {
      print('[SupabaseProvidersRemoteDatasource] Deletando provider: $id');

      // 🔴 TODO: Implementar com supabase_flutter
      // await supabase
      //     .from(_tableName)
      //     .delete()
      //     .eq('id', id);
      // return true;

      return true;
    } catch (e) {
      print('[SupabaseProvidersRemoteDatasource] ❌ Erro ao deletar provider: $e');
      return false;
    }
  }

  /// 📦 Upsert em lote (PUSH bidirecional)
  ///
  /// **Implementação da sincronização push:**
  ///
  /// Esta é a primeira etapa do fluxo push-then-pull (sincronização bidirecional).
  /// O repositório envia todas as mudanças locais para o Supabase neste método.
  ///
  /// **Fluxo didático:**
  /// ```
  /// PUSH (Envia local → Supabase):
  /// ┌──────────────────────┐
  /// │ Local DAO (cache)    │
  /// │ Providers cache      │
  /// └──────────┬───────────┘
  ///            │ Repository.listAll()
  ///            ↓
  /// ┌──────────────────────┐
  /// │ Mapper.toDto()       │
  /// │ Entity → Model       │
  /// └──────────┬───────────┘
  ///            │
  ///            ↓
  /// ┌──────────────────────┐
  /// │ upsertProviders()    │ ← Você está aqui
  /// │ Este método          │
  /// └──────────┬───────────┘
  ///            │ supabase.from('providers').upsert([...])
  ///            ↓
  /// ┌──────────────────────┐
  /// │ Supabase (remoto)    │
  /// │ Table: providers     │
  /// └──────────────────────┘
  /// ```
  ///
  /// **Parâmetros:**
  /// - `models`: Lista de DTOs que existem no cache local
  ///
  /// **Retorna:**
  /// - Número de linhas que foram upsertadas no servidor
  /// - 0 se houve erro (erro é registrado em log)
  ///
  /// **Comportamento:**
  /// 1. Se a lista for vazia, registra em log e retorna 0 (sem falha)
  /// 2. Mapeia cada DTO para JSON
  /// 3. Envia ao Supabase via `upsert()`
  /// 4. Se sucesso, retorna quantidade de linhas
  /// 5. Se erro, registra em log e retorna 0 (não falha - permite pull continuar)
  ///
  /// **⚠️ Importante didático:**
  /// - Este método NÃO retorna as linhas (would need SELECT after upsert)
  /// - Retorna apenas a contagem como um "melhor esforço"
  /// - O Repository não usa o retorno para nada crítico
  /// - Erros aqui não impedem o pull (fluxo bidirecional resiliente)
  @override
  Future<int> upsertProviders(List<ProviderModel> models) async {
    try {
      // 🔵 PASSO 1: Verificar se há itens para enviar
      if (models.isEmpty) {
        print('[SupabaseProvidersRemoteDatasource] Nenhum item local para enviar (cache vazio)');
        return 0;
      }

      print('[SupabaseProvidersRemoteDatasource] Iniciando PUSH: enviando ${models.length} itens para Supabase');

      // 🔵 PASSO 2: Converter DTOs para JSON
      final jsonList = models.map((model) => model.toJson()).toList();

      print('[SupabaseProvidersRemoteDatasource] Convertidos ${jsonList.length} modelos para JSON');

      // 🔵 PASSO 3: Chamar Supabase upsert
      // 🔴 TODO: Implementar com supabase_flutter
      // Exemplo de como ficaria:
      // ```dart
      // final supabase = Supabase.instance.client;
      // final response = await supabase
      //     .from(_tableName)
      //     .upsert(jsonList)
      //     .select();
      // 
      // // response pode ser vazio ou conter os itens upsertados
      // // dependendo de como o Supabase está configurado
      // print('[SupabaseProvidersRemoteDatasource] Upsert response: ${response.length} linhas retornadas');
      // return response.length ?? models.length;
      // ```

      // 🟡 Para esta versão didática, simulamos sucesso
      print('[SupabaseProvidersRemoteDatasource] ✅ PUSH simulado: ${models.length} itens');
      return models.length;

    } catch (e) {
      // 🔵 PASSO 4: Tratamento de erro (melhor esforço - não falha)
      print('[SupabaseProvidersRemoteDatasource] ⚠️ Erro no PUSH: $e');
      print('[SupabaseProvidersRemoteDatasource] Continuando com PULL mesmo com erro no PUSH...');
      
      // Retorna 0 para indicar falha, mas não relança erro
      // O Repository continuará com o pull
      return 0;
    }
  }
}
