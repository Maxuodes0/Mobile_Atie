class UserRoleCount {
  final String role;
  final int count;

  const UserRoleCount({
    required this.role,
    required this.count,
  });

  factory UserRoleCount.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final parsedCount = rawCount is int
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '') ?? 0;
    return UserRoleCount(
      role: json['role']?.toString() ?? '',
      count: parsedCount,
    );
  }
}

