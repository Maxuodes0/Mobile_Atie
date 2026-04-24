import '../models/dashboard_mobile_summary.dart';
import '../models/dashboard_summary.dart';
import 'api_client.dart';

class DashboardApi {
  final ApiClient _api;

  DashboardApi(this._api);

  Future<DashboardSummary> adminSummary({
    bool lite = true,
    int? year,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (lite) query['lite'] = '1';
    if (year != null) query['year'] = year;

    final res = await _api.get(
      '/dashboard/admin/summary',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );

    if (res is Map<String, dynamic>) {
      return DashboardSummary.fromJson(res);
    }
    if (res is Map) {
      return DashboardSummary.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected dashboard summary response');
  }

  Future<DashboardMobileSummary> mobileSummary({
    int? year,
    String? from,
    String? to,
    List<String>? sections,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;
    if (from != null && from.trim().isNotEmpty) query['from'] = from.trim();
    if (to != null && to.trim().isNotEmpty) query['to'] = to.trim();
    if (sections != null && sections.isNotEmpty) {
      query['sections'] = sections.join(',');
    }

    final res = await _api.get(
      '/dashboard/admin/mobile-summary',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );

    if (res is Map<String, dynamic>) {
      return DashboardMobileSummary.fromJson(res);
    }
    if (res is Map) {
      return DashboardMobileSummary.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected mobile dashboard summary response');
  }
}
