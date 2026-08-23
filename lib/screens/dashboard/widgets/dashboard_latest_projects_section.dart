import 'package:flutter/material.dart';

import '../../../data/models/project_summary.dart';
import '../../../theme/app_theme.dart';
import 'latest_project_card.dart';

class DashboardLatestProjectsSection extends StatelessWidget {
  final List<ProjectSummary> projects;
  final ValueChanged<ProjectSummary> onOpen;

  const DashboardLatestProjectsSection({
    super.key,
    required this.projects,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أحدث المشاريع',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'آخر المشاريع المضافة خلال الفترة الأخيرة',
          style: TextStyle(color: AppTheme.muted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (projects.isEmpty)
          const Text(
            'لا توجد مشاريع خلال آخر 3 أشهر',
            style: TextStyle(color: AppTheme.muted, fontSize: 12),
          )
        else
          SizedBox(
            height: 282,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: projects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final p = projects[index];
                return LatestProjectCard(
                  project: p,
                  onOpen: () => onOpen(p),
                );
              },
            ),
          ),
      ],
    );
  }
}
