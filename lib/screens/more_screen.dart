import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/app_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_page_header.dart';
import 'clients_screen.dart';
import 'tasks_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  String get _role =>
      (AppServices.session.user.value?.role ?? '').trim().toUpperCase();

  bool get _canSeeClients =>
      _role == 'ADMIN' ||
      _role == 'PROGRAM_MANAGER' ||
      _role == 'PROJECT_MANAGER';

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).popUntil((route) => route.isFirst);
    await AppServices.session.logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = AppServices.session.user.value;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 116),
        children: [
          AppPageHeader(
            title: context.tr(en: 'More', ar: 'المزيد'),
            subtitle: context.tr(
              en: 'Business tools and account settings',
              ar: 'أدوات العمل وإعدادات الحساب',
            ),
            showLogout: false,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppTheme.ink),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? context.tr(en: 'My account', ar: 'حسابي'),
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (_canSeeClients)
            _MoreTile(
              icon: Icons.groups_rounded,
              color: AppTheme.ink,
              title: context.tr(en: 'Clients', ar: 'العملاء'),
              subtitle: context.tr(
                en: 'Client directory and project statistics',
                ar: 'دليل العملاء وإحصاءات المشاريع',
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ClientsScreen()),
              ),
            ),
          _MoreTile(
            icon: Icons.checklist_rounded,
            color: AppTheme.ink,
            title: context.tr(en: 'Tasks', ar: 'المهام'),
            subtitle: context.tr(
              en: 'Your assigned tasks and their progress',
              ar: 'مهامك المسندة إليك وتقدمها',
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  backgroundColor: AppTheme.pageBg,
                  body: TasksScreen(),
                ),
              ),
            ),
          ),
          _MoreTile(
            icon: Icons.logout_rounded,
            color: AppTheme.muted,
            title: context.tr(en: 'Log out', ar: 'تسجيل الخروج'),
            subtitle: context.tr(
              en: 'Sign out securely from this device',
              ar: 'تسجيل خروج آمن من هذا الجهاز',
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MoreTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.border),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.softSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.muted,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
