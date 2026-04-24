import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/app_card.dart';

class DashboardChartCard extends StatelessWidget {
  final String title;
  final String value;
  final String? secondaryValue;
  final String subtitle;
  final Widget chart;

  const DashboardChartCard({
    super.key,
    required this.title,
    required this.value,
    this.secondaryValue,
    required this.subtitle,
    required this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  if (secondaryValue != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      secondaryValue!,
                      style: const TextStyle(
                        color: AppTheme.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: chart,
          ),
        ],
      ),
    );
  }
}
