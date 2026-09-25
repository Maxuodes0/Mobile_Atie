import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'projects_screen.dart';
import 'tasks_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  final Set<int> _builtIndexes = <int>{0};

  List<_NavItem> _navForRole(String? rawRole) {
    final role = (rawRole ?? '').trim().toUpperCase();

    final isAdmin = role == 'ADMIN';
    final isProgramManager = role == 'PROGRAM_MANAGER';
    final canSeeAdminDashboard = isAdmin || isProgramManager;
    final items = <_NavItem>[
      if (canSeeAdminDashboard)
        _NavItem(
          pageBuilder: (isActive) => DashboardScreen(isActive: isActive),
          destination: NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: context.tr(en: 'Dashboard', ar: 'لوحة التحكم'),
          ),
        ),
      _NavItem(
        pageBuilder: (_) => const ProjectsScreen(),
        destination: NavigationDestination(
          icon: const Icon(Icons.folder_open_outlined),
          selectedIcon: const Icon(Icons.folder),
          label: context.tr(en: 'Projects', ar: 'المشاريع'),
        ),
      ),
      _NavItem(
        pageBuilder: (_) => const TasksScreen(),
        destination: NavigationDestination(
          icon: const Icon(Icons.checklist_outlined),
          selectedIcon: const Icon(Icons.checklist),
          label: context.tr(en: 'Tasks', ar: 'المهام'),
        ),
      ),
      _NavItem(
        pageBuilder: (_) => const MoreScreen(),
        destination: NavigationDestination(
          icon: const Icon(Icons.grid_view_outlined),
          selectedIcon: const Icon(Icons.grid_view_rounded),
          label: context.tr(en: 'More', ar: 'المزيد'),
        ),
      ),
    ];

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final role = AppServices.session.user.value?.role;
    final nav = _navForRole(role);
    final effectiveIndex = _index.clamp(0, nav.length - 1);
    _builtIndexes.add(effectiveIndex);
    if (effectiveIndex != _index) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _index = effectiveIndex);
      });
    }

    final pages = List<Widget>.generate(nav.length, (index) {
      if (!_builtIndexes.contains(index)) {
        return const SizedBox.shrink();
      }
      return nav[index].pageBuilder(index == effectiveIndex);
    }, growable: false);
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      extendBody: false,
      body: IndexedStack(index: effectiveIndex, children: pages),
      bottomNavigationBar: AppBottomNavigationBar(
        destinations: nav.map((item) => item.destination).toList(),
        selectedIndex: effectiveIndex,
        onDestinationSelected: (value) => setState(() {
          _index = value;
          _builtIndexes.add(value);
        }),
      ),
    );
  }
}

class _NavItem {
  final Widget Function(bool isActive) pageBuilder;
  final NavigationDestination destination;

  _NavItem({
    required this.pageBuilder,
    required this.destination,
  });
}
