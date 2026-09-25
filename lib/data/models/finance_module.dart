import 'dart:typed_data';

/// All financial filters are interpreted on the server. In particular, the
/// client never turns a year or quarter into its own date boundaries.
class FinanceQuery {
  final int? year;
  final String quarter;
  final String? from;
  final String? to;
  final String? clientId;
  final String? operatingCompanyId;
  final String? projectId;
  final String? status;
  final String? costCategory;
  final String? search;
  final String? sortField;
  final String? sortDir;
  final String? groupBy;
  final String? compare;
  final int page;
  final int pageSize;

  const FinanceQuery({
    this.year,
    this.quarter = 'ALL',
    this.from,
    this.to,
    this.clientId,
    this.operatingCompanyId,
    this.projectId,
    this.status,
    this.costCategory,
    this.search,
    this.sortField,
    this.sortDir,
    this.groupBy,
    this.compare,
    this.page = 1,
    this.pageSize = 25,
  });

  FinanceQuery copyWith({
    int? year,
    String? quarter,
    String? from,
    String? to,
    String? clientId,
    String? operatingCompanyId,
    String? projectId,
    String? status,
    String? costCategory,
    String? search,
    String? sortField,
    String? sortDir,
    String? groupBy,
    String? compare,
    int? page,
    int? pageSize,
    bool clearYear = false,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearClient = false,
    bool clearOperatingCompany = false,
    bool clearProject = false,
    bool clearStatus = false,
    bool clearCostCategory = false,
    bool clearSearch = false,
  }) {
    return FinanceQuery(
      year: clearYear ? null : year ?? this.year,
      quarter: quarter ?? this.quarter,
      from: clearFrom ? null : from ?? this.from,
      to: clearTo ? null : to ?? this.to,
      clientId: clearClient ? null : clientId ?? this.clientId,
      operatingCompanyId: clearOperatingCompany
          ? null
          : operatingCompanyId ?? this.operatingCompanyId,
      projectId: clearProject ? null : projectId ?? this.projectId,
      status: clearStatus ? null : status ?? this.status,
      costCategory:
          clearCostCategory ? null : costCategory ?? this.costCategory,
      search: clearSearch ? null : search ?? this.search,
      sortField: sortField ?? this.sortField,
      sortDir: sortDir ?? this.sortDir,
      groupBy: groupBy ?? this.groupBy,
      compare: compare ?? this.compare,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  Map<String, dynamic> toQuery() {
    final values = <String, dynamic>{'page': page, 'pageSize': pageSize};
    if (year != null) values['year'] = year;
    if (quarter != 'ALL') values['quarter'] = quarter;
    void add(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) values[key] = value.trim();
    }

    add('from', from);
    add('to', to);
    add('clientId', clientId);
    add('operatingCompanyId', operatingCompanyId);
    add('projectId', projectId);
    add('status', status);
    add('costCategory', costCategory);
    add('search', search);
    add('sortField', sortField);
    add('sortDir', sortDir);
    add('groupBy', groupBy);
    add('compare', compare);
    return values;
  }
}

class FinancePageMeta {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const FinancePageMeta({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory FinancePageMeta.fromJson(Map<String, dynamic> json) {
    int read(String key, int fallback) =>
        int.tryParse(json[key]?.toString() ?? '') ?? fallback;
    final pageSize = read('pageSize', read('limit', 25));
    final total = read('total', read('totalCount', 0));
    return FinancePageMeta(
      total: total,
      page: read('page', 1),
      pageSize: pageSize,
      totalPages:
          read('totalPages', pageSize > 0 ? (total / pageSize).ceil() : 0),
    );
  }
}

class FinanceDataPage {
  final List<Map<String, dynamic>> rows;
  final FinancePageMeta meta;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> filters;
  final Map<String, dynamic> basis;
  final Map<String, dynamic> deltas;
  final String? filteredTotal;
  final String? cardTotal;
  final bool? matchesCard;
  final bool unavailable;
  final String? unavailableReason;

  const FinanceDataPage({
    required this.rows,
    required this.meta,
    required this.totals,
    required this.filters,
    required this.basis,
    required this.deltas,
    required this.filteredTotal,
    required this.cardTotal,
    required this.matchesCard,
    required this.unavailable,
    required this.unavailableReason,
  });

  factory FinanceDataPage.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> mapOf(dynamic raw) =>
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    final rawRows = json['rows'];
    final totals = mapOf(json['totals']);
    final meta = mapOf(json['meta']);
    // Reports keep the count/page on the top level while details place them
    // in `meta`. Merge both so a report's pagination never appears empty.
    meta.putIfAbsent('total', () => json['totalCount']);
    meta.putIfAbsent('page', () => json['page']);
    meta.putIfAbsent('pageSize', () => json['pageSize']);
    meta.putIfAbsent('totalPages', () => json['totalPages']);
    return FinanceDataPage(
      rows: rawRows is List
          ? rawRows.whereType<Map>().map((row) => mapOf(row)).toList()
          : const <Map<String, dynamic>>[],
      meta: FinancePageMeta.fromJson(meta),
      totals: totals,
      filters: mapOf(json['filters']),
      basis: mapOf(json['basis']),
      deltas: mapOf(meta['deltas']),
      filteredTotal:
          (json['filteredTotal'] ?? totals['filteredSum'])?.toString(),
      cardTotal: (json['cardTotal'] ?? totals['cardSum'])?.toString(),
      matchesCard: json['matchesCard'] is bool
          ? json['matchesCard'] as bool
          : totals['matchesCard'] is bool
              ? totals['matchesCard'] as bool
              : null,
      unavailable: json['unavailable'] == true || meta['unavailable'] == true,
      unavailableReason: (json['unavailableReason'] ??
              meta['unavailableReason'] ??
              meta['reason'])
          ?.toString(),
    );
  }
}

class FinanceProjectDetail {
  final Map<String, dynamic> project;
  final Map<String, String?> financials;
  final FinanceDataPage collections;
  final FinanceDataPage costs;

  const FinanceProjectDetail({
    required this.project,
    required this.financials,
    required this.collections,
    required this.costs,
  });

  factory FinanceProjectDetail.fromJson(Map<String, dynamic> json) {
    final project = json['project'] is Map
        ? Map<String, dynamic>.from(json['project'] as Map)
        : <String, dynamic>{};
    final rawFinancials = json['financials'] is Map
        ? Map<String, dynamic>.from(json['financials'] as Map)
        : <String, dynamic>{};
    final financials = rawFinancials.map(
      (key, value) => MapEntry(key, value?.toString()),
    );
    FinanceDataPage readPage(String key) => FinanceDataPage.fromJson(
          json[key] is Map
              ? Map<String, dynamic>.from(json[key] as Map)
              : <String, dynamic>{},
        );
    return FinanceProjectDetail(
      project: project,
      financials: financials,
      collections: readPage('collections'),
      costs: readPage('costs'),
    );
  }
}

class FinanceExport {
  final Uint8List bytes;
  final String mimeType;
  final String filename;

  const FinanceExport({
    required this.bytes,
    required this.mimeType,
    required this.filename,
  });
}
