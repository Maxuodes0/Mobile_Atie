import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import 'api_exception.dart';
import 'cookie_store.dart';

class ApiClient {
  ApiClient({
    String? baseUrl,
  })  : _cookies = CookieStore(),
        _dio = Dio(
          BaseOptions(
            baseUrl: _normalizeBaseUrl(baseUrl ?? AppConfig.apiBaseUrl),
            connectTimeout: const Duration(seconds: 12),
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 25),
            headers: const {
              'accept': 'application/json',
              'content-type': 'application/json',
            },
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _cookies.ready;
          final cookieHeader = _cookies.buildCookieHeader(options.path);
          if (cookieHeader.isNotEmpty) {
            options.headers['cookie'] = cookieHeader;
          }
          handler.next(options);
        },
        onResponse: (response, handler) async {
          await _captureSetCookie(response.headers);
          _capturePermissionsVersion(response.headers);
          handler.next(response);
        },
        onError: (err, handler) async {
          await _captureSetCookie(err.response?.headers);
          handler.next(err);
        },
      ),
    );
  }

  final Dio _dio;
  final CookieStore _cookies;
  final ValueNotifier<int?> permissionsVersion = ValueNotifier<int?>(null);

  Future<bool>? _refreshing;
  String? _csrfToken;

  final Map<String, _CacheEntry> _getCache = <String, _CacheEntry>{};
  final Map<String, Future<dynamic>> _getInflight = <String, Future<dynamic>>{};

  String get baseUrl => _dio.options.baseUrl;

  void clearSession() {
    unawaited(_cookies.clear());
    _csrfToken = null;
    clearCache();
  }

  void clearCache() {
    _getCache.clear();
    _getInflight.clear();
  }

  Future<dynamic> _runGetWithInflight(
    String key,
    Future<dynamic> Function() fetch,
  ) async {
    final existing = _getInflight[key];
    if (existing != null) return existing;

    final future = fetch();
    _getInflight[key] = future;
    try {
      return await future;
    } finally {
      _getInflight.remove(key);
    }
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    Duration? cacheTtl,
    bool forceRefresh = false,
    Map<String, dynamic>? headers,
  }) async {
    final key = _cacheKey(path, query);

    if (cacheTtl == null) {
      return _runGetWithInflight(key, () async {
        final res = await _request('GET', path, query: query, headers: headers);
        return res.data;
      });
    }

    _gcCache();

    if (!forceRefresh) {
      final cached = _getCache[key];
      if (cached != null && cached.expiresAt.isAfter(DateTime.now())) {
        return cached.value;
      }
    }

    final data = await _runGetWithInflight(key, () async {
      final res = await _request('GET', path, query: query, headers: headers);
      return res.data;
    });
    _getCache[key] =
        _CacheEntry(value: data, expiresAt: DateTime.now().add(cacheTtl));
    return data;
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final res = await _request('POST', path, data: data, query: query);
    return res.data;
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final res = await _request('PATCH', path, data: data, query: query);
    return res.data;
  }

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final res = await _request('PUT', path, data: data, query: query);
    return res.data;
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
  }) async {
    final res = await _request('DELETE', path, data: data, query: query);
    return res.data;
  }

  Future<Response<dynamic>> _request(
    String method,
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool retryOnAuthFailure = true,
    bool retryOnCsrfFailure = true,
    Map<String, dynamic>? headers,
  }) async {
    final options = Options(method: method, headers: headers);
    if (!_isSafeMethod(method)) {
      final csrf = await _ensureCsrfToken();
      if (csrf != null && csrf.isNotEmpty) {
        options.headers = <String, dynamic>{
          ...?headers,
          'x-csrf-token': csrf,
        };
      }
    }

    try {
      return await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final errorCode = _extractErrorCode(e.response?.data);

      if (status == 403 && errorCode == 'CSRF_INVALID' && retryOnCsrfFailure) {
        await _rotateCsrfToken();
        return _request(
          method,
          path,
          data: data,
          query: query,
          retryOnCsrfFailure: false,
          retryOnAuthFailure: retryOnAuthFailure,
          headers: headers,
        );
      }

      if (status == 401 && retryOnAuthFailure && !_isAuthPath(path)) {
        final refreshed = await _tryRefreshSession();
        if (refreshed) {
          return _request(
            method,
            path,
            data: data,
            query: query,
            retryOnAuthFailure: false,
            retryOnCsrfFailure: retryOnCsrfFailure,
            headers: headers,
          );
        }
      }

      throw _toApiException(e);
    }
  }

  Future<String?> _ensureCsrfToken() async {
    final existing = _cookies.get('csrf_token') ?? _csrfToken;
    if (existing != null && existing.isNotEmpty) {
      _csrfToken = existing;
      return existing;
    }
    return _rotateCsrfToken();
  }

  Future<String?> _rotateCsrfToken() async {
    try {
      final res = await _dio.get<dynamic>('/auth/csrf');
      _captureSetCookie(res.headers);
      final token =
          (res.data is Map) ? (res.data as Map)['csrfToken']?.toString() : null;
      if (token != null && token.isNotEmpty) {
        _csrfToken = token;
        return token;
      }
      final cookieToken = _cookies.get('csrf_token');
      _csrfToken = cookieToken;
      return cookieToken;
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<bool> _tryRefreshSession() async {
    if (_refreshing != null) return _refreshing!;
    final completer = Completer<bool>();
    _refreshing = completer.future;
    try {
      final csrf = await _ensureCsrfToken();
      final res = await _dio.post<dynamic>(
        '/auth/refresh',
        options: Options(
          headers: csrf != null && csrf.isNotEmpty
              ? <String, dynamic>{'x-csrf-token': csrf}
              : null,
        ),
      );
      _captureSetCookie(res.headers);
      completer.complete(res.statusCode != null &&
          res.statusCode! >= 200 &&
          res.statusCode! < 300);
      return completer.future;
    } on DioException {
      completer.complete(false);
      return false;
    } finally {
      _refreshing = null;
    }
  }

  Future<void> _captureSetCookie(Headers? headers) async {
    if (headers == null) return;
    final setCookies = headers.map['set-cookie'];
    if (setCookies == null || setCookies.isEmpty) return;
    await _cookies.updateFromSetCookieHeaders(setCookies);
    final csrf = _cookies.get('csrf_token');
    if (csrf != null && csrf.isNotEmpty) _csrfToken = csrf;
  }

  void _capturePermissionsVersion(Headers headers) {
    final raw = headers.value('x-permissions-version');
    final parsed = raw == null ? null : int.tryParse(raw);
    if (parsed != null && parsed != permissionsVersion.value) {
      permissionsVersion.value = parsed;
    }
  }

  static String _normalizeBaseUrl(String url) {
    final trimmed = url.trim();
    return trimmed.replaceAll(RegExp(r'/+$'), '');
  }

  void _gcCache() {
    if (_getCache.isEmpty) return;
    final now = DateTime.now();
    _getCache.removeWhere((_, v) => !v.expiresAt.isAfter(now));
    // Keep it simple: if the cache still grows too much, clear it.
    if (_getCache.length > 200) _getCache.clear();
  }

  static String _cacheKey(String path, Map<String, dynamic>? query) {
    if (query == null || query.isEmpty) return 'GET:$path';
    final entries = query.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final qs = entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value.toString())}')
        .join('&');
    return 'GET:$path?$qs';
  }

  static bool _isSafeMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
      case 'HEAD':
      case 'OPTIONS':
        return true;
      default:
        return false;
    }
  }

  static bool _isAuthPath(String path) {
    return path.startsWith('/auth/login') ||
        path.startsWith('/auth/refresh') ||
        path.startsWith('/auth/logout') ||
        path.startsWith('/auth/signup');
  }

  static String? _extractErrorCode(dynamic data) {
    if (data is Map) {
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
      final msg = data['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    }
    return null;
  }

  static ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Request failed';
    String? code;

    if (data is Map) {
      final err = data['error'];
      final msg = data['message'];
      // Backend convention:
      // - `error`: stable error code (e.g. CSRF_INVALID, REQUEST_ERROR)
      // - `message`: human-friendly message
      if (err is String && err.isNotEmpty) code = err;
      if (msg is String && msg.isNotEmpty) {
        message = msg;
      } else if (err is String && err.isNotEmpty) {
        message = err;
      }
    } else if (data is String && data.isNotEmpty) {
      message = _normalizeTextError(data);
    } else if (e.message != null && e.message!.isNotEmpty) {
      message = e.message!;
    }

    return ApiException(statusCode: status, message: message, code: code);
  }

  static String _normalizeTextError(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'Request failed';

    // Express default 404 HTML: `<pre>Cannot GET /path</pre>`
    final preStart = trimmed.indexOf('<pre>');
    final preEnd = trimmed.indexOf('</pre>');
    if (preStart != -1 && preEnd != -1 && preEnd > preStart) {
      final inside = trimmed.substring(preStart + 5, preEnd).trim();
      if (inside.isNotEmpty) return inside;
    }

    // Generic HTML response: keep it readable in UI.
    if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html')) {
      final m = RegExp(
        r'Cannot\\s+(GET|POST|PUT|PATCH|DELETE)\\s+[^<\\s]+',
      ).firstMatch(trimmed);
      if (m != null) return m.group(0)!;
      return 'Unexpected HTML error response';
    }

    // Avoid dumping very large payloads into the UI.
    const maxLen = 280;
    if (trimmed.length > maxLen) {
      return '${trimmed.substring(0, maxLen)}...';
    }
    return trimmed;
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  const _CacheEntry({
    required this.value,
    required this.expiresAt,
  });
}
