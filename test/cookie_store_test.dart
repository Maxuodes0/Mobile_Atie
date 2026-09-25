import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:aite_mobile/data/api/cookie_store.dart';

class _UnavailableKeychain extends FlutterSecureStoragePlatform {
  PlatformException get _error => PlatformException(code: '-34018');

  @override
  Future<String?> read(
          {required String key, required Map<String, String> options}) async =>
      throw _error;

  @override
  Future<void> write(
          {required String key,
          required String value,
          required Map<String, String> options}) async =>
      throw _error;

  @override
  Future<void> delete(
          {required String key, required Map<String, String> options}) async =>
      throw _error;

  @override
  Future<bool> containsKey(
          {required String key, required Map<String, String> options}) async =>
      throw _error;

  @override
  Future<Map<String, String>> readAll(
          {required Map<String, String> options}) async =>
      throw _error;

  @override
  Future<void> deleteAll({required Map<String, String> options}) async =>
      throw _error;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
      'unavailable iOS keychain cannot stall startup or erase in-memory session',
      () async {
    final previous = FlutterSecureStoragePlatform.instance;
    FlutterSecureStoragePlatform.instance = _UnavailableKeychain();
    addTearDown(() => FlutterSecureStoragePlatform.instance = previous);

    final store = CookieStore();
    await store.ready.timeout(const Duration(seconds: 2));
    expect(store.get('refresh_token'), isNull);

    await store.updateFromSetCookieHeaders(['refresh_token=example; Path=/']);
    expect(store.get('refresh_token'), 'example');
    await store.clear();
    expect(store.get('refresh_token'), isNull);
  });
}
