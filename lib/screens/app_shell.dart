import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../data/models/access_snapshot.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import 'dashboard_screen.dart';
import 'finance_screen.dart';
import 'more_screen.dart';
import 'projects_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String? _selectedId;
  final Set<String> _builtIds = <String>{};

  @override
  void initState() {
    super.initState();
    AppServices.session.access.addListener(_onAccessChanged);
  }

  @override
  void dispose() {
    AppServices.session.access.removeListener(_onAccessChanged);
    super.dispose();
  }

  void _onAccessChanged() {
    if (mounted) setState(() {});
  }

  List<_NavItem> _navForRole(String? rawRole, AccessSnapshot? access) {
    final role = (rawRole ?? '').trim().toUpperCase();

    final isAdmin = role == 'ADMIN';
    final isProgramManager = role == 'PROGRAM_MANAGER';
    final supportedRole = isAdmin || isProgramManager;
    final dashboardScreen =
        isAdmin ? 'admin.dashboard' : 'programManager.dashboard';
    final financeScreen = isAdmin
        ? 'admin.finance.dashboard'
        : 'programManager.finance.dashboard';
    // Until /access/me arrives, keep the role-based shell responsive. Once it
    // arrives, mirror the server's screen/action gates; the server remains the
    // authority for every request.
    final canSeeAdminDashboard = supportedRole &&
        (access == null || access.screens.contains(dashboardScreen));
    final canSeeFinance = supportedRole &&
        (access == null ||
            (access.screens.contains(financeScreen) &&
                access.actions.contains('finance.read')));
    final items = <_NavItem>[
      if (canSeeAdminDashboard)
        _NavItem(
          id: 'dashboard',
          pageBuilder: (isActive) => DashboardScreen(isActive: isActive),
          destination: NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: context.tr(en: 'Dashboard', ar: 'لوحة التحكم'),
          ),
        ),
      _NavItem(
        id: 'projects',
        pageBuilder: (_) => const ProjectsScreen(),
        destination: NavigationDestination(
          icon: const Icon(Icons.folder_open_outlined),
          selectedIcon: const Icon(Icons.folder),
          label: context.tr(en: 'Projects', ar: 'المشاريع'),
        ),
      ),
      if (canSeeFinance)
        _NavItem(
          id: 'finance',
          pageBuilder: (isActive) => FinanceScreen(isActive: isActive),
          destination: NavigationDestination(
            icon: const Icon(Icons.pie_chart_outline_rounded),
            selectedIcon: const Icon(Icons.pie_chart_rounded),
            label: context.tr(en: 'Finance', ar: 'المالية'),
          ),
        ),
      _NavItem(
        id: 'more',
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
    final nav = _navForRole(role, AppServices.session.access.value);
    final selectedIndex = nav.indexWhere((item) => item.id == _selectedId);
    final effectiveIndex = selectedIndex < 0 ? 0 : selectedIndex;
    _builtIds.add(nav[effectiveIndex].id);

    final pages = List<Widget>.generate(nav.length, (index) {
      if (!_builtIds.contains(nav[index].id)) {
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
          _selectedId = nav[value].id;
          _builtIds.add(nav[value].id);
        }),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final Widget Function(bool isActive) pageBuilder;
  final NavigationDestination destination;

  _NavItem({
    required this.id,
    required this.pageBuilder,
    required this.destination,
  });
}
