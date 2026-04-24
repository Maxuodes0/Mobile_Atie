import '../models/user_profile.dart';
import '../models/user_project_summary.dart';
import '../models/org_user.dart';
import '../models/org_users_result.dart';
import '../models/page_meta.dart';
import 'api_client.dart';

class UsersApi {
  final ApiClient _api;

  UsersApi(this._api);

  Future<OrgUsersResult> listMyOrganizationUsers({
    int limit = 50,
    int offset = 0,
    String view = 'basic',
  }) async {
    final res = await _api.get(
      '/users/my-organization',
      query: <String, dynamic>{
        'limit': limit,
        'offset': offset,
        'view': view,
      },
    );

    if (res is Map) {
      final rawUsers = res['users'];
      final rawMeta = res['meta'];

      final users = rawUsers is List
          ? rawUsers
              .whereType<Map>()
              .map((u) => OrgUser.fromJson(Map<String, dynamic>.from(u)))
              .toList()
          : const <OrgUser>[];

      final meta = rawMeta is Map
          ? PageMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : PageMeta(total: users.length, limit: limit, offset: offset);

      return OrgUsersResult(users: users, meta: meta);
    }

    return const OrgUsersResult(
      users: <OrgUser>[],
      meta: PageMeta(total: 0, limit: 0, offset: 0),
    );
  }

  Future<UserProfile> getUser({
    required String userId,
  }) async {
    final res = await _api.get('/users/$userId');
    if (res is Map) {
      final raw = res['user'];
      if (raw is Map<String, dynamic>) return UserProfile.fromJson(raw);
      if (raw is Map) {
        return UserProfile.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    throw Exception('Unexpected user profile response');
  }

  Future<UserProjectSummary> getTeamSummary({
    required String userId,
  }) async {
    final res = await _api.get('/users/team/$userId');
    if (res is Map<String, dynamic>) return UserProjectSummary.fromJson(res);
    if (res is Map) {
      return UserProjectSummary.fromJson(Map<String, dynamic>.from(res));
    }
    throw Exception('Unexpected user summary response');
  }
}
