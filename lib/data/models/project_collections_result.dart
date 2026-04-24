import 'page_meta.dart';
import 'project_collection.dart';

class ProjectCollectionsResult {
  final List<ProjectCollectionItem> collections;
  final PageMeta meta;

  const ProjectCollectionsResult({
    required this.collections,
    required this.meta,
  });

  factory ProjectCollectionsResult.fromJson(Map<String, dynamic> json) {
    final raw = json['collections'];
    final items = raw is List
        ? raw
            .whereType<Map>()
            .map((e) => ProjectCollectionItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : const <ProjectCollectionItem>[];

    final metaRaw = json['meta'];
    final meta = metaRaw is Map ? PageMeta.fromJson(Map<String, dynamic>.from(metaRaw)) : const PageMeta(total: 0, limit: 0, offset: 0);

    return ProjectCollectionsResult(collections: items, meta: meta);
  }
}

