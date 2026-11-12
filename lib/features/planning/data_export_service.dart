import 'dart:convert';

import '../../core/database/app_database.dart';
import 'domain/financial_planning_service.dart';

/// Создаёт читаемый AI снимок базы и текущего раздела «Обзор».
class PlanningDataExportService {
  PlanningDataExportService(this.database, this.planningService);

  final AppDatabase database;
  final FinancialPlanningService planningService;

  static const _tables = [
    'accounts',
    'categories',
    'transactions',
    'recurring_payments',
    'payment_occurrences',
    'income_schedules',
    'app_settings',
    'backup_import_identities',
    'database_metadata',
    'database_history_changes',
    'database_history_metadata',
  ];

  Future<String> createJson({DateTime? date}) async {
    final selectedDate = calendarDate(date ?? DateTime.now());
    final dashboard = await planningService.getDashboardDay(selectedDate);
    final tables = <String, List<Map<String, Object?>>>{};

    for (final table in _tables) {
      final rows = await database.customSelect('SELECT * FROM "$table"').get();
      tables[table] = rows
          .map((row) => _jsonSafe(Map<String, Object?>.from(row.data)))
          .cast<Map<String, Object?>>()
          .toList();
    }

    return const JsonEncoder.withIndent('  ').convert({
      'format': 'survive_till_payday_ai_export',
      'formatVersion': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'overview': _overviewJson(selectedDate, dashboard),
      'tables': tables,
    });
  }

  static Map<String, Object?> _overviewJson(
    DateTime date,
    DashboardDay dashboard,
  ) {
    final finance = dashboard.finance;
    final data = dashboard.dashboard;
    return {
      'date': date.toIso8601String(),
      'finance': {
        'currentBalance': finance.currentBalance,
        'expectedIncome': finance.expectedIncome,
        'reservedPayments': finance.reservedPayments,
        'reserve': finance.reserve,
        'nextPayday': finance.nextPayday?.toIso8601String(),
        'daysUntilPayday': finance.daysUntilPayday,
        'safeToSpend': finance.safeToSpend,
        'dailySafeToSpend': finance.dailySafeToSpend,
        'accumulatedBalance': finance.accumulatedBalance,
        'availableToday': finance.availableToday,
        'todayExpenses': finance.todayExpenses,
        'dailyLimitBalance': finance.dailyLimitBalance,
        'dayBalance': finance.dayBalance,
      },
      'dashboard': {
        'monthIncome': data.monthIncome,
        'monthExpense': data.monthExpense,
        'categorySpending': [
          for (final item in data.categorySpending)
            {'name': item.name, 'color': item.color, 'amount': item.amount},
        ],
        'recentTransactions': [
          for (final item in data.recentTransactions)
            {
              'id': item.transaction.id,
              'date': item.transaction.transactionDate.toIso8601String(),
              'type': item.transaction.type,
              'amount': item.transaction.amount,
              'description': item.transaction.description,
              'account': item.accountName,
              'category': item.categoryName,
            },
        ],
        'remainingTransactionsThisMonth': data.remainingTransactionsThisMonth,
        'upcomingPayments': [
          for (final item in data.upcomingPayments)
            {
              'id': item.occurrence.id,
              'name': item.name,
              'dueDate': item.occurrence.dueDate.toIso8601String(),
              'expectedAmount': item.occurrence.expectedAmount,
              'paidAmount': item.occurrence.paidAmount,
              'status': item.occurrence.status,
            },
        ],
      },
    };
  }

  static Object? _jsonSafe(Object? value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _jsonSafe(item)),
      );
    }
    if (value is Iterable) return value.map(_jsonSafe).toList();
    return value;
  }
}
