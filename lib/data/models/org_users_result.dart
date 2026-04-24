import 'page_meta.dart';
import 'org_user.dart';

class OrgUsersResult {
  final List<OrgUser> users;
  final PageMeta meta;

  const OrgUsersResult({
    required this.users,
    required this.meta,
  });
}

