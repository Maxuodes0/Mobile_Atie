import '../models/project_summary.dart';
import '../models/project_details.dart';
import '../models/page_meta.dart';
import '../models/project_collection.dart';
import '../models/project_team_member.dart';
import '../models/project_collections_result.dart';
import '../models/project_list_result.dart';
import 'api_client.dart';

class ProjectsApi {
  final ApiClient _api;

  ProjectsApi(this._api);

  Future<List<ProjectSummary>> listProjects({
    int limit = 50,
    int offset = 0,
    String view = 'summary',
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final result = await listProjectsPage(
      limit: limit,
      offset: offset,
      view: view,
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    return result.projects;
  }

  Future<ProjectListResult> listProjectsPage({
    int limit = 50,
    int offset = 0,
    String view = 'summary',
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/projects',
      query: <String, dynamic>{
        'view': view,
        'limit': limit,
        'offset': offset,
      },
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is Map<String, dynamic>) {
      return ProjectListResult.fromJson(res);
    }
    if (res is Map) {
      return ProjectListResult.fromJson(Map<String, dynamic>.from(res));
    }
    return const ProjectListResult(
      projects: <ProjectSummary>[],
      meta: PageMeta(total: 0, limit: 0, offset: 0),
    );
  }

  Future<ProjectDetails> getProject({
    required String projectId,
    String view = 'summary',
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/projects/$projectId',
      query: <String, dynamic>{'view': view},
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is Map) {
      final raw = res['project'];
      if (raw is Map<String, dynamic>) return ProjectDetails.fromJson(raw);
      if (raw is Map) {
        return ProjectDetails.fromJson(Map<String, dynamic>.from(raw));
      }
    }
    throw Exception('Unexpected project details response');
  }

  Future<List<ProjectTeamMember>> listTeam({
    required String projectId,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/projects/$projectId/team',
      query: const <String, dynamic>{'view': 'basic'},
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is Map) {
      final raw = res['members'];
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
                (m) => ProjectTeamMember.fromJson(Map<String, dynamic>.from(m)))
            .toList();
      }
    }
    return const <ProjectTeamMember>[];
  }

  Future<ProjectCollectionsResult> listCollections({
    required String projectId,
    int limit = 200,
    int offset = 0,
    Duration? cacheTtl,
    bool forceRefresh = false,
  }) async {
    final res = await _api.get(
      '/projects/$projectId/collections',
      query: <String, dynamic>{
        'limit': limit,
        'offset': offset,
      },
      cacheTtl: cacheTtl,
      forceRefresh: forceRefresh,
    );
    if (res is Map<String, dynamic>) {
      return ProjectCollectionsResult.fromJson(res);
    }
    if (res is Map) {
      return ProjectCollectionsResult.fromJson(Map<String, dynamic>.from(res));
    }
    return const ProjectCollectionsResult(
      collections: <ProjectCollectionItem>[],
      meta: PageMeta(total: 0, limit: 0, offset: 0),
    );
  }
}
