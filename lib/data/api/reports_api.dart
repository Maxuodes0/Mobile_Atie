import '../models/monthly_collection_point.dart';
import '../models/monthly_series.dart';
import '../models/project_status_count.dart';
import 'api_client.dart';

class ReportsApi {
  final ApiClient _api;

  ReportsApi(this._api);

  Future<List<int>> availableYears({
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/reports/available-years',
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

  Future<List<MonthlyCollectionPoint>> monthlyProjectCollections({
    int? year,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (year != null) {
      query['year'] = year;
    }

    final res = await _api.get(
      '/reports/monthly-project-collections',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );

    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) =>
              MonthlyCollectionPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return const <MonthlyCollectionPoint>[];
  }

  Future<MonthlySeries> monthlyProjectCount({
    int? year,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (year != null) {
      query['year'] = year;
    }

    final res = await _api.get(
      '/reports/monthly-project-count',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );

    if (res is Map<String, dynamic>) {
      return MonthlySeries.fromJson(res);
    }
    if (res is Map) {
      return MonthlySeries.fromJson(Map<String, dynamic>.from(res));
    }
    return const MonthlySeries(months: <String>[], values: <double>[]);
  }

  Future<List<ProjectStatusCount>> projectStatusCounts({
    int? year,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final query = <String, dynamic>{};
    if (year != null) query['year'] = year;

    final res = await _api.get(
      '/reports/project-status-counts',
      query: query.isEmpty ? null : query,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is List) {
      return res
          .whereType<Map>()
          .map((e) => ProjectStatusCount.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const <ProjectStatusCount>[];
  }
}
