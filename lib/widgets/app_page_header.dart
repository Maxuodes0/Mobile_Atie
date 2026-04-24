import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  Future<void> _logout(BuildContext context) async {
    // Ensure we return to the root route so AuthGate can swap AppShell -> LoginScreen.
    Navigator.of(context).popUntil((route) => route.isFirst);
    await AppServices.session.logout();
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final logoutLabel = isAr ? 'تسجيل خروج' : 'Logout';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: logoutLabel,
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          color: AppTheme.muted,
        ),
      ],
    );
  }
}
