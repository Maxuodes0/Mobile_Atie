import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppBottomNavigationBar extends StatelessWidget {
  static const double _barHeight = 72;
  static const double _widthFactor = 0.82;
  static const Color _inactiveColor = Color(0xFFBEBEBA);

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppBottomNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  })  : assert(destinations.length > 1),
        assert(selectedIndex >= 0),
        assert(selectedIndex < destinations.length);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: SizedBox(
        height: _barHeight,
        child: Center(
          child: FractionallySizedBox(
            widthFactor: _widthFactor,
            child: Material(
              color: AppTheme.dashboardInk,
              borderRadius: BorderRadius.circular(_barHeight / 2),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: List<Widget>.generate(destinations.length, (index) {
                  return Expanded(
                    child: _NavigationButton(
                      destination: destinations[index],
                      selected: index == selectedIndex,
                      onTap: () => onDestinationSelected(index),
                    ),
                  );
                }, growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(36),
          splashColor: Colors.white12,
          highlightColor: Colors.white10,
          onTap: onTap,
          child: Center(
            child: AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              child: IconTheme(
                data: IconThemeData(
                  color: selected
                      ? Colors.white
                      : AppBottomNavigationBar._inactiveColor,
                  size: selected ? 31 : 29,
                ),
                child: selected
                    ? (destination.selectedIcon ?? destination.icon)
                    : destination.icon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
