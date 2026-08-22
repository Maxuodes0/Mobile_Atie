import '../models/user.dart';
import 'api_client.dart';

class AuthApi {
  final ApiClient _api;

  AuthApi(this._api);

  Future<AuthLoginResult> login({
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
      return AuthLoginResult.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected login response');
  }

  Future<MfaEnrollmentSetup> startMfaEnrollment(
    String transactionToken,
  ) async {
    final res = await _api.post(
      '/auth/mfa/enrollment/start',
      data: <String, dynamic>{'transactionToken': transactionToken},
    );
    if (res is Map) {
      return MfaEnrollmentSetup.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected MFA enrollment response');
  }

  Future<AuthLoginResult> confirmMfaEnrollment({
    required String transactionToken,
    required String code,
  }) async {
    final res = await _api.post(
      '/auth/mfa/enrollment/confirm',
      data: <String, dynamic>{
        'transactionToken': transactionToken,
        'code': code.trim(),
      },
    );
    if (res is Map) {
      return AuthLoginResult.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected MFA confirmation response');
  }

  Future<AuthLoginResult> challengeMfa({
    required String transactionToken,
    required String code,
  }) async {
    final res = await _api.post(
      '/auth/mfa/challenge',
      data: <String, dynamic>{
        'transactionToken': transactionToken,
        'code': code.trim(),
      },
    );
    if (res is Map) {
      return AuthLoginResult.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected MFA challenge response');
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

class AuthLoginResult {
  const AuthLoginResult({
    this.user,
    this.code,
    this.message,
    this.transactionToken,
    this.recoveryCodes = const <String>[],
  });

  final User? user;
  final String? code;
  final String? message;
  final String? transactionToken;
  final List<String> recoveryCodes;

  bool get requiresMfaEnrollment => code == 'MFA_ENROLLMENT_REQUIRED';
  bool get requiresMfaChallenge => code == 'MFA_REQUIRED';

  factory AuthLoginResult.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'];
    User? user;
    if (userRaw is Map) {
      user = User.fromJson(Map<String, dynamic>.from(userRaw));
    }
    final recoveryRaw = json['recoveryCodes'];
    return AuthLoginResult(
      user: user,
      code: json['code']?.toString(),
      message: json['message']?.toString(),
      transactionToken: json['transactionToken']?.toString(),
      recoveryCodes: recoveryRaw is List
          ? recoveryRaw.map((value) => value.toString()).toList()
          : const <String>[],
    );
  }
}

class MfaEnrollmentSetup {
  const MfaEnrollmentSetup({required this.secret, required this.uri});

  final String secret;
  final String uri;

  factory MfaEnrollmentSetup.fromJson(Map<String, dynamic> json) {
    final secret = json['secret']?.toString() ?? '';
    if (secret.isEmpty) {
      throw Exception('Missing MFA setup key');
    }
    return MfaEnrollmentSetup(
      secret: secret,
      uri: json['uri']?.toString() ?? '',
    );
  }
}
