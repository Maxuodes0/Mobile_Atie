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
  final ValueNotifier<bool> restoring = ValueNotifier<bool>(true);
  final ValueNotifier<AccessSnapshot?> access =
      ValueNotifier<AccessSnapshot?>(null);
  Timer? _accessVersionTimer;
  Future<void>? _pendingLogout;

  SessionController(this._auth, this._api) {
    _api.permissionsVersion.addListener(_handleResponseVersion);
    _accessVersionTimer = Timer.periodic(
      const Duration(seconds: 60),
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

  Future<void> _loadAccessSafely() async {
    try {
      await _loadAccess();
    } catch (_) {
      // Access will be retried by the version poll. The backend remains the
      // authority, so this request should never block launch or sign-in UI.
    }
  }

  Future<void> _checkAccessVersion() async {
    if (user.value == null) return;
    try {
      final data = await _api.get('/access/version', forceRefresh: true);
      final version =
          data is Map ? (data['permissionsVersion'] as num?)?.toInt() : null;
      if (version != null && version != access.value?.permissionsVersion) {
        await _loadAccess();
      }
    } catch (_) {
      // Backend authorization remains authoritative while the app is active.
    }
  }

  void _handleResponseVersion() {
    final version = _api.permissionsVersion.value;
    if (user.value != null &&
        version != null &&
        version != access.value?.permissionsVersion) {
      unawaited(_loadAccessSafely());
    }
  }

  Future<void> restore() async {
    restoring.value = true;
    try {
      user.value = await _auth.restore();
      // A slow permissions request must not keep the launch screen visible.
      // The shell can render immediately and react when access arrives.
      if (user.value != null) unawaited(_loadAccessSafely());
    } catch (_) {
      user.value = null;
    } finally {
      restoring.value = false;
    }
  }

  Future<AuthLoginResult> login({
    required String email,
    required String password,
  }) async {
    // A fast second login must not race the previous server-side logout.
    await _pendingLogout;
    // Avoid reusing cached GET responses when switching accounts.
    _api.clearCache();
    final result = await _auth.login(email: email, password: password);
    if (result.user != null) {
      await acceptAuthenticatedUser(result.user!);
    }
    return result;
  }

  Future<void> acceptAuthenticatedUser(User authenticatedUser) async {
    user.value = authenticatedUser;
    unawaited(_loadAccessSafely());
  }

  Future<void> logout() async {
    // AuthGate switches to the sign-in screen immediately. The server session
    // is revoked in the background, then local cookies are cleared.
    access.value = null;
    user.value = null;
    _api.clearCache();
    _pendingLogout = _completeLogout();
  }

  Future<void> _completeLogout() async {
    try {
      await _auth.logout().timeout(const Duration(seconds: 5));
    } catch (_) {
      // Local credentials were already cleared before revocation was sent.
    }
  }

  void dispose() {
    _accessVersionTimer?.cancel();
    _api.permissionsVersion.removeListener(_handleResponseVersion);
    user.dispose();
    restoring.dispose();
    access.dispose();
  }
}
