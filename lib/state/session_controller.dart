import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/api/api_client.dart';
import '../data/api/auth_api.dart';
import '../data/models/user.dart';
import '../data/models/access_snapshot.dart';

class SessionController {
  final AuthApi _auth;
  final ApiClient _api;

  final ValueNotifier<User?> user = ValueNotifier<User?>(null);
  final ValueNotifier<bool> restoring = ValueNotifier<bool>(false);
  final ValueNotifier<AccessSnapshot?> access = ValueNotifier<AccessSnapshot?>(null);
  Timer? _accessVersionTimer;

  SessionController(this._auth, this._api) {
    _api.permissionsVersion.addListener(_handleResponseVersion);
    _accessVersionTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_checkAccessVersion()),
    );
  }

  Future<void> _loadAccess() async {
    final data = await _api.get(
      '/access/me',
      forceRefresh: true,
      headers: const <String, dynamic>{
        'accept': 'application/vnd.aite.access.v2+json',
      },
    );
    if (data is Map) {
      access.value = AccessSnapshot.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> _checkAccessVersion() async {
    if (user.value == null) return;
    try {
      final data = await _api.get('/access/version', forceRefresh: true);
      final version = data is Map ? (data['permissionsVersion'] as num?)?.toInt() : null;
      if (version != null && version != access.value?.permissionsVersion) {
        await _loadAccess();
      }
    } catch (_) {
      // Backend authorization remains authoritative while the app is active.
    }
  }

  void _handleResponseVersion() {
    final version = _api.permissionsVersion.value;
    if (user.value != null && version != null && version != access.value?.permissionsVersion) {
      unawaited(_loadAccess());
    }
  }

  Future<void> restore() async {
    restoring.value = true;
    try {
      user.value = await _auth.me();
      await _loadAccess();
    } catch (_) {
      user.value = null;
    } finally {
      restoring.value = false;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    // Avoid reusing cached GET responses when switching accounts.
    _api.clearCache();
    user.value = await _auth.login(email: email, password: password);
    await _loadAccess();
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // ignore logout failures; still clear local session
    }
    _api.clearSession();
    access.value = null;
    user.value = null;
  }

  void dispose() {
    _accessVersionTimer?.cancel();
    _api.permissionsVersion.removeListener(_handleResponseVersion);
    user.dispose();
    restoring.dispose();
    access.dispose();
  }
}
