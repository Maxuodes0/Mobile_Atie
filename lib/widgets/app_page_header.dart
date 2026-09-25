import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';

class AppPageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogout;
  final bool showBack;

  const AppPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogout = true,
    this.showBack = false,
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
        if (showBack) ...[
          IconButton(
            tooltip: isAr ? 'عودة' : 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              isAr ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            ),
            color: AppTheme.ink,
          ),
          const SizedBox(width: 4),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.muted,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showLogout)
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
