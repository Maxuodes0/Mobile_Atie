import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../theme/app_theme.dart';
import 'clients_screen.dart';
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
    final canSeeClients =
        isAdmin || isProgramManager || role == 'PROJECT_MANAGER';

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
      if (canSeeClients)
        _NavItem(
          pageBuilder: (_) => const ClientsScreen(),
          destination: const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'العملاء',
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
    return Scaffold(
      body: IndexedStack(index: effectiveIndex, children: pages),
      bottomNavigationBar: _FloatingNavigationBar(
        items: nav,
        selectedIndex: effectiveIndex,
        onSelected: (value) => setState(() {
          _index = value;
          _builtIndexes.add(value);
        }),
      ),
    );
  }
}

class _FloatingNavigationBar extends StatelessWidget {
  static const _background = AppTheme.primary;
  static const _selectedBackground = AppTheme.accent;

  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _FloatingNavigationBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(38),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          height: 72,
          child: Row(
            children: List<Widget>.generate(items.length, (index) {
              final destination = items[index].destination;
              final isSelected = index == selectedIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: destination.label,
                  child: Tooltip(
                    message: destination.label,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(36),
                      onTap: () => onSelected(index),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedBackground
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconTheme(
                            data: const IconThemeData(
                              color: Colors.white,
                              size: 28,
                            ),
                            child: isSelected
                                ? (destination.selectedIcon ?? destination.icon)
                                : destination.icon,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }, growable: false),
          ),
        ),
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
