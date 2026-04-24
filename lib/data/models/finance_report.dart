class FinanceReport {
  final String reportType;
  final DateTime? generatedAt;
  final Map<String, dynamic> filters;
  final String totalAmount;
  final int totalCount;
  final List<Map<String, dynamic>> rows;

  const FinanceReport({
    required this.reportType,
    required this.generatedAt,
    required this.filters,
    required this.totalAmount,
    required this.totalCount,
    required this.rows,
  });

  factory FinanceReport.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    final filtersRaw = json['filters'];
    final filters = filtersRaw is Map
        ? Map<String, dynamic>.from(filtersRaw)
        : const <String, dynamic>{};

    final summaryRaw = json['summary'];
    final summary = summaryRaw is Map ? Map<String, dynamic>.from(summaryRaw) : const <String, dynamic>{};

    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    final rowsRaw = json['rows'];
    final rows = rowsRaw is List
        ? rowsRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : const <Map<String, dynamic>>[];

    return FinanceReport(
      reportType: json['reportType']?.toString() ?? '',
      generatedAt: parseDate(json['generatedAt']),
      filters: filters,
      totalAmount: summary['totalAmount']?.toString() ?? '0.00',
      totalCount: toInt(summary['totalCount']),
      rows: rows,
    );
  }
}

