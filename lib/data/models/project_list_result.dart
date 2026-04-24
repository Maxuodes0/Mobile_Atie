import 'page_meta.dart';
import 'project_summary.dart';

class ProjectListResult {
  final List<ProjectSummary> projects;
  final PageMeta meta;

  const ProjectListResult({
    required this.projects,
    required this.meta,
  });

  factory ProjectListResult.fromJson(Map<String, dynamic> json) {
    final rawProjects = json['projects'];
    final projects = rawProjects is List
        ? rawProjects
            .whereType<Map>()
            .map((p) => ProjectSummary.fromJson(Map<String, dynamic>.from(p)))
            .toList()
        : const <ProjectSummary>[];

    final rawMeta = json['meta'];
    final meta = rawMeta is Map
        ? PageMeta.fromJson(Map<String, dynamic>.from(rawMeta))
        : PageMeta(total: projects.length, limit: projects.length, offset: 0);

    return ProjectListResult(
      projects: projects,
      meta: meta,
    );
  }
}
