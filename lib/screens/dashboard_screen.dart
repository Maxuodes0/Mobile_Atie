import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../l10n/app_localizations.dart';
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
      color: AppTheme.dashboardCanvas,
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
                      ? context.tr(en: 'Welcome', ar: 'مرحبًا بك')
                      : context.tr(
                          en: 'Hello, $userName', ar: 'أهلًا، $userName'),
                  netProfit: formatSar(kpis?.netProfit),
                  onRefresh: () => _controller.load(
                    refreshYears: true,
                    forceRefresh: true,
                  ),
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
                color: AppTheme.dashboardCanvas,
                padding: const EdgeInsets.fromLTRB(18, 26, 18, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_controller.error != null) ...[
                      ErrorBanner(message: _controller.error!),
                      const SizedBox(height: 12),
                    ],
                    _reveal(
                      2,
                      _SectionHeading(
                        title: context.tr(
                            en: 'Business overview', ar: 'نظرة عامة'),
                        subtitle: context.tr(
                          en: 'The numbers that matter for this period',
                          ar: 'أهم أرقام الأعمال للفترة المحددة',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_controller.finance == null && financeError != null)
                      DashboardSectionErrorCard(
                        title: context.tr(
                          en: 'Could not load financial indicators',
                          ar: 'تعذر تحميل مؤشرات المالية',
                        ),
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
                        title: context.tr(
                          en: 'Could not load collection data',
                          ar: 'تعذر تحميل بيانات الأموال المحصلة',
                        ),
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
                        title: context.tr(
                          en: 'Could not load project and business statistics',
                          ar: 'تعذر تحميل إحصاءات المشاريع وشبكة الأعمال',
                        ),
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
                        title: context.tr(
                          en: 'Could not load latest projects',
                          ar: 'تعذر تحميل أحدث المشاريع',
                        ),
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
  final VoidCallback onRefresh;

  const _DashboardHero({
    required this.userName,
    required this.netProfit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final month = context.tr(
      en: const [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ][now.month - 1],
      ar: const [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ][now.month - 1],
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
      color: AppTheme.dashboardCanvas,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.dashboardInk.withOpacitySafe(0.55),
                        fontFamily: AppTheme.dashboardFontFamily,
                        fontFamilyFallback: AppTheme.currencyFontFallback,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr(
                        en: 'Aite\nBusiness Insights',
                        ar: 'آيت\nمؤشرات الأعمال',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.dashboardInk,
                        fontFamily: AppTheme.dashboardFontFamily,
                        fontFamilyFallback: AppTheme.currencyFontFallback,
                        fontSize: 43,
                        height: 0.82,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${now.day} $month',
                      style: const TextStyle(
                        color: AppTheme.dashboardMuted,
                        fontFamily: AppTheme.dashboardFontFamily,
                        fontFamilyFallback: AppTheme.currencyFontFallback,
                        fontSize: 30,
                        height: 0.95,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _HeroAction(
                icon: Icons.refresh_rounded,
                tooltip: context.tr(en: 'Refresh data', ar: 'تحديث البيانات'),
                onPressed: onRefresh,
              ),
            ],
          ),
          const SizedBox(height: 42),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: BoxDecoration(
              color: AppTheme.dashboardInk,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(en: 'Net profit', ar: 'صافي الربح'),
                        style: const TextStyle(
                          color: AppTheme.dashboardPaper,
                          fontFamily: AppTheme.dashboardFontFamily,
                          fontFamilyFallback: AppTheme.currencyFontFallback,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 9),
                      SizedBox(
                        height: 42,
                        child: FittedBox(
                          alignment: AlignmentDirectional.centerStart,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            netProfit,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              color: AppTheme.dashboardMint,
                              fontFamily: AppTheme.dashboardFontFamily,
                              fontFamilyFallback: AppTheme.currencyFontFallback,
                              fontSize: 42,
                              height: 0.9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        color: AppTheme.dashboardPaper,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, color: AppTheme.dashboardInk, size: 24),
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
      color: AppTheme.dashboardCanvas,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.dashboardInk,
                  size: 21,
                ),
                const SizedBox(width: 7),
                Text(
                  context.tr(en: 'Time period', ar: 'الفترة الزمنية'),
                  style: const TextStyle(
                    color: AppTheme.dashboardInk,
                    fontFamily: AppTheme.dashboardFontFamily,
                    fontFamilyFallback: AppTheme.currencyFontFallback,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
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
            color: AppTheme.dashboardInk,
            fontFamily: AppTheme.dashboardFontFamily,
            fontFamilyFallback: AppTheme.currencyFontFallback,
            fontSize: 31,
            height: 0.95,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.dashboardMuted,
            fontFamily: AppTheme.dashboardFontFamily,
            fontFamilyFallback: AppTheme.currencyFontFallback,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
