import 'dashboard_summary.dart';
import 'finance_dashboard.dart';
import 'monthly_collection_point.dart';
import 'project_status_count.dart';
import 'project_summary.dart';

class DashboardMobileSummary {
  final Set<String> sections;
  final Map<String, String> errors;
  final List<int>? availableYears;
  final FinanceDashboard? finance;
  final List<MonthlyCollectionPoint>? collections;
  final List<ProjectStatusCount>? statusCounts;
  final DashboardSummary? summary;
  final List<ProjectSummary>? latestProjects;

  const DashboardMobileSummary({
    required this.sections,
    required this.errors,
    required this.availableYears,
    required this.finance,
    required this.collections,
    required this.statusCounts,
    required this.summary,
    required this.latestProjects,
  });

  bool hasSectionError(String sectionKey) => errors[sectionKey] != null;

  DashboardMobileSummary copyWith({
    Set<String>? sections,
    Map<String, String>? errors,
    List<int>? availableYears,
    FinanceDashboard? finance,
    List<MonthlyCollectionPoint>? collections,
    List<ProjectStatusCount>? statusCounts,
    DashboardSummary? summary,
    List<ProjectSummary>? latestProjects,
  }) {
    return DashboardMobileSummary(
      sections: sections ?? this.sections,
      errors: errors ?? this.errors,
      availableYears: availableYears ?? this.availableYears,
      finance: finance ?? this.finance,
      collections: collections ?? this.collections,
      statusCounts: statusCounts ?? this.statusCounts,
      summary: summary ?? this.summary,
      latestProjects: latestProjects ?? this.latestProjects,
    );
  }

  factory DashboardMobileSummary.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? toMap(dynamic value) {
      if (value is Map<String, dynamic>) return value;
      if (value is Map) return Map<String, dynamic>.from(value);
      return null;
    }

    final rawSections = json['sections'];
    final sections = rawSections is List
        ? rawSections
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toSet()
        : <String>{};

    final rawErrors = toMap(json['errors']);
    final errors = <String, String>{};
    if (rawErrors != null) {
      for (final entry in rawErrors.entries) {
        final key = entry.key.toString().trim();
        if (key.isEmpty) continue;
        errors[key] = entry.value?.toString() ?? 'Unexpected section error';
      }
    }

    final data = toMap(json['data']) ?? const <String, dynamic>{};

    List<int>? parseYears(dynamic raw) {
      if (raw is! List) return null;
      return raw
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .toList();
    }

    List<T>? parseList<T>(
      dynamic raw,
      T Function(Map<String, dynamic>) parser,
    ) {
      if (raw is! List) return null;
      return raw
          .whereType<Map>()
          .map((e) => parser(Map<String, dynamic>.from(e)))
          .toList();
    }

    final financeRaw = toMap(data['finance']);
    final summaryRaw = toMap(data['summary']);

    return DashboardMobileSummary(
      sections: sections,
      errors: errors,
      availableYears: parseYears(data['years']),
      finance:
          financeRaw != null ? FinanceDashboard.fromJson(financeRaw) : null,
      collections: parseList<MonthlyCollectionPoint>(
        data['collections'],
        MonthlyCollectionPoint.fromJson,
      ),
      statusCounts: parseList<ProjectStatusCount>(
        data['statusCounts'],
        ProjectStatusCount.fromJson,
      ),
      summary:
          summaryRaw != null ? DashboardSummary.fromJson(summaryRaw) : null,
      latestProjects: parseList<ProjectSummary>(
        data['latestProjects'],
        ProjectSummary.fromJson,
      ),
    );
  }
}
