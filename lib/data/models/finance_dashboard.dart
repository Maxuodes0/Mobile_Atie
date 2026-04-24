class FinanceKpis {
  final String totalProjectValueWithoutVat;
  final String totalCollectedAmount;
  final String outstandingAmount;
  final String totalCosts;
  final String netProfit;
  final String profitMargin;

  const FinanceKpis({
    required this.totalProjectValueWithoutVat,
    required this.totalCollectedAmount,
    required this.outstandingAmount,
    required this.totalCosts,
    required this.netProfit,
    required this.profitMargin,
  });

  factory FinanceKpis.fromJson(Map<String, dynamic> json) {
    return FinanceKpis(
      totalProjectValueWithoutVat:
          json['totalProjectValueWithoutVat']?.toString() ?? '0.00',
      totalCollectedAmount: json['totalCollectedAmount']?.toString() ?? '0.00',
      outstandingAmount: json['outstandingAmount']?.toString() ?? '0.00',
      totalCosts: json['totalCosts']?.toString() ?? '0.00',
      netProfit: json['netProfit']?.toString() ?? '0.00',
      profitMargin: json['profitMargin']?.toString() ?? '0',
    );
  }
}

class FinanceDashboard {
  final FinanceKpis kpis;

  const FinanceDashboard({required this.kpis});

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final kpisRaw = json['kpis'];
    final kpis = kpisRaw is Map<String, dynamic>
        ? FinanceKpis.fromJson(kpisRaw)
        : const FinanceKpis(
            totalProjectValueWithoutVat: '0.00',
            totalCollectedAmount: '0.00',
            outstandingAmount: '0.00',
            totalCosts: '0.00',
            netProfit: '0.00',
            profitMargin: '0',
          );
    return FinanceDashboard(kpis: kpis);
  }
}
