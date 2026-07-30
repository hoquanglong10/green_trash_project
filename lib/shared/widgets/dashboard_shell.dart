import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_widgets.dart';

class DashboardDestination {
  const DashboardDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.onSelected,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final VoidCallback onSelected;
}

class DashboardShell extends StatelessWidget {
  const DashboardShell({
    super.key,
    required this.child,
    required this.destinations,
    this.selectedIndex = 0,
    this.actions = const [],
    this.drawer,
    this.maxContentWidth = 1180,
  });

  final Widget child;
  final List<DashboardDestination> destinations;
  final int selectedIndex;
  final List<Widget> actions;
  final Widget? drawer;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 920;
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      drawer: wide ? null : drawer,
      appBar: AppBar(
        centerTitle: false,
        leading: wide || drawer == null
            ? null
            : Builder(
                builder: (scaffoldContext) => IconButton(
                  tooltip: 'Mở menu',
                  onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
        title: const BrandLogo(compact: true, logoSize: 30),
        actions: actions,
      ),
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              _DashboardRail(
                destinations: destinations,
                selectedIndex: selectedIndex,
              ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: wide
          ? null
          : _DashboardBottomNavigation(
              destinations: destinations,
              selectedIndex: selectedIndex,
            ),
    );
  }
}

class _DashboardRail extends StatelessWidget {
  const _DashboardRail({
    required this.destinations,
    required this.selectedIndex,
  });

  final List<DashboardDestination> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedIndex,
        labelType: NavigationRailLabelType.all,
        groupAlignment: -0.72,
        indicatorColor: AppColors.green100,
        selectedIconTheme: const IconThemeData(color: AppColors.primary),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.primaryDark,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        onDestinationSelected: (index) {
          if (index == selectedIndex) return;
          destinations[index].onSelected();
        },
        destinations: [
          for (final destination in destinations)
            NavigationRailDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: Text(destination.label),
            ),
        ],
      ),
    );
  }
}

class _DashboardBottomNavigation extends StatelessWidget {
  const _DashboardBottomNavigation({
    required this.destinations,
    required this.selectedIndex,
  });

  final List<DashboardDestination> destinations;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            destinations[index].onSelected();
          },
          destinations: [
            for (final destination in destinations)
              NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
          ],
        ),
      ),
    );
  }
}
