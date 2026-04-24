import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ErrorBanner extends StatelessWidget {
  final String message;

  const ErrorBanner({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const danger = Color(0xFFEF4444);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: danger.withOpacitySafe(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: danger.withOpacitySafe(0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFFB91C1C),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
