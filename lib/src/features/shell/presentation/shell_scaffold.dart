import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 768;

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onDestinationSelected,
              labelType: NavigationRailLabelType.all,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.primarySubtle,
              selectedIconTheme: const IconThemeData(color: AppColors.primary),
              selectedLabelTextStyle: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Icon(
                  CupertinoIcons.cube_box_fill,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.cart),
                  selectedIcon: Icon(CupertinoIcons.cart_fill),
                  label: Text('POS'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.clock),
                  selectedIcon: Icon(CupertinoIcons.clock_fill),
                  label: Text('Riwayat'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.square_grid_2x2),
                  selectedIcon: Icon(CupertinoIcons.square_grid_2x2_fill),
                  label: Text('Produk'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.chart_bar),
                  selectedIcon: Icon(CupertinoIcons.chart_bar_fill),
                  label: Text('Laporan'),
                ),
                NavigationRailDestination(
                  icon: Icon(CupertinoIcons.gear),
                  selectedIcon: Icon(CupertinoIcons.gear_solid),
                  label: Text('Pengaturan'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.border),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.cart),
            selectedIcon: Icon(CupertinoIcons.cart_fill, color: AppColors.primary),
            label: 'POS',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.clock),
            selectedIcon: Icon(CupertinoIcons.clock_fill, color: AppColors.primary),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.square_grid_2x2),
            selectedIcon: Icon(CupertinoIcons.square_grid_2x2_fill, color: AppColors.primary),
            label: 'Produk',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_bar),
            selectedIcon: Icon(CupertinoIcons.chart_bar_fill, color: AppColors.primary),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.gear),
            selectedIcon: Icon(CupertinoIcons.gear_solid, color: AppColors.primary),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
