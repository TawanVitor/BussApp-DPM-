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
  /// Nome da tabela no Supabase
  static const String _tableName = 'providers';

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
}
