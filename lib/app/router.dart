import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/transactions/presentation/transactions_page.dart';
import '../features/planning/presentation/dashboard_page.dart';
import '../features/planning/presentation/payments_page.dart';
import '../features/planning/presentation/settings_planning_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/analytics/presentation/analytics_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: DashboardPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: TransactionsPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/payments',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: PaymentsPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: AnalyticsPage()),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) =>
                  const NoTransitionPage(child: PlanningSettingsPage()),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),
  ],
);

class AppScaffold extends StatelessWidget {
  const AppScaffold({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  static const _items = [
    NavigationDestination(
      icon: Icon(Icons.space_dashboard_outlined),
      label: 'Обзор',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      label: 'Операции',
    ),
    NavigationDestination(
      icon: Icon(Icons.event_repeat_outlined),
      label: 'Платежи',
    ),
    NavigationDestination(
      icon: Icon(Icons.insert_chart_outlined),
      label: 'Аналитика',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      label: 'Настройки',
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: navigationShell,
    bottomNavigationBar: NavigationBar(
      selectedIndex: navigationShell.currentIndex,
      destinations: _items,
      onDestinationSelected: (index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      ),
    ),
  );
}
