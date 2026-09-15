import '../../utils/formatters.dart';

class FinanceKpis {
  final String? totalProjectValueWithoutVat;
  final String? totalCollectedAmount;
  final String? outstandingAmount;
  final String? totalCosts;
  final String? netProfit;
  final String? profitMargin;

  const FinanceKpis({
    required this.totalProjectValueWithoutVat,
    required this.totalCollectedAmount,
    required this.outstandingAmount,
    required this.totalCosts,
    required this.netProfit,
    required this.profitMargin,
  });

  factory FinanceKpis.fromJson(Map<String, dynamic> json) {
    String? read(String key) {
      final raw = json[key];
      if (raw == null) return null;
      if (parseFinancialValue(raw) == null) {
        throw FormatException('Invalid financial field: $key');
      }
      return raw.toString();
    }

    return FinanceKpis(
      totalProjectValueWithoutVat: read('totalProjectValueWithoutVat'),
      totalCollectedAmount: read('totalCollectedAmount'),
      outstandingAmount: read('outstandingAmount'),
      totalCosts: read('totalCosts'),
      netProfit: read('netProfit'),
      profitMargin: read('profitMargin'),
    );
  }
}

class FinanceDashboard {
  final FinanceKpis kpis;

  const FinanceDashboard({required this.kpis});

  factory FinanceDashboard.fromJson(Map<String, dynamic> json) {
    final kpisRaw = json['kpis'];
    if (kpisRaw is! Map<String, dynamic>) {
      throw const FormatException('Financial response is missing KPI data.');
    }
    final kpis = FinanceKpis.fromJson(kpisRaw);
    return FinanceDashboard(kpis: kpis);
  }
}
