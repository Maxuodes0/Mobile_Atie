import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Holds a section's place without showing unverified financial data.
class DashboardSectionSkeleton extends StatelessWidget {
  final double height;

  const DashboardSectionSkeleton({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.dashboardPaper,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBlock(height: 26, width: 176),
          SizedBox(height: 20),
          _SkeletonBlock(height: 38, width: 224),
          Spacer(),
          _SkeletonBlock(height: 18, width: 116),
        ],
      ),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final double width;

  const _SkeletonBlock({required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.dashboardGraphite.withOpacitySafe(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
