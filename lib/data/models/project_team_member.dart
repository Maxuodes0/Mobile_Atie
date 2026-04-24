class ProjectTeamUser {
  final String id;
  final String name;
  final String role;
  final String? profileImage;

  const ProjectTeamUser({
    required this.id,
    required this.name,
    required this.role,
    required this.profileImage,
  });

  factory ProjectTeamUser.fromJson(Map<String, dynamic> json) {
    return ProjectTeamUser(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class ProjectTeamMember {
  final String userId;
  final String? projectRole;
  final bool isPaid;
  final double? estimatedDays;
  final double? actualDays;
  final double? dailyRate;
  final double? totalAmount;
  final double? totalPaid;
  final ProjectTeamUser? user;

  const ProjectTeamMember({
    required this.userId,
    required this.projectRole,
    required this.isPaid,
    required this.estimatedDays,
    required this.actualDays,
    required this.dailyRate,
    required this.totalAmount,
    required this.totalPaid,
    required this.user,
  });

  factory ProjectTeamMember.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final userRaw = json['user'];
    final user = userRaw is Map ? ProjectTeamUser.fromJson(Map<String, dynamic>.from(userRaw)) : null;

    return ProjectTeamMember(
      userId: json['userId']?.toString() ?? '',
      projectRole: json['role']?.toString(),
      isPaid: json['isPaid'] == true,
      estimatedDays: toDouble(json['estimatedDays'] ?? json['days']),
      actualDays: toDouble(json['actualDays']),
      dailyRate: toDouble(json['dailyRate'] ?? json['ratePerDay']),
      totalAmount: toDouble(json['totalAmount'] ?? json['amountPaid']),
      totalPaid: toDouble(json['totalPaid']),
      user: user,
    );
  }
}

