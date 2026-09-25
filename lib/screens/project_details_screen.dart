import 'package:flutter/material.dart';
import '../data/models/project_details.dart';
import '../data/models/project_collection.dart';
import '../data/models/project_summary.dart';
import '../data/models/project_team_member.dart';
import '../data/models/project_role_label.dart';
import '../l10n/app_localizations.dart';
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
  static const String _projectManagerRoleLabel = 'Project Manager';

  bool _loading = true;
  String? _error;
  String? _teamError;
  String? _collectionsError;
  ProjectDetails? _project;
  List<ProjectTeamMember> _team = const [];
  List<ProjectRoleLabel> _roleLabels = const [];
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

    final remaining =
        team.where((m) => m.userId.trim() != managerId).toList(growable: false);

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

    final rolesFuture = _capture(
      AppServices.projects.listProjectRoles(
        cacheTtl: _detailsCacheTtl,
        forceRefresh: forceRefresh,
      ),
    );

    final results = await Future.wait<dynamic>([
      projectFuture,
      teamFuture,
      collectionsFuture,
      rolesFuture,
    ]);

    final projectResult = results[0] as _AsyncLoad<ProjectDetails>;
    final teamResult = results[1] as _AsyncLoad<List<ProjectTeamMember>>;
    final collectionsResult =
        results[2] as _AsyncLoad<List<ProjectCollectionItem>>;
    final rolesResult = results[3] as _AsyncLoad<List<ProjectRoleLabel>>;

    if (!mounted) return;
    setState(() {
      _project = projectResult.value;
      _error = projectResult.error;
      _team = _withProjectManagerFirst(
        projectResult.value,
        teamResult.value ?? const <ProjectTeamMember>[],
      );
      _collections = collectionsResult.value ?? const <ProjectCollectionItem>[];
      _roleLabels = rolesResult.value ?? const <ProjectRoleLabel>[];
      _teamError = teamResult.error;
      _collectionsError = collectionsResult.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallback = widget.initial;
    final project = _project;

    final title = project?.name ??
        fallback?.name ??
        context.tr(en: 'Project details', ar: 'تفاصيل المشروع');
    final totalCollected =
        _collections.fold<double>(0, (a, c) => a + c.collectedAmount);
    final projectCost = _resolveProjectCost(project, _team);

    Widget tabBody(List<Widget> children) {
      return RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: children,
        ),
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            indicatorColor: Theme.of(context).colorScheme.secondary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: [
              Tab(
                icon: const Icon(Icons.info_outline_rounded, size: 19),
                text: context.tr(en: 'Overview', ar: 'نظرة عامة'),
              ),
              Tab(
                icon: const Icon(Icons.groups_outlined, size: 19),
                text: context.tr(en: 'Team', ar: 'الفريق'),
              ),
              Tab(
                icon: const Icon(Icons.receipt_long_outlined, size: 19),
                text: context.tr(en: 'Costs', ar: 'التكاليف'),
              ),
              Tab(
                icon: const Icon(Icons.payments_outlined, size: 19),
                text: context.tr(en: 'Collections', ar: 'التحصيل'),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              tabBody([
                if (_error != null) ...[
                  ErrorBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                ProjectDetailsHeaderCard(
                  imageUrl: project?.projectImage ?? fallback?.projectImage,
                  name: project?.name ?? fallback?.name ?? '',
                  client: project?.clientName ?? fallback?.clientName,
                  operatingCompanyName: project?.operatingCompanyName,
                  operatingCompanyNameEn: project?.operatingCompanyNameEn,
                  status: project?.status ?? fallback?.status ?? '',
                  projectType: project?.projectType ?? 'PAID',
                  startDate: project?.startDate,
                  dueDate: project?.dueDate,
                  loading: _projectLoading,
                ),
                const SizedBox(height: 14),
                ProjectDetailsSectionCard(
                  title: context.tr(en: 'Project value', ar: 'قيمة المشروع'),
                  child: ProjectValueSection(
                    loading: _projectLoading,
                    valueWithoutVat: project?.projectValueWithoutVat,
                    valueWithVat: project?.projectValueWithVat,
                  ),
                ),
              ]),
              tabBody([
                ProjectDetailsSectionCard(
                  title: context.tr(en: 'Project team', ar: 'فريق المشروع'),
                  child: ProjectTeamSection(
                    loading: _projectLoading && _team.isEmpty,
                    error: _teamError,
                    items: _team,
                    roleLabels: _roleLabels,
                  ),
                ),
              ]),
              tabBody([
                ProjectDetailsSectionCard(
                  title: context.tr(en: 'Project costs', ar: 'تكاليف المشروع'),
                  child: ProjectCostSection(
                    loading: _projectLoading && _team.isEmpty,
                    totalCost: projectCost,
                  ),
                ),
              ]),
              tabBody([
                ProjectDetailsSectionCard(
                  title: context.tr(en: 'Collections', ar: 'التحصيل'),
                  child: ProjectCollectionsSection(
                    loading: _projectLoading && _collections.isEmpty,
                    error: _collectionsError,
                    totalCollected: totalCollected,
                    items: _collections,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
