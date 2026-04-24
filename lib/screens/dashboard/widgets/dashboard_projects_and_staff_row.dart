import 'package:flutter/material.dart';

import '../../../data/models/dashboard_summary.dart';
import '../../../data/models/project_status_count.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/project_status.dart';
import '../../../widgets/mini_donut_chart.dart';
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
    final donutSegments = statusCounts
        .where((s) => s.count > 0)
        .map(
          (s) => DonutSegment(
            label: projectStatusLabel(s.status),
            value: s.count.toDouble(),
            color: projectStatusColor(s.status),
          ),
        )
        .toList();

    final roleCounts = <String, int>{
      for (final rc in (summary?.userRoleCounts ?? const [])) rc.role: rc.count,
    };
    final employees = roleCounts['EMPLOYEE'] ?? 0;
    final freelancers = roleCounts['FREELANCER'] ?? 0;
    final managers = (roleCounts['PROGRAM_MANAGER'] ?? 0) +
        (roleCounts['PROJECT_MANAGER'] ?? 0);
    final totalStaff = employees + freelancers + managers;

    return Row(
      children: [
        Expanded(
          child: DashboardChartCard(
            title: 'عدد المشاريع',
            value: totalProjects.toString(),
            subtitle: 'حسب الحالة',
            chart: SizedBox(
              height: 140,
              child: MiniDonutChart(
                segments: donutSegments,
                strokeWidth: 12,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      totalProjects.toString(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'مشروع',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DashboardChartCard(
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
        ),
      ],
    );
  }
}
