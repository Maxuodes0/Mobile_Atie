import 'package:flutter/foundation.dart';

import '../data/api/api_client.dart';
import '../data/api/auth_api.dart';
import '../data/models/user.dart';

class SessionController {
  final AuthApi _auth;
  final ApiClient _api;

  final ValueNotifier<User?> user = ValueNotifier<User?>(null);
  final ValueNotifier<bool> restoring = ValueNotifier<bool>(false);

  SessionController(this._auth, this._api);

  Future<void> restore() async {
    restoring.value = true;
    try {
      user.value = await _auth.me();
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
  }

  Future<void> logout() async {
    try {
      await _auth.logout();
    } catch (_) {
      // ignore logout failures; still clear local session
    }
    _api.clearSession();
    user.value = null;
  }
}
