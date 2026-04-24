class MonthlySeries {
  final List<String> months;
  final List<double> values;

  const MonthlySeries({
    required this.months,
    required this.values,
  });

  factory MonthlySeries.fromJson(Map<String, dynamic> json) {
    final monthsRaw = json['months'];
    final valuesRaw = json['values'];

    final months = monthsRaw is List
        ? monthsRaw.map((e) => e?.toString() ?? '').toList()
        : <String>[];

    double toDouble(dynamic v) {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '') ?? 0;
    }

    final values = valuesRaw is List
        ? valuesRaw.map((e) => toDouble(e)).toList()
        : <double>[];

    return MonthlySeries(months: months, values: values);
  }
}
