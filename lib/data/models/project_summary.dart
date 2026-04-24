class ProjectSummary {
  final String id;
  final String name;
  final String status;
  final String? clientName;
  final String? projectImage;
  final DateTime? createdAt;

  const ProjectSummary({
    required this.id,
    required this.name,
    required this.status,
    required this.clientName,
    required this.projectImage,
    required this.createdAt,
  });

  factory ProjectSummary.fromJson(Map<String, dynamic> json) {
    final client = json['client'];
    final clientName = client is Map ? client['name']?.toString() : null;

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return ProjectSummary(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      clientName: clientName,
      projectImage: json['projectImage']?.toString(),
      createdAt: parseDate(json['createdAt']),
    );
  }
}
