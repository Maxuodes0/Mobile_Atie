import 'package:flutter/material.dart';

import '../widgets/app_page_header.dart';
import '../widgets/error_banner.dart';
import '../widgets/inline_loading_bar.dart';
import '../widgets/period_filters_bar.dart';
import 'dashboard/dashboard_screen_controller.dart';
import 'dashboard/widgets/dashboard_collections_card.dart';
import 'dashboard/widgets/dashboard_kpi_grid.dart';
import 'dashboard/widgets/dashboard_latest_projects_section.dart';
import 'dashboard/widgets/dashboard_loading_skeleton.dart';
import 'dashboard/widgets/dashboard_projects_and_staff_row.dart';
import 'dashboard/widgets/dashboard_section_error_card.dart';
import 'project_details_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isActive;

  const DashboardScreen({
    super.key,
    required this.isActive,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DashboardScreenController();
    _controller.addListener(_onControllerChanged);
    _controller.setActive(widget.isActive);
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) {
      _controller.setActive(widget.isActive);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Widget _withSectionLoader({
    required bool loading,
    required Widget child,
  }) {
    if (!loading) return child;
    return Column(
      children: [
        const InlineLoadingBar(
          visible: true,
          padding: EdgeInsetsDirectional.only(bottom: 8),
        ),
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.loading) {
      return const DashboardLoadingSkeleton();
    }

    final financeError =
        _controller.sectionErrors[DashboardScreenController.sectionFinance];
    final collectionsError =
        _controller.sectionErrors[DashboardScreenController.sectionCollections];
    final latestProjectsError = _controller
        .sectionErrors[DashboardScreenController.sectionLatestProjects];
    final projectsAndStaffError = _controller.combinedError(
      const [
        DashboardScreenController.sectionStatusCounts,
        DashboardScreenController.sectionSummary,
      ],
    );

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () =>
            _controller.load(refreshYears: true, forceRefresh: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const AppPageHeader(
              title: 'لوحة التحكم',
              subtitle: 'نظرة سريعة على أداء المشاريع',
            ),
            const SizedBox(height: 14),
            IgnorePointer(
              ignoring: _controller.updating,
              child: Opacity(
                opacity: _controller.updating ? 0.65 : 1,
                child: PeriodFiltersBar(
                  year: _controller.year,
                  quarter: _controller.quarter,
                  availableYears: List<int>.from(_controller.availableYears),
                  onYearChanged: (y) {
                    _controller.updateSharedFilter(
                      year: y,
                      quarter: y == null ? null : _controller.quarter,
                    );
                  },
                  onQuarterChanged: (q) {
                    _controller.updateSharedFilter(
                      year: _controller.year,
                      quarter: _controller.year == null ? null : q,
                    );
                  },
                ),
              ),
            ),
            InlineLoadingBar(visible: _controller.updating),
            const SizedBox(height: 16),
            if (_controller.error != null) ...[
              ErrorBanner(message: _controller.error!),
              const SizedBox(height: 12),
            ],
            if (_controller.finance == null && financeError != null)
              DashboardSectionErrorCard(
                title: 'تعذر تحميل مؤشرات المالية',
                message: financeError,
                onRetry: () => _controller.retrySections(
                  const [DashboardScreenController.sectionFinance],
                ),
              )
            else
              _withSectionLoader(
                loading: _controller.updatingSections.contains(
                  DashboardScreenController.sectionFinance,
                ),
                child: DashboardKpiGrid(kpis: _controller.finance?.kpis),
              ),
            const SizedBox(height: 18),
            if (_controller.collections.isEmpty && collectionsError != null)
              DashboardSectionErrorCard(
                title: 'تعذر تحميل بيانات الأموال المحصلة',
                message: collectionsError,
                onRetry: () => _controller.retrySections(
                  const [DashboardScreenController.sectionCollections],
                ),
              )
            else
              _withSectionLoader(
                loading: _controller.updatingSections.contains(
                  DashboardScreenController.sectionCollections,
                ),
                child: DashboardCollectionsCard(
                  kpis: _controller.finance?.kpis,
                  collections: _controller.collections,
                ),
              ),
            const SizedBox(height: 12),
            if (_controller.summary == null &&
                _controller.statusCounts.isEmpty &&
                projectsAndStaffError != null)
              DashboardSectionErrorCard(
                title: 'تعذر تحميل إحصاءات المشاريع والموظفين',
                message: projectsAndStaffError,
                onRetry: () => _controller.retrySections(
                  const [
                    DashboardScreenController.sectionStatusCounts,
                    DashboardScreenController.sectionSummary,
                  ],
                ),
              )
            else
              _withSectionLoader(
                loading: _controller.updatingSections.contains(
                      DashboardScreenController.sectionStatusCounts,
                    ) ||
                    _controller.updatingSections.contains(
                      DashboardScreenController.sectionSummary,
                    ),
                child: DashboardProjectsAndStaffRow(
                  summary: _controller.summary,
                  statusCounts: _controller.statusCounts,
                ),
              ),
            const SizedBox(height: 18),
            if (_controller.latestProjects.isEmpty &&
                latestProjectsError != null)
              DashboardSectionErrorCard(
                title: 'تعذر تحميل أحدث المشاريع',
                message: latestProjectsError,
                onRetry: () => _controller.retrySections(
                  const [DashboardScreenController.sectionLatestProjects],
                ),
              )
            else
              _withSectionLoader(
                loading: _controller.updatingSections.contains(
                  DashboardScreenController.sectionLatestProjects,
                ),
                child: DashboardLatestProjectsSection(
                  projects: _controller.latestProjects,
                  onOpen: (project) {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProjectDetailsScreen(
                          projectId: project.id,
                          initial: project,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
