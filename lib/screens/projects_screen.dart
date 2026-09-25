import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../l10n/app_localizations.dart';
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
import '../widgets/ios_select_field.dart';
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
  String _statusFilter = 'ALL';
  String _collectionFilter = 'ALL';
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
    final q = _search.text.trim().toLowerCase();
    return _projects.where((p) {
      if (_statusFilter != 'ALL' && p.status != _statusFilter) return false;
      final collection = (p.collectionStatus ?? '').trim().toUpperCase();
      if (_collectionFilter != 'ALL' && collection != _collectionFilter) {
        return false;
      }
      if (q.isEmpty) return true;
      return p.name.toLowerCase().contains(q) ||
          (p.clientName ?? '').toLowerCase().contains(q) ||
          (p.operatingCompanyName ?? '').toLowerCase().contains(q);
    }).toList(growable: false);
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 116),
          children: [
            AppPageHeader(
              title: context.tr(en: 'Projects', ar: 'المشاريع'),
              subtitle: context.tr(
                en: 'Track projects and team progress',
                ar: 'تابع تقدم المشاريع وأعضاء الفريق',
              ),
              showLogout: false,
            ),
            InlineLoadingBar(visible: _updating),
            const SizedBox(height: 16),
            if (_error != null) ...[
              ErrorBanner(message: _error!),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText:
                    context.tr(en: 'Search projects', ar: 'ابحث عن مشروع'),
                prefixIcon: const Icon(Icons.search, size: 20),
                prefixIconColor: AppTheme.muted,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProjectFilterDropdown(
                    value: _statusFilter,
                    label: context.tr(en: 'Status', ar: 'الحالة'),
                    items: const [
                      'ALL',
                      'ON_TRACK',
                      'AT_RISK',
                      'OFF_TRACK',
                      'COMPLETED',
                      'CANCELLED',
                    ],
                    itemLabel: (value) => value == 'ALL'
                        ? context.tr(en: 'All statuses', ar: 'كل الحالات')
                        : projectStatusLabel(
                            value,
                            languageCode:
                                Localizations.localeOf(context).languageCode,
                          ),
                    onChanged: (value) => setState(() => _statusFilter = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ProjectFilterDropdown(
                    value: _collectionFilter,
                    label: context.tr(en: 'Collection', ar: 'التحصيل'),
                    items: const [
                      'ALL',
                      'FULLY_COLLECTED',
                      'PARTIALLY_COLLECTED',
                      'NOT_COLLECTED',
                    ],
                    itemLabel: (value) => value == 'ALL'
                        ? context.tr(en: 'All collections', ar: 'كل التحصيلات')
                        : collectionStatusLabel(
                            value,
                            languageCode:
                                Localizations.localeOf(context).languageCode,
                          ),
                    onChanged: (value) =>
                        setState(() => _collectionFilter = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_filtered.isEmpty)
              Text(context.tr(en: 'No projects found', ar: 'لا توجد مشاريع'),
                  style: const TextStyle(color: AppTheme.muted, fontSize: 14))
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
                      child: Text(
                        context.tr(en: 'Load more', ar: 'تحميل المزيد'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
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
    final languageCode = Localizations.localeOf(context).languageCode;
    final statusLabel = projectStatusLabel(
      project.status,
      languageCode: languageCode,
    );
    final statusColor = projectStatusColor(project.status);
    final collectionStatus = project.collectionStatus?.trim();
    final hasCollectionStatus =
        collectionStatus != null && collectionStatus.isNotEmpty;
    final collectionLabel = hasCollectionStatus
        ? collectionStatusLabel(collectionStatus, languageCode: languageCode)
        : null;
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
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.border),
          ),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if ((project.operatingCompanyName ?? '')
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.business_outlined,
                                size: 13,
                                color: AppTheme.muted,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  project.operatingCompanyName!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.muted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (project.projectValueWithoutVat != null) ...[
                          const SizedBox(height: 7),
                          Text(
                            context.tr(
                              en: 'Value: ${formatSar(project.projectValueWithoutVat!.toStringAsFixed(2))}',
                              ar: 'القيمة: ${formatSar(project.projectValueWithoutVat!.toStringAsFixed(2))}',
                            ),
                            style: const TextStyle(
                              color: AppTheme.ink,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          project.clientName ??
                              context.tr(en: 'No client', ar: 'بدون عميل'),
                          style: const TextStyle(
                            color: AppTheme.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.muted),
                          ],
                        ),
                        if (project.totalCollectedAmount != null &&
                            project.totalCollectedAmount! > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            context.tr(
                              en: 'Collected: ${formatSar(project.totalCollectedAmount!.toStringAsFixed(2))}',
                              ar: 'المحصل: ${formatSar(project.totalCollectedAmount!.toStringAsFixed(2))}',
                            ),
                            style: const TextStyle(
                              color: AppTheme.muted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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

class _ProjectFilterDropdown extends StatelessWidget {
  final String value;
  final String label;
  final List<String> items;
  final String Function(String value) itemLabel;
  final ValueChanged<String> onChanged;

  const _ProjectFilterDropdown({
    required this.value,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IosSelectField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 11, 10, 11),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                itemLabel(item),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(growable: false),
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
