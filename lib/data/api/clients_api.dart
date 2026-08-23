import '../models/client_list_result.dart';
import '../models/client_summary.dart';
import '../models/page_meta.dart';
import 'api_client.dart';

class ClientsApi {
  final ApiClient _api;

  ClientsApi(this._api);

  Future<ClientListResult> listClientsPage({
    int limit = 200,
    int offset = 0,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final response = await _api.get(
      '/clients',
      query: <String, dynamic>{'limit': limit, 'offset': offset},
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (response is Map) {
      return ClientListResult.fromJson(Map<String, dynamic>.from(response));
    }
    return const ClientListResult(
      clients: <ClientSummary>[],
      meta: PageMeta(total: 0, limit: 0, offset: 0),
    );
  }

  Future<List<ClientSummary>> listAllClients({
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    const pageSize = 200;
    final clients = <ClientSummary>[];
    var offset = 0;

    while (true) {
      final page = await listClientsPage(
        limit: pageSize,
        offset: offset,
        cacheTtl: cacheTtl,
        forceRefresh: forceRefresh,
      );
      clients.addAll(page.clients);
      offset = clients.length;
      if (page.clients.isEmpty || offset >= page.meta.total) break;
    }

    return clients;
  }
}
