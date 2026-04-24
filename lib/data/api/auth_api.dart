import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _api;

  AuthApi(this._api);

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final res = await _api.post(
      '/auth/login',
      data: <String, dynamic>{
        'email': email.trim(),
        'password': password,
      },
    );
    if (res is Map) {
      final userRaw = res['user'];
      if (userRaw is Map<String, dynamic>) {
        return User.fromJson(userRaw);
      }
      if (userRaw is Map) {
        return User.fromJson(Map<String, dynamic>.from(userRaw));
      }
    }
    throw Exception('Unexpected login response');
  }

  Future<User> me() async {
    final res = await _api.get('/auth/me');
    if (res is Map) {
      final userRaw = res['user'];
      if (userRaw is Map<String, dynamic>) {
        return User.fromJson(userRaw);
      }
      if (userRaw is Map) {
        return User.fromJson(Map<String, dynamic>.from(userRaw));
      }
    }
    throw Exception('Unexpected /auth/me response');
  }

  Future<void> logout() async {
    await _api.post('/auth/logout');
  }
}
