import 'package:flutter/material.dart';

import '../../../data/models/dashboard_summary.dart';
import '../../../data/models/project_status_count.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';

class DashboardProjectsAndStaffRow extends StatelessWidget {
  final DashboardSummary? summary;
  final List<ProjectStatusCount> statusCounts;

  const DashboardProjectsAndStaffRow({
    super.key,
    required this.summary,
    required this.statusCounts,
  });

  @override
  Widget build(BuildContext context) {
    final totalProjects = statusCounts.fold<int>(0, (a, s) => a + s.count);
    final clientCount = summary?.clientCount ?? 0;
    final operatingCompanyCount = summary?.operatingCompanyCount ?? 0;

    return Column(
      children: [
        _ProjectCountCard(totalProjects: totalProjects),
        const SizedBox(height: 12),
        _BusinessNetworkCard(
          clientCount: clientCount,
          operatingCompanyCount: operatingCompanyCount,
        ),
      ],
    );
  }
}

class _ProjectCountCard extends StatelessWidget {
  final int totalProjects;

  const _ProjectCountCard({required this.totalProjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: AppTheme.dashboardMint,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(en: 'Project portfolio', ar: 'محفظة المشاريع'),
            style: const TextStyle(
              color: AppTheme.dashboardInk,
              fontFamily: AppTheme.dashboardFontFamily,
              fontFamilyFallback: AppTheme.currencyFontFallback,
              fontSize: 28,
              height: 0.95,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  context.tr(
                    en: 'Projects in the selected period',
                    ar: 'مشاريع الفترة المحددة',
                  ),
                  style: TextStyle(
                    color: AppTheme.dashboardInk.withOpacitySafe(0.5),
                    fontFamily: AppTheme.dashboardFontFamily,
                    fontFamilyFallback: AppTheme.currencyFontFallback,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                totalProjects.toString(),
                style: const TextStyle(
                  color: AppTheme.dashboardInk,
                  fontFamily: AppTheme.dashboardFontFamily,
                  fontSize: 84,
                  height: 0.74,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessNetworkCard extends StatelessWidget {
  final int clientCount;
  final int operatingCompanyCount;

  const _BusinessNetworkCard({
    required this.clientCount,
    required this.operatingCompanyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: AppTheme.dashboardGraphite,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(
              en: 'Business network',
              ar: 'شبكة الأعمال',
            ),
            style: const TextStyle(
              color: AppTheme.dashboardInk,
              fontFamily: AppTheme.dashboardFontFamily,
              fontFamilyFallback: AppTheme.currencyFontFallback,
              fontSize: 28,
              height: 0.95,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _NetworkMetric(
                  label: context.tr(en: 'Clients', ar: 'العملاء'),
                  value: clientCount,
                ),
              ),
              Container(
                width: 1,
                height: 82,
                color: AppTheme.dashboardInk.withOpacitySafe(0.18),
              ),
              Expanded(
                child: _NetworkMetric(
                  label: context.tr(
                    en: 'Operators',
                    ar: 'الشركات المشغلة',
                  ),
                  value: operatingCompanyCount,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkMetric extends StatelessWidget {
  final String label;
  final int value;

  const _NetworkMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: AppTheme.dashboardInk,
            fontFamily: AppTheme.dashboardFontFamily,
            fontSize: 59,
            height: 0.86,
            fontWeight: FontWeight.w900,
            letterSpacing: -2,
          ),
        ),
        const SizedBox(height: 11),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.dashboardInk.withOpacitySafe(0.62),
            fontFamily: AppTheme.dashboardFontFamily,
            fontFamilyFallback: AppTheme.currencyFontFallback,
            fontSize: 17,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
