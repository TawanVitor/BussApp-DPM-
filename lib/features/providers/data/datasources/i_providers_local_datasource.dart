import '../../domain/entities/provider.dart';

/// Interface para Datasource Local de Providers (DAO)
/// 
/// Define o contrato para acesso de dados local (cache) de providers.
abstract class IProvidersLocalDao {
  /// Obtém todos os providers do cache local
  Future<List<Provider>> getAll();

  /// Obtém um provider pelo ID do cache
  Future<Provider?> getById(String id);

  /// Cria um novo provider no cache
  Future<Provider> create(Provider provider);

  /// Atualiza um provider existente no cache
  Future<Provider> update(Provider provider);

  /// Deleta um provider do cache
  Future<bool> delete(String id);

  /// Salva múltiplos providers no cache
  Future<List<Provider>> saveAll(List<Provider> providers);

  /// Limpa todos os providers do cache
  Future<void> clear();
}
