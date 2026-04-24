class MonthlyCollectionPoint {
  final String month;
  final double collected;
  final double uncollected;

  const MonthlyCollectionPoint({
    required this.month,
    required this.collected,
    required this.uncollected,
  });

  factory MonthlyCollectionPoint.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    return MonthlyCollectionPoint(
      month: json['month']?.toString() ?? '',
      collected: toDouble(json['collected']),
      uncollected: toDouble(json['uncollected']),
    );
  }
}
