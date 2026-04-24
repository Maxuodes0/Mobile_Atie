class UserProjectMembership {
  final String projectId;
  final String projectName;
  final String? role;
  final double? amount;
  final double? days;
  final double? ratePerDay;
  final bool isPaid;

  const UserProjectMembership({
    required this.projectId,
    required this.projectName,
    required this.role,
    required this.amount,
    required this.days,
    required this.ratePerDay,
    required this.isPaid,
  });

  factory UserProjectMembership.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return UserProjectMembership(
      projectId: json['projectId']?.toString() ?? '',
      projectName: json['projectName']?.toString() ?? '',
      role: json['role']?.toString(),
      amount: toDouble(json['amount'] ?? json['amountPaid'] ?? json['totalAmount']),
      days: toDouble(json['days'] ?? json['estimatedDays']),
      ratePerDay: toDouble(json['ratePerDay'] ?? json['dailyRate']),
      isPaid: json['isPaid'] == true,
    );
  }
}

class UserProjectSummary {
  final int totalProjects;
  final int paidProjects;
  final int unpaidProjects;
  final double totalPaidAmount;
  final List<UserProjectMembership> projects;

  const UserProjectSummary({
    required this.totalProjects,
    required this.paidProjects,
    required this.unpaidProjects,
    required this.totalPaidAmount,
    required this.projects,
  });

  factory UserProjectSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final raw = json['projects'];
    final projects = raw is List
        ? raw
            .whereType<Map>()
            .map((p) => UserProjectMembership.fromJson(Map<String, dynamic>.from(p)))
            .toList()
        : const <UserProjectMembership>[];

    return UserProjectSummary(
      totalProjects: toInt(json['totalProjects']),
      paidProjects: toInt(json['paidProjects']),
      unpaidProjects: toInt(json['unpaidProjects']),
      totalPaidAmount: toDouble(json['totalPaidAmount']),
      projects: projects,
    );
  }
}

