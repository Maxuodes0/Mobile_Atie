class TaskItem {
  final String id;
  final String title;
  final String? description;
  final String status;
  final String? priority;
  final DateTime? dueDate;
  final String projectId;
  final String? assigneeId;
  final String? projectName;

  const TaskItem({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.projectId,
    required this.assigneeId,
    required this.projectName,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    final projectRaw = json['project'];
    final projectName =
        projectRaw is Map ? projectRaw['name']?.toString() : null;

    return TaskItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      priority: json['priority']?.toString(),
      dueDate: parseDate(json['dueDate']),
      projectId: json['projectId']?.toString() ?? '',
      assigneeId: json['assigneeId']?.toString(),
      projectName: projectName,
    );
  }

  TaskItem copyWith({
    String? title,
    String? description,
    String? status,
    String? priority,
    DateTime? dueDate,
    String? projectId,
    String? assigneeId,
    String? projectName,
  }) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      projectName: projectName ?? this.projectName,
    );
  }
}
