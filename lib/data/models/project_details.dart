class ProjectDetails {
  final String id;
  final String name;
  final String? description;
  final String status;
  final String? projectImage;
  final String? clientName;
  final ProjectUserRef? projectManager;
  final DateTime? createdAt;
  final DateTime? startDate;
  final DateTime? dueDate;
  final double? budgetSpent;

  const ProjectDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.projectImage,
    required this.clientName,
    required this.projectManager,
    required this.createdAt,
    required this.startDate,
    required this.dueDate,
    required this.budgetSpent,
  });

  factory ProjectDetails.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    double? parseNumber(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    final clientRaw = json['client'];
    final client =
        clientRaw is Map ? Map<String, dynamic>.from(clientRaw) : null;

    final managerRaw = json['projectManager'];
    final projectManager = managerRaw is Map
        ? ProjectUserRef.fromJson(Map<String, dynamic>.from(managerRaw))
        : null;

    return ProjectDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? '',
      projectImage: json['projectImage']?.toString(),
      clientName: client?['name']?.toString(),
      projectManager: projectManager,
      createdAt: parseDate(json['createdAt']),
      startDate: parseDate(json['startDate']),
      dueDate: parseDate(json['dueDate']),
      budgetSpent: parseNumber(json['budgetSpent']),
    );
  }
}

class ProjectUserRef {
  final String id;
  final String name;
  final String? email;

  const ProjectUserRef({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ProjectUserRef.fromJson(Map<String, dynamic> json) {
    return ProjectUserRef(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }
}
