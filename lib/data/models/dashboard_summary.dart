class DashboardSummary {
  final int clientCount;
  final int operatingCompanyCount;

  const DashboardSummary({
    required this.clientCount,
    required this.operatingCompanyCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return DashboardSummary(
      clientCount: parseInt(json['clientCount']),
      operatingCompanyCount: parseInt(json['operatingCompanyCount']),
    );
  }
}
