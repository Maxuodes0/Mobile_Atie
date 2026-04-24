class PageMeta {
  final int total;
  final int limit;
  final int offset;

  const PageMeta({
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory PageMeta.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    return PageMeta(
      total: toInt(json['total']),
      limit: toInt(json['limit']),
      offset: toInt(json['offset']),
    );
  }
}
