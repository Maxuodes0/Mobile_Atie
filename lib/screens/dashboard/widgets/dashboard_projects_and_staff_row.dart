import 'package:flutter/material.dart';

import '../../../data/models/dashboard_summary.dart';
import '../../../data/models/project_status_count.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/role_bar_chart.dart';
import 'dashboard_chart_card.dart';

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

    final roleCounts = <String, int>{
      for (final rc in (summary?.userRoleCounts ?? const [])) rc.role: rc.count,
    };
    final employees = roleCounts['EMPLOYEE'] ?? 0;
    final freelancers = roleCounts['FREELANCER'] ?? 0;
    final managers = (roleCounts['PROGRAM_MANAGER'] ?? 0) +
        (roleCounts['PROJECT_MANAGER'] ?? 0);
    final totalStaff = employees + freelancers + managers;

    return Column(
      children: [
        _ProjectsOverviewCard(
          totalProjects: totalProjects,
        ),
        const SizedBox(height: 12),
        DashboardChartCard(
          title: 'عدد الموظفين',
          value: totalStaff.toString(),
          subtitle: 'حسب الدور',
          chart: SizedBox(
            height: 140,
            child: RoleBarChart(
              items: [
                RoleBarDatum(
                  label: 'موظف',
                  value: employees,
                  color: const Color(0xFF3B82F6),
                ),
                RoleBarDatum(
                  label: 'فريلانسر',
                  value: freelancers,
                  color: const Color(0xFFF59E0B),
                ),
                RoleBarDatum(
                  label: 'إدارة',
                  value: managers,
                  color: const Color(0xFF111827),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectsOverviewCard extends StatelessWidget {
  static const Color _accent = Color(0xFF527BFF);

  final int totalProjects;

  const _ProjectsOverviewCard({required this.totalProjects});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppTheme.border.withOpacitySafe(0.75)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F1115),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _accent.withOpacitySafe(0.12),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.work_outline_rounded,
                        color: _accent,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'عدد المشاريع',
                            style: TextStyle(
                              color: AppTheme.ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'حسب الحالة',
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                totalProjects.toString(),
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontSize: 38,
                  height: 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 34),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: totalProjects > 0 ? 1 : 0,
              minHeight: 7,
              color: _accent,
              backgroundColor: _accent.withOpacitySafe(0.12),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'إجمالي المشاريع',
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$totalProjects مشروع',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
