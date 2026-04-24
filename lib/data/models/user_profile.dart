class HrProfile {
  final String? employeeNumber;
  final String? jobTitle;
  final String? department;
  final String? status;
  final DateTime? hireDate;

  const HrProfile({
    required this.employeeNumber,
    required this.jobTitle,
    required this.department,
    required this.status,
    required this.hireDate,
  });

  factory HrProfile.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    return HrProfile(
      employeeNumber: json['employeeNumber']?.toString(),
      jobTitle: json['jobTitle']?.toString(),
      department: json['department']?.toString(),
      status: json['status']?.toString(),
      hireDate: toDate(json['hireDate']),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? iban;
  final String? profileImage;
  final String? organizationName;
  final DateTime? createdAt;
  final HrProfile? hrProfile;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.iban,
    required this.profileImage,
    required this.organizationName,
    required this.createdAt,
    required this.hrProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? toDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    final hrRaw = json['hrProfile'];
    final hr = hrRaw is Map ? HrProfile.fromJson(Map<String, dynamic>.from(hrRaw)) : null;

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString(),
      iban: json['iban']?.toString(),
      profileImage: json['profileImage']?.toString(),
      organizationName: json['organizationName']?.toString(),
      createdAt: toDate(json['createdAt']),
      hrProfile: hr,
    );
  }
}

