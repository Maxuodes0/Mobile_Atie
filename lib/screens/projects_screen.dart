import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/error_banner.dart';
import '../services/app_services.dart';
import '../data/models/page_meta.dart';
import '../data/models/project_summary.dart';
import '../utils/project_status.dart';
import '../utils/collection_status.dart';
import '../utils/formatters.dart';
import '../utils/async_request_guard_mixin.dart';
import '../widgets/project_image.dart';
import '../widgets/app_page_header.dart';
import '../widgets/inline_loading_bar.dart';
import 'project_details_screen.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with AsyncRequestGuardMixin<ProjectsScreen> {
  static const int _pageSize = 24;

  final _search = TextEditingController();
  bool _loading = true;
  bool _updating = false;
  bool _loadingMore = false;
  String? _error;
  List<ProjectSummary> _projects = const [];
  PageMeta _meta = const PageMeta(total: 0, limit: _pageSize, offset: 0);

  @override
  void initState() {
    super.initState();
    _load(reset: true);
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasMore => _projects.length < _meta.total;

  Future<void> _load({
    required bool reset,
    bool forceRefresh = false,
  }) async {
    final ticket = nextRequestTicket();

    if (reset) {
      final initial = _projects.isEmpty;
      setState(() {
        _error = null;
        _loadingMore = false;
        if (initial) {
          _loading = true;
          _updating = false;
        } else {
          _loading = false;
          _updating = true;
        }
      });
    } else {
      if (_loading || _updating || _loadingMore || !_hasMore) return;
      setState(() {
        _loadingMore = true;
        _error = null;
      });
    }

    List<ProjectSummary> projects = _projects;
    PageMeta meta = _meta;
    String? error;

    try {
      final result = await AppServices.projects.listProjectsPage(
        limit: _pageSize,
        offset: reset ? 0 : _projects.length,
        cacheTtl: const Duration(seconds: 45),
        forceRefresh: forceRefresh,
      );

      projects = reset ? result.projects : [..._projects, ...result.projects];
      meta = PageMeta(
        total: result.meta.total,
        limit: result.meta.limit <= 0 ? _pageSize : result.meta.limit,
        offset: projects.length,
      );
    } catch (e) {
      error = e.toString();
    }

    if (isRequestStale(ticket)) return;
    setState(() {
      _projects = projects;
      _meta = meta;
      _error = error;
      _loading = false;
      _updating = false;
      _loadingMore = false;
    });
  }

  List<ProjectSummary> get _filtered {
    final q = _search.text.trim();
    if (q.isEmpty) return _projects;
    return _projects
        .where((p) => p.name.toLowerCase().contains(q.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SafeArea(child: Center(child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _load(reset: true, forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppPageHeader(
              title: 'المشاريع',
              subtitle: 'تابع تقدم المشاريع وأعضاء الفريق',
            ),
            InlineLoadingBar(visible: _updating),
            const SizedBox(height: 16),
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                hintText: 'ابحث عن مشروع',
                prefixIcon: Icon(Icons.search, size: 20),
                prefixIconColor: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 16),
            if (_filtered.isEmpty)
              const Text('لا توجد مشاريع',
                  style: TextStyle(color: AppTheme.muted, fontSize: 12))
            else
              ..._filtered.map(
                (p) => _ProjectCard(
                  project: p,
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProjectDetailsScreen(
                          projectId: p.id,
                          initial: p,
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (_hasMore) ...[
              const SizedBox(height: 12),
              _loadingMore
                  ? const Center(child: CircularProgressIndicator())
                  : OutlinedButton(
                      onPressed: () => _load(reset: false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: AppTheme.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'تحميل المزيد',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectSummary project;
  final VoidCallback onOpen;

  const _ProjectCard({
    required this.project,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = projectStatusLabel(project.status);
    final statusColor = projectStatusColor(project.status);
    final collectionStatus = project.collectionStatus?.trim();
    final hasCollectionStatus =
        collectionStatus != null && collectionStatus.isNotEmpty;
    final collectionLabel =
        hasCollectionStatus ? collectionStatusLabel(collectionStatus) : null;
    final collectionColor = hasCollectionStatus
        ? collectionStatusColor(collectionStatus)
        : AppTheme.muted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.border),
          ),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProjectImage(
                    url: project.projectImage,
                    width: 64,
                    height: 64,
                    borderRadius: BorderRadius.circular(14),
                    iconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          project.clientName ?? 'بدون عميل',
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _ProjectStatusBadge(
                                    label: statusLabel,
                                    color: statusColor,
                                  ),
                                  if (collectionLabel != null)
                                    _ProjectStatusBadge(
                                      label: collectionLabel,
                                      color: collectionColor,
                                      icon: Icons.payments_outlined,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Directionality(
                              textDirection: TextDirection.ltr,
                              child: Icon(
                                Icons.chevron_left,
                                color: AppTheme.muted,
                              ),
                            ),
                          ],
                        ),
                        if (project.totalCollectedAmount != null &&
                            project.totalCollectedAmount! > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            'المحصل: ${formatSar(project.totalCollectedAmount!.toStringAsFixed(2))}',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _ProjectStatusBadge({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacitySafe(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
