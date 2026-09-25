import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aite_mobile/widgets/app_bottom_navigation_bar.dart';

void main() {
  const destinations = <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    NavigationDestination(
      icon: Icon(Icons.folder_open_outlined),
      selectedIcon: Icon(Icons.folder),
      label: 'Projects',
    ),
    NavigationDestination(
      icon: Icon(Icons.checklist_outlined),
      selectedIcon: Icon(Icons.checklist),
      label: 'Tasks',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'More',
    ),
  ];

  testWidgets('bottom navigation remains a compact icon-only pill', (
    tester,
  ) async {
    var selectedIndex = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: AppBottomNavigationBar(
            destinations: destinations,
            selectedIndex: 0,
            onDestinationSelected: (index) => selectedIndex = index,
          ),
        ),
      ),
    );

    final barSize = tester.getSize(find.byType(AppBottomNavigationBar));
    expect(barSize.height, lessThan(120));
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Projects'), findsNothing);

    await tester.tap(find.byIcon(Icons.folder_open_outlined));
    await tester.pump();
    expect(selectedIndex, 1);
  });
}
