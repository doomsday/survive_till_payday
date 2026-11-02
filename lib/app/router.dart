import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/transactions/presentation/transactions_page.dart';
import '../features/planning/presentation/dashboard_page.dart';
import '../features/planning/presentation/payments_page.dart';
import '../features/planning/presentation/settings_planning_page.dart';

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
        _branch('/analytics', 'Аналитика', Icons.insert_chart_outlined),
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
  ],
);

StatefulShellBranch _branch(String path, String title, IconData icon) =>
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: path,
          pageBuilder: (context, state) => NoTransitionPage(
            child: SectionPage(title: title, icon: icon),
          ),
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

class SectionPage extends StatelessWidget {
  const SectionPage({required this.title, required this.icon, super.key});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'Раздел будет реализован на следующем этапе.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
