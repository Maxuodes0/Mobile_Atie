import '../models/finance_dashboard.dart';
import '../models/finance_report.dart';
import 'api_client.dart';

class FinanceApi {
  final ApiClient _api;

  FinanceApi(this._api);

  Future<List<int>> availableYears({
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/finance/available-years',
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );

    if (res is Map) {
      final rawYears = res['years'];
      if (rawYears is List) {
        return rawYears
            .map((e) => int.tryParse(e.toString()))
            .whereType<int>()
            .toList();
      }
    }

    if (res is List) {
      return res
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    return const <int>[];
  }

  Future<FinanceDashboard> getDashboard({
    String? from,
    String? to,
    String? projectId,
    String? clientId,
    String? currency,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (from != null && from.trim().isNotEmpty) {
      query['from'] = from.trim();
    }
    if (to != null && to.trim().isNotEmpty) {
      query['to'] = to.trim();
    }
    if (projectId != null && projectId.trim().isNotEmpty) {
      query['projectId'] = projectId.trim();
    }
    if (clientId != null && clientId.trim().isNotEmpty) {
      query['clientId'] = clientId.trim();
    }
    if (currency != null && currency.trim().isNotEmpty) {
      query['currency'] = currency.trim();
    }

    final res = await _api.get(
      '/finance/dashboard',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is Map<String, dynamic>) return FinanceDashboard.fromJson(res);
    if (res is Map) {
      return FinanceDashboard.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected finance dashboard response');
  }

  Future<FinanceReport> getReport({
    required String reportType,
    String? from,
    String? to,
    String? projectId,
    String? clientId,
    String? currency,
  }) async {
    final query = <String, dynamic>{'reportType': reportType};
    if (from != null && from.trim().isNotEmpty) {
      query['from'] = from.trim();
    }
    if (to != null && to.trim().isNotEmpty) {
      query['to'] = to.trim();
    }
    if (projectId != null && projectId.trim().isNotEmpty) {
      query['projectId'] = projectId.trim();
    }
    if (clientId != null && clientId.trim().isNotEmpty) {
      query['clientId'] = clientId.trim();
    }
    if (currency != null && currency.trim().isNotEmpty) {
      query['currency'] = currency.trim();
    }

    final res = await _api.get('/finance/reports', query: query);
    if (res is Map<String, dynamic>) return FinanceReport.fromJson(res);
    if (res is Map) {
      return FinanceReport.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected finance report response');
  }
}
