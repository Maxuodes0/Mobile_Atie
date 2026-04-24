import 'user_role_count.dart';

class DashboardSummary {
  final List<UserRoleCount> userRoleCounts;
  final int hrEmployeesCount;
  final int hrEmployeesWithAccountCount;

  const DashboardSummary({
    required this.userRoleCounts,
    required this.hrEmployeesCount,
    required this.hrEmployeesWithAccountCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final roleCountsRaw = json['userRoleCounts'];
    final roleCounts = roleCountsRaw is List
        ? roleCountsRaw
            .whereType<Map>()
            .map((e) => UserRoleCount.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <UserRoleCount>[];

    int parseInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    return DashboardSummary(
      userRoleCounts: roleCounts,
      hrEmployeesCount: parseInt(json['hrEmployeesCount']),
      hrEmployeesWithAccountCount: parseInt(json['hrEmployeesWithAccountCount']),
    );
  }
}

