import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../models/finance_dashboard.dart';
import '../models/finance_module.dart';
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
    int? year,
    String? quarter,
    String? from,
    String? to,
    String? projectId,
    String? clientId,
    String? currency,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    // The mobile overview only consumes project KPIs. Keep the backend's
    // authoritative calculation while skipping unrelated asset/chart work.
    final query = <String, dynamic>{'compact': 'true'};
    if (year != null) query['year'] = year;
    if (quarter != null && quarter != 'ALL') query['quarter'] = quarter;
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
    if (res is Map<String, dynamic>) {
      _rejectFallback(res);
      return FinanceDashboard.fromJson(res);
    }
    if (res is Map) {
      final parsed = Map<String, dynamic>.from(res);
      _rejectFallback(parsed);
      return FinanceDashboard.fromJson(parsed);
    }
    throw Exception('Unexpected finance dashboard response');
  }

  static const _metrics = <String>{
    'contractValue',
    'collected',
    'uncollected',
    'costs',
    'netProfit',
    'collectionRate',
  };
  static const _reportTypes = <String>{
    'revenue',
    'collection-status',
    'aging',
    'costs',
    'profitability',
    'vat',
    'cash-flow',
    'entities',
    'comparison',
  };

  void _rejectFallback(Map<String, dynamic> body) {
    final meta = body['meta'];
    if (meta is Map && meta['fallback'] == true) {
      throw StateError('Financial data is temporarily unavailable. Retry.');
    }
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response is! Map) {
      throw const FormatException('Invalid finance response');
    }
    final body = Map<String, dynamic>.from(response);
    _rejectFallback(body);
    return body;
  }

  Future<FinanceDataPage> getKpiDetails(
      String metric, FinanceQuery query) async {
    if (!_metrics.contains(metric)) throw ArgumentError.value(metric, 'metric');
    final body = _asMap(await _api.get(
      '/finance/kpi-details/$metric',
      query: query.toQuery(),
    ));
    return FinanceDataPage.fromJson(body);
  }

  Future<FinanceProjectDetail> getProjectFinancialDetail(
    String projectId, {
    int page = 1,
    int pageSize = 25,
  }) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    final body = _asMap(await _api.get(
      '/finance/projects/${Uri.encodeComponent(projectId)}/summary',
      query: {'page': page, 'pageSize': pageSize},
    ));
    return FinanceProjectDetail.fromJson(body);
  }

  Future<FinanceDataPage> getCollections(FinanceQuery query) async =>
      FinanceDataPage.fromJson(_asMap(await _api.get(
        '/finance/collections',
        query: query.toQuery(),
      )));

  Future<FinanceDataPage> getCosts(FinanceQuery query) async =>
      FinanceDataPage.fromJson(_asMap(await _api.get(
        '/finance/costs',
        query: query.toQuery(),
      )));

  Future<FinanceDataPage> getMobileReport(
      String type, FinanceQuery query) async {
    if (!_reportTypes.contains(type)) throw ArgumentError.value(type, 'type');
    final body = _asMap(await _api.get(
      '/finance/reports/$type',
      query: query.toQuery(),
    ));
    return FinanceDataPage.fromJson(body);
  }

  Future<void> createCollection(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    if (projectId.trim().isEmpty) {
      throw ArgumentError.value(projectId, 'projectId');
    }
    await _api.post(
      '/projects/${Uri.encodeComponent(projectId)}/collections',
      data: payload,
    );
    _api.clearCache();
  }

  Future<void> deleteCollection(String projectId, String collectionId) async {
    if (projectId.trim().isEmpty || collectionId.trim().isEmpty) {
      throw ArgumentError('projectId and collectionId are required');
    }
    await _api.delete(
      '/projects/${Uri.encodeComponent(projectId)}/collections/${Uri.encodeComponent(collectionId)}',
    );
    _api.clearCache();
  }

  Future<FinanceExport> exportReport(
      String type, String format, FinanceQuery query,
      {String locale = 'en'}) async {
    if (!_reportTypes.contains(type)) throw ArgumentError.value(type, 'type');
    if (format != 'pdf' && format != 'xlsx') {
      throw ArgumentError.value(format, 'format');
    }
    final response = await _api.getRaw(
      '/finance/reports/$type/export',
      query: {
        ...query.toQuery(),
        'format': format,
        'locale': locale == 'ar' ? 'ar' : 'en'
      },
      responseType: ResponseType.bytes,
    );
    final contentType = response.headers.value('content-type') ?? '';
    final expected = format == 'pdf' ? 'application/pdf' : 'spreadsheetml';
    if (!contentType.contains(expected)) {
      throw const FormatException('Unexpected finance export response');
    }
    final data = response.data;
    final bytes = data is Uint8List
        ? data
        : data is List<int>
            ? Uint8List.fromList(data)
            : throw const FormatException('Invalid finance export data');
    if (bytes.isEmpty) throw const FormatException('Empty finance export');
    final disposition = response.headers.value('content-disposition') ?? '';
    final filename =
        RegExp(r'filename="?([^";]+)"?').firstMatch(disposition)?.group(1) ??
            'finance-$type.$format';
    return FinanceExport(
      bytes: bytes,
      mimeType: contentType,
      filename: filename.replaceAll(RegExp(r'[/\\]'), '_'),
    );
  }
}
