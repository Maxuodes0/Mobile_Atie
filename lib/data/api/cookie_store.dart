class CookieStore {
  final Map<String, String> _cookies = <String, String>{};

  bool get isEmpty => _cookies.isEmpty;

  String? get(String name) => _cookies[name];

  void clear() => _cookies.clear();

  String buildCookieHeader() {
    if (_cookies.isEmpty) return '';
    return _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  void updateFromSetCookieHeaders(List<String> setCookieHeaders) {
    for (final raw in setCookieHeaders) {
      final firstPart = raw.split(';').first.trim();
      if (firstPart.isEmpty) continue;
      final eq = firstPart.indexOf('=');
      if (eq <= 0) continue;
      final name = firstPart.substring(0, eq).trim();
      var value = firstPart.substring(eq + 1).trim();
      if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      if (name.isEmpty) continue;
      if (value.isEmpty) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
      }
    }
  }
}
