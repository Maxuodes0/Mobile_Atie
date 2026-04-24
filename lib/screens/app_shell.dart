import 'package:flutter/material.dart';

import '../services/app_services.dart';
import 'dashboard_screen.dart';
import 'finance_screen.dart';
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
    final canSeeFinance = isAdmin || isProgramManager;

    final items = <_NavItem>[
      if (canSeeAdminDashboard)
        _NavItem(
          pageBuilder: (isActive) => DashboardScreen(isActive: isActive),
          destination: const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'لوحة التحكم',
          ),
        ),
      _NavItem(
        pageBuilder: (_) => const ProjectsScreen(),
        destination: const NavigationDestination(
          icon: Icon(Icons.folder_open_outlined),
          selectedIcon: Icon(Icons.folder),
          label: 'المشاريع',
        ),
      ),
      _NavItem(
        pageBuilder: (_) => const TasksScreen(),
        destination: const NavigationDestination(
          icon: Icon(Icons.checklist_outlined),
          selectedIcon: Icon(Icons.checklist),
          label: 'المهام',
        ),
      ),
      if (canSeeFinance)
        _NavItem(
          pageBuilder: (isActive) => FinanceScreen(isActive: isActive),
          destination: const NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'المالية',
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
    final destinations = nav.map((e) => e.destination).toList(growable: false);

    return Scaffold(
      body: IndexedStack(index: effectiveIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: effectiveIndex,
        onDestinationSelected: (value) => setState(() {
          _index = value;
          _builtIndexes.add(value);
        }),
        destinations: destinations,
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
