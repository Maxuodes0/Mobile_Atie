class ProjectSummary {
  final String id;
  final String name;
  final String status;
  final String? collectionStatus;
  final double? totalCollectedAmount;
  final String? clientName;
  final String? operatingCompanyName;
  final String? projectImage;
  final DateTime? createdAt;
  final DateTime? startDate;
  final double? projectValueWithoutVat;

  const ProjectSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.collectionStatus,
    required this.totalCollectedAmount,
    required this.clientName,
    this.operatingCompanyName,
    required this.projectImage,
    required this.createdAt,
    this.startDate,
    this.projectValueWithoutVat,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    final client = json['client'];
    final clientName = client is Map ? client['name']?.toString() : null;
    final operatingCompany = json['operatingCompany'];
    final operatingCompanyName = operatingCompany is Map
        ? operatingCompany['name']?.toString()
        : json['operatingCompanyName']?.toString();

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    double? parseNumber(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      final raw = value.toString().trim();
      if (raw.isEmpty) return null;
      return double.tryParse(raw);
    }

    return ProjectSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      collectionStatus: json.containsKey('collectionStatus')
          ? json['collectionStatus']?.toString()
          : null,
      totalCollectedAmount: json.containsKey('totalCollectedAmount')
          ? parseNumber(json['totalCollectedAmount'])
          : null,
      clientName: clientName,
      operatingCompanyName: operatingCompanyName,
      projectImage: json['projectImage']?.toString(),
      createdAt: parseDate(json['createdAt']),
      startDate: parseDate(json['startDate']),
      projectValueWithoutVat: parseNumber(json['projectValueWithoutVat']),
    );
  }
}
