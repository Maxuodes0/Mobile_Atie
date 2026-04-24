import 'package:flutter/material.dart';
import '../data/models/project_details.dart';
import '../data/models/project_collection.dart';
import '../data/models/project_summary.dart';
import '../data/models/project_team_member.dart';
import '../services/app_services.dart';
import '../widgets/error_banner.dart';
import 'project_details/widgets/project_details_sections.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  final ProjectSummary? initial;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.initial,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _AsyncLoad<T> {
  final T? value;
  final String? error;

  const _AsyncLoad({
    this.value,
    this.error,
  });
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  static const Duration _detailsCacheTtl = Duration(seconds: 45);
  static const String _projectManagerRoleLabel = 'مدير المشروع';

  bool _loading = true;
  String? _error;
  String? _teamError;
  String? _collectionsError;
  ProjectDetails? _project;
  List<ProjectTeamMember> _team = const [];
  List<ProjectCollectionItem> _collections = const [];

  bool get _projectLoading => _loading && _project == null;

  Future<_AsyncLoad<T>> _capture<T>(Future<T> future) async {
    try {
      return _AsyncLoad<T>(value: await future);
    } catch (e) {
      return _AsyncLoad<T>(error: e.toString());
    }
  }

  double? _resolveProjectCost(
    ProjectDetails? project,
    List<ProjectTeamMember> team,
  ) {
    if (project?.budgetSpent != null) {
      return project!.budgetSpent;
    }
    final computed = team.fold<double>(0, (sum, member) {
      final direct = member.totalAmount;
      if (direct != null) return sum + direct;
      final days = member.estimatedDays;
      final rate = member.dailyRate;
      if (days != null && rate != null) return sum + (days * rate);
      return sum;
    });
    return computed > 0 ? computed : null;
  }

  List<ProjectTeamMember> _withProjectManagerFirst(
    ProjectDetails? project,
    List<ProjectTeamMember> team,
  ) {
    final manager = project?.projectManager;
    final managerId = (manager?.id ?? '').trim();
    if (managerId.isEmpty) return team;

    ProjectTeamMember? existing;
    for (final member in team) {
      if (member.userId.trim() == managerId) {
        existing = member;
        break;
      }
    }

    final managerRow = existing != null
        ? ProjectTeamMember(
            userId: existing.userId,
            projectRole: _projectManagerRoleLabel,
            isPaid: existing.isPaid,
            estimatedDays: existing.estimatedDays,
            actualDays: existing.actualDays,
            dailyRate: existing.dailyRate,
            totalAmount: existing.totalAmount,
            totalPaid: existing.totalPaid,
            user: existing.user,
          )
        : ProjectTeamMember(
            userId: managerId,
            projectRole: _projectManagerRoleLabel,
            isPaid: true,
            estimatedDays: null,
            actualDays: null,
            dailyRate: null,
            totalAmount: null,
            totalPaid: null,
            user: ProjectTeamUser(
              id: managerId,
              name: (manager?.name ?? '').trim(),
              role: 'PROJECT_MANAGER',
              profileImage: null,
            ),
          );

    final remaining = team
        .where((m) => m.userId.trim() != managerId)
        .toList(growable: false);

    return <ProjectTeamMember>[managerRow, ...remaining];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      _teamError = null;
      _collectionsError = null;
    });

    final projectFuture = _capture(
      AppServices.projects.getProject(
        projectId: widget.projectId,
        cacheTtl: _detailsCacheTtl,
        forceRefresh: forceRefresh,
      ),
    );

    final teamFuture = _capture(
      AppServices.projects.listTeam(
        projectId: widget.projectId,
        cacheTtl: _detailsCacheTtl,
        forceRefresh: forceRefresh,
      ),
    );

    final collectionsFuture = _capture(
      AppServices.projects
          .listCollections(
            projectId: widget.projectId,
            cacheTtl: _detailsCacheTtl,
            forceRefresh: forceRefresh,
          )
          .then((value) => value.collections),
    );

    final results = await Future.wait<dynamic>([
      projectFuture,
      teamFuture,
      collectionsFuture,
    ]);

    final projectResult = results[0] as _AsyncLoad<ProjectDetails>;
    final teamResult = results[1] as _AsyncLoad<List<ProjectTeamMember>>;
    final collectionsResult =
        results[2] as _AsyncLoad<List<ProjectCollectionItem>>;

    if (!mounted) return;
    setState(() {
      _project = projectResult.value;
      _error = projectResult.error;
      _team = _withProjectManagerFirst(
        projectResult.value,
        teamResult.value ?? const <ProjectTeamMember>[],
      );
      _collections = collectionsResult.value ?? const <ProjectCollectionItem>[];
      _teamError = teamResult.error;
      _collectionsError = collectionsResult.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.initial;
    final project = _project;

    final title = project?.name ?? fallback?.name ?? 'تفاصيل المشروع';
    final totalCollected =
        _collections.fold<double>(0, (a, c) => a + c.collectedAmount);
    final projectCost = _resolveProjectCost(project, _team);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _load(forceRefresh: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_error != null) ...[
                ErrorBanner(message: _error!),
                const SizedBox(height: 12),
              ],
              ProjectDetailsHeaderCard(
                imageUrl: project?.projectImage ?? fallback?.projectImage,
                name: project?.name ?? fallback?.name ?? '',
                client: project?.clientName ?? fallback?.clientName,
                status: project?.status ?? fallback?.status ?? '',
                createdAt: project?.createdAt ?? fallback?.createdAt,
                startDate: project?.startDate,
                dueDate: project?.dueDate,
                loading: _projectLoading,
              ),
              const SizedBox(height: 14),
              ProjectDetailsSectionCard(
                title: 'فريق المشروع',
                child: ProjectTeamSection(
                  loading: _projectLoading && _team.isEmpty,
                  error: _teamError,
                  items: _team,
                ),
              ),
              const SizedBox(height: 14),
              ProjectDetailsSectionCard(
                title: 'تكاليف المشروع',
                child: ProjectCostSection(
                  loading: _projectLoading && _team.isEmpty,
                  totalCost: projectCost,
                ),
              ),
              const SizedBox(height: 14),
              ProjectDetailsSectionCard(
                title: 'التحصيل',
                child: ProjectCollectionsSection(
                  loading: _projectLoading && _collections.isEmpty,
                  error: _collectionsError,
                  totalCollected: totalCollected,
                  items: _collections,
                ),
              ),
              const SizedBox(height: 14),
              if (_projectLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
