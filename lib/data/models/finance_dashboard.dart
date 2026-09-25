class FinanceKpis {
  final String? totalProjectValueWithoutVat;
  final String? totalCollectedAmount;
  final String? outstandingAmount;
  final String? allTimeOutstandingAmount;
  final String? totalCosts;
  final String? netProfit;
  final String? profitMargin;
  final String? collectionRate;

  const FinanceKpis({
    required this.totalProjectValueWithoutVat,
    required this.totalCollectedAmount,
    required this.outstandingAmount,
    this.allTimeOutstandingAmount,
    required this.totalCosts,
    required this.netProfit,
    required this.profitMargin,
    this.collectionRate,
  });

  FinanceKpis copyWith({
    String? totalProjectValueWithoutVat,
    String? totalCollectedAmount,
    String? outstandingAmount,
    String? allTimeOutstandingAmount,
    String? totalCosts,
    String? netProfit,
    String? profitMargin,
    String? collectionRate,
  }) {
    return FinanceKpis(
      totalProjectValueWithoutVat:
          totalProjectValueWithoutVat ?? this.totalProjectValueWithoutVat,
      totalCollectedAmount: totalCollectedAmount ?? this.totalCollectedAmount,
      outstandingAmount: outstandingAmount ?? this.outstandingAmount,
      allTimeOutstandingAmount:
          allTimeOutstandingAmount ?? this.allTimeOutstandingAmount,
      totalCosts: totalCosts ?? this.totalCosts,
      netProfit: netProfit ?? this.netProfit,
      profitMargin: profitMargin ?? this.profitMargin,
      collectionRate: collectionRate ?? this.collectionRate,
    );
  }

  factory FinanceKpis.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final raw = json[key];
      if (raw == null) return null;
      if (!RegExp(r'^-?\d+(?:\.\d+)?$').hasMatch(raw.toString())) {
        throw FormatException('Invalid financial field: $key');
      }
      return raw.toString();
    }

    return FinanceKpis(
      totalProjectValueWithoutVat: read('totalProjectValueWithoutVat'),
      totalCollectedAmount: read('totalCollectedAmount'),
      outstandingAmount: read('outstandingAmount'),
      allTimeOutstandingAmount: read('allTimeOutstandingAmount'),
      totalCosts: read('totalCosts'),
      netProfit: read('netProfit'),
      profitMargin: read('profitMargin'),
      collectionRate: read('collectionRate'),
    );
  }
}

class FinanceDashboard {
  final FinanceKpis kpis;

  const FinanceDashboard({required this.kpis});

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'];
    if (meta is Map && meta['fallback'] == true) {
      throw const FormatException('Financial data is temporarily unavailable.');
    }
    final kpisRaw = json['kpis'];
    if (kpisRaw is! Map<String, dynamic>) {
      throw const FormatException('Financial response is missing KPI data.');
    }
    final kpis = FinanceKpis.fromJson(kpisRaw);
    return FinanceDashboard(kpis: kpis);
  }
}
