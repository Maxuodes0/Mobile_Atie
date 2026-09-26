import 'dart:convert';
import 'dart:typed_data';

import 'package:aite_mobile/data/api/api_client.dart';
import 'package:aite_mobile/data/api/auth_api.dart';
import 'package:aite_mobile/data/api/cookie_store.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryCookieStore extends CookieStore {
  _MemoryCookieStore([Map<String, String> values = const {}])
      : _values = Map<String, String>.from(values),
        super(restoreFromStorage: false);

  final Map<String, String> _values;

  @override
  String? get(String name) => _values[name];

  @override
  String buildCookieHeader(String requestPath) => _values.entries
      .where((entry) =>
          entry.key != 'refresh_token' || requestPath.startsWith('/auth'))
      .map((entry) => '${entry.key}=${entry.value}')
      .join('; ');

  @override
  Future<void> updateFromSetCookieHeaders(List<String> headers) async {
    for (final raw in headers) {
      final pair = raw.split(';').first;
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      _values[pair.substring(0, separator)] = pair.substring(separator + 1);
    }
  }
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.respond);

  final ResponseBody Function(RequestOptions) respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async =>
      respond(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Object body, {List<String> setCookies = const []}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    200,
    headers: {
      Headers.contentTypeHeader: ['application/json'],
      if (setCookies.isNotEmpty) 'set-cookie': setCookies,
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('signed-out cold launch skips the network entirely', () async {
    final paths = <String>[];
    final api = ApiClient(
      baseUrl: 'https://api.example.test',
      cookieStore: _MemoryCookieStore(),
      httpClientAdapter: _StubAdapter((options) {
        paths.add(options.path);
        throw StateError('No request is expected without a refresh token');
      }),
    );

    expect(await AuthApi(api).restore(), isNull);
    expect(paths, isEmpty);
  });

  test('signed-in cold launch refreshes once before requesting profile',
      () async {
    final paths = <String>[];
    final cookies = <String>[];
    final api = ApiClient(
      baseUrl: 'https://api.example.test',
      cookieStore: _MemoryCookieStore({
        'refresh_token': 'old-refresh',
        'csrf_token': 'old-csrf',
      }),
      httpClientAdapter: _StubAdapter((options) {
        paths.add(options.path);
        cookies.add(options.headers['cookie']?.toString() ?? '');
        if (options.path == '/auth/refresh') {
          return _jsonResponse(
            {'message': 'Token refreshed'},
            setCookies: ['access_token=new-access; Path=/; HttpOnly'],
          );
        }
        if (options.path == '/auth/me') {
          return _jsonResponse({
            'user': {
              'id': 'u1',
              'name': 'Aite User',
              'email': 'user@example.test',
              'role': 'ADMIN',
            },
          });
        }
        throw StateError('Unexpected ${options.path}');
      }),
    );

    final user = await AuthApi(api).restore();

    expect(user?.id, 'u1');
    expect(paths, ['/auth/refresh', '/auth/me']);
    expect(cookies.first, contains('refresh_token=old-refresh'));
    expect(cookies.last, contains('access_token=new-access'));
  });
}
