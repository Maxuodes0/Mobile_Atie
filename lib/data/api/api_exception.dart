class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final String? code;

  ApiException({
    required this.message,
    this.statusCode,
    this.code,
  });

  @override
  String toString() {
    final c = code != null ? ' ($code)' : '';
    final s = statusCode != null ? ' HTTP $statusCode' : '';
    return 'ApiException$s$c: $message';
  }
}
