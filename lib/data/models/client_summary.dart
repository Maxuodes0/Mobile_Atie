class ClientSummary {
  final String id;
  final String name;
  final String? logo;
  final String status;
  final int projectCount;
  final double totalRevenueWithoutVat;

  const ClientSummary({
    required this.id,
    required this.name,
    required this.logo,
    required this.status,
    required this.projectCount,
    required this.totalRevenueWithoutVat,
  });

  factory ClientSummary.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '') ?? 0;
    }

    final rawCount = json['_count'];
    final count = rawCount is Map
        ? toInt(rawCount['projects'])
        : toInt(json['totalProjects']);

    return ClientSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      status: json['status']?.toString() ?? 'ACTIVE',
      projectCount: count,
      totalRevenueWithoutVat: toDouble(
        json['totalRevenueWithoutVat'] ?? json['totalRevenue'],
      ),
    );
  }
}
