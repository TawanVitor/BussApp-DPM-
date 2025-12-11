import '../models/provider_model.dart';

/// Interface para Datasource Remoto de Providers (API)
/// 
/// Define o contrato para acesso de dados remoto (Supabase) de providers.
abstract class IProvidersRemoteApi {
  /// Busca todos os providers do servidor remoto
  Future<List<ProviderModel>> fetchAll();

  /// Busca um provider específico pelo ID do servidor remoto
  Future<ProviderModel?> fetchById(String id);

  /// Cria um novo provider no servidor remoto
  Future<ProviderModel> create(ProviderModel model);

  /// Atualiza um provider no servidor remoto
  Future<ProviderModel> update(ProviderModel model);

  /// Deleta um provider do servidor remoto
  Future<bool> delete(String id);

  /// Sincroniza múltiplos providers com o servidor (upsert)
  Future<int> upsertProviders(List<ProviderModel> models);
}
