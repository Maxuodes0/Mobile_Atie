import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final DashboardScreenController _controller;
  late final AnimationController _introController;
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
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
    _introController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
    if (!_controller.loading && !_introStarted) {
      _introStarted = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _introController.forward();
      });
    }
  }

  Future<void> _logout() async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await AppServices.session.logout();
  }

  Widget _reveal(int order, Widget child) {
    const totalItems = 6;
    final start = (order / totalItems) * 0.58;
    final end = (start + 0.42).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: _introController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.10),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
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

    final kpis = _controller.finance?.kpis;
    final userName = AppServices.session.user.value?.name.trim();

    return ColoredBox(
      color: AppTheme.primary,
      child: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () =>
              _controller.load(refreshYears: true, forceRefresh: true),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _reveal(
                0,
                _DashboardHero(
                  userName: userName == null || userName.isEmpty
                      ? 'مرحبًا بك'
                      : 'أهلًا، $userName',
                  netProfit: formatSar(kpis?.netProfit ?? '0'),
                  profitMargin: kpis?.profitMargin ?? '0',
                  onRefresh: () => _controller.load(
                    refreshYears: true,
                    forceRefresh: true,
                  ),
                  onLogout: _logout,
                ),
              ),
              _reveal(
                1,
                _DashboardFilterBand(
                  updating: _controller.updating,
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
              Container(
                decoration: const BoxDecoration(
                  color: AppTheme.pageBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_controller.error != null) ...[
                      ErrorBanner(message: _controller.error!),
                      const SizedBox(height: 12),
                    ],
                    _reveal(
                      2,
                      const _SectionHeading(
                        title: 'ملخص الأداء',
                        subtitle: 'أهم المؤشرات المالية للفترة المحددة',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_controller.finance == null && financeError != null)
                      DashboardSectionErrorCard(
                        title: 'تعذر تحميل مؤشرات المالية',
                        message: financeError,
                        onRetry: () => _controller.retrySections(
                          const [DashboardScreenController.sectionFinance],
                        ),
                      )
                    else
                      _reveal(
                        2,
                        _withSectionLoader(
                          loading: _controller.updatingSections.contains(
                            DashboardScreenController.sectionFinance,
                          ),
                          child: DashboardKpiGrid(kpis: kpis),
                        ),
                      ),
                    const SizedBox(height: 18),
                    if (_controller.collections.isEmpty &&
                        collectionsError != null)
                      DashboardSectionErrorCard(
                        title: 'تعذر تحميل بيانات الأموال المحصلة',
                        message: collectionsError,
                        onRetry: () => _controller.retrySections(
                          const [DashboardScreenController.sectionCollections],
                        ),
                      )
                    else
                      _reveal(
                        3,
                        _withSectionLoader(
                          loading: _controller.updatingSections.contains(
                            DashboardScreenController.sectionCollections,
                          ),
                          child: DashboardCollectionsCard(
                            kpis: kpis,
                            collections: _controller.collections,
                          ),
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
                      _reveal(
                        4,
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
                      ),
                    const SizedBox(height: 18),
                    if (_controller.latestProjects.isEmpty &&
                        latestProjectsError != null)
                      DashboardSectionErrorCard(
                        title: 'تعذر تحميل أحدث المشاريع',
                        message: latestProjectsError,
                        onRetry: () => _controller.retrySections(
                          const [
                            DashboardScreenController.sectionLatestProjects
                          ],
                        ),
                      )
                    else
                      _reveal(
                        5,
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
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  final String userName;
  final String netProfit;
  final String profitMargin;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const _DashboardHero({
    required this.userName,
    required this.netProfit,
    required this.profitMargin,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final margin = profitMargin.replaceAll('%', '').trim();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 26),
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'هذه نظرة سريعة على أعمالك',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              _HeroAction(
                icon: Icons.refresh_rounded,
                tooltip: 'تحديث البيانات',
                onPressed: onRefresh,
              ),
              const SizedBox(width: 8),
              _HeroAction(
                icon: Icons.logout_rounded,
                tooltip: 'تسجيل الخروج',
                onPressed: onLogout,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'صافي الربح',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                netProfit,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacitySafe(0.24),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              'هامش الربح $margin٪',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _HeroAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withOpacitySafe(0.12),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ),
      ),
    );
  }
}

class _DashboardFilterBand extends StatelessWidget {
  final bool updating;
  final Widget child;

  const _DashboardFilterBand({
    required this.updating,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.primary,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                SizedBox(width: 7),
                Text(
                  'الفترة الزمنية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            IgnorePointer(
              ignoring: updating,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 180),
                opacity: updating ? 0.58 : 1,
                child: child,
              ),
            ),
            InlineLoadingBar(visible: updating),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
      ],
    );
  }
}
