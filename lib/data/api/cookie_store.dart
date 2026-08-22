import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieStore {
  CookieStore() : ready = Future<void>.value() {
    if (!kIsWeb) ready = _restore();
  }

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _persistedNames = <String>{'refresh_token', 'csrf_token'};
  final Map<String, String> _cookies = <String, String>{};
  late Future<void> ready;

  Future<void> _restore() async {
    for (final name in _persistedNames) {
      final value = await _storage.read(key: 'aite.auth.$name');
      if (value != null && value.isNotEmpty) _cookies[name] = value;
    }
  }

  String? get(String name) => _cookies[name];

  Future<void> clear() async {
    _cookies.clear();
    if (!kIsWeb) {
      for (final name in _persistedNames) {
        await _storage.delete(key: 'aite.auth.$name');
      }
    }
  }

  String buildCookieHeader(String requestPath) => _cookies.entries
      .where((entry) => entry.key != 'refresh_token' || requestPath.startsWith('/auth'))
      .map((entry) => '${entry.key}=${entry.value}')
      .join('; ');

  Future<void> updateFromSetCookieHeaders(List<String> headers) async {
    for (final raw in headers) {
      final pair = raw.split(';').first;
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      final name = pair.substring(0, separator).trim();
      final value = pair.substring(separator + 1).trim();
      if (value.isEmpty) {
        _cookies.remove(name);
        if (!kIsWeb && _persistedNames.contains(name)) await _storage.delete(key: 'aite.auth.$name');
      } else {
        _cookies[name] = value;
        if (!kIsWeb && _persistedNames.contains(name)) await _storage.write(key: 'aite.auth.$name', value: value);
      }
    }
  }
}
