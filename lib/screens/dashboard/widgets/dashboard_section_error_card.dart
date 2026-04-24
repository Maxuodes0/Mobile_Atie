import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

class DashboardSectionErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const DashboardSectionErrorCard({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFEF4444);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: danger.withOpacitySafe(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: danger.withOpacitySafe(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFFB91C1C),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('إعادة المحاولة'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB91C1C),
                side: BorderSide(color: danger.withOpacitySafe(0.45)),
                minimumSize: const Size(0, 38),
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
