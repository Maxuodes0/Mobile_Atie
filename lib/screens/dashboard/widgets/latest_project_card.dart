import 'package:flutter/material.dart';

import '../../../data/models/project_summary.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../utils/project_status.dart';
import '../../../widgets/project_image.dart';

class LatestProjectCard extends StatelessWidget {
  final ProjectSummary project;
  final VoidCallback onOpen;

  const LatestProjectCard({
    super.key,
    required this.project,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final statusLabel = projectStatusLabel(
      project.status,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    final statusColor = projectStatusColor(project.status);

    return SizedBox(
      width: 286,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.dashboardPaper,
            borderRadius: BorderRadius.circular(30),
          ),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ProjectImage(
                      url: project.projectImage,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    project.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.dashboardInk,
                      fontFamily: AppTheme.dashboardFontFamily,
                      fontFamilyFallback: AppTheme.currencyFontFallback,
                      fontSize: 20,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    project.clientName ??
                        context.tr(en: 'No client', ar: 'بدون عميل'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.dashboardMuted,
                      fontFamily: AppTheme.dashboardFontFamily,
                      fontFamilyFallback: AppTheme.currencyFontFallback,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacitySafe(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
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
