class TaskNote {
  final String id;
  final String body;
  final DateTime createdAt;
  final String? authorName;
  final String? authorRole;
  final String? authorProfileImage;

  const TaskNote({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.authorName,
    required this.authorRole,
    required this.authorProfileImage,
  });

  factory TaskNote.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic v) {
      if (v is DateTime) return v;
      final s = v?.toString().trim() ?? '';
      return DateTime.tryParse(s) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    final authorRaw = json['author'];
    final author =
        authorRaw is Map ? Map<String, dynamic>.from(authorRaw) : null;

    return TaskNote(
      id: json['id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
      authorName: author?['name']?.toString(),
      authorRole: author?['role']?.toString(),
      authorProfileImage: author?['profileImage']?.toString(),
    );
  }
}
