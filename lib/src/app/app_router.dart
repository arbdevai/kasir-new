import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/history/presentation/history_shell_screen.dart';
import '../features/pos/presentation/pos_shell_screen.dart';
import '../features/products/presentation/products_shell_screen.dart';
import '../features/reports/presentation/reports_shell_screen.dart';
import '../features/settings/presentation/settings_shell_screen.dart';
import '../features/shell/presentation/shell_scaffold.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/pos',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellScaffold(
          navigationShell: navigationShell,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pos',
                name: 'pos',
                builder: (context, state) => const PosShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                name: 'history',
                builder: (context, state) => const HistoryShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (context, state) => const ProductsShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                name: 'reports',
                builder: (context, state) => const ReportsShellScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsShellScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
      body: Center(child: Text(state.error.toString())),
    ),
  );
}
