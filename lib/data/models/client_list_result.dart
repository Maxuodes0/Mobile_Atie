import 'client_summary.dart';
import 'page_meta.dart';

class ClientListResult {
  final List<ClientSummary> clients;
  final PageMeta meta;

  const ClientListResult({
    required this.clients,
    required this.meta,
  });

  factory ClientListResult.fromJson(Map<String, dynamic> json) {
    final rawClients = json['clients'];
    final clients = rawClients is List
        ? rawClients
            .whereType<Map>()
            .map((client) =>
                ClientSummary.fromJson(Map<String, dynamic>.from(client)))
            .toList()
        : const <ClientSummary>[];

    final rawMeta = json['meta'];
    final meta = rawMeta is Map
        ? PageMeta.fromJson(Map<String, dynamic>.from(rawMeta))
        : PageMeta(total: clients.length, limit: clients.length, offset: 0);

    return ClientListResult(clients: clients, meta: meta);
  }
}
