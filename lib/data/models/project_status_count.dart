class ProjectStatusCount {
  final String status;
  final int count;

  const ProjectStatusCount({
    required this.status,
    required this.count,
  });

  factory ProjectStatusCount.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    final parsedCount = rawCount is int
        ? rawCount
        : int.tryParse(rawCount?.toString() ?? '') ?? 0;
    return ProjectStatusCount(
      status: json['status']?.toString() ?? '',
      count: parsedCount,
    );
  }
}

