class ProjectCollectionItem {
  final String id;
  final double collectedAmount;
  final DateTime? collectedDate;
  final String? method;
  final String? referenceNumber;
  final String? notes;
  final String? createdByName;

  const ProjectCollectionItem({
    required this.id,
    required this.collectedAmount,
    required this.collectedDate,
    required this.method,
    required this.referenceNumber,
    required this.notes,
    required this.createdByName,
  });

  factory ProjectCollectionItem.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    final createdByRaw = json['createdBy'];
    final createdBy = createdByRaw is Map ? Map<String, dynamic>.from(createdByRaw) : null;

    return ProjectCollectionItem(
      id: json['id']?.toString() ?? '',
      collectedAmount: toDouble(json['collectedAmount']),
      collectedDate: parseDate(json['collectedDate']),
      method: json['method']?.toString(),
      referenceNumber: json['referenceNumber']?.toString(),
      notes: json['notes']?.toString(),
      createdByName: createdBy?['name']?.toString(),
    );
  }
}

