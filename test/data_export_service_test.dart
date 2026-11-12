import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/planning/data_export_service.dart';
import 'package:survive_till_payday/features/planning/domain/financial_planning_service.dart';

void main() {
  late AppDatabase database;
  late FinancialPlanningService planning;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    planning = FinancialPlanningService(database);
  });

  tearDown(() => database.close());

  test('exports all data and the overview calculation as JSON', () async {
    final today = DateTime.now();
    await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Основной',
            currentBalance: const Value(100000),
          ),
        );
    await planning.setNextPayday(today.add(const Duration(days: 10)));

    final json = await PlanningDataExportService(
      database,
      planning,
    ).createJson(date: today);
    final export = jsonDecode(json) as Map<String, dynamic>;
    final tables = export['tables'] as Map<String, dynamic>;
    final finance =
        (export['overview'] as Map<String, dynamic>)['finance']
            as Map<String, dynamic>;

    expect(export['format'], 'survive_till_payday_ai_export');
    expect(
      tables.keys,
      containsAll(<String>[
        'accounts',
        'categories',
        'transactions',
        'recurring_payments',
        'payment_occurrences',
        'income_schedules',
        'app_settings',
      ]),
    );
    expect((tables['accounts'] as List<dynamic>), isNotEmpty);
    expect(finance['currentBalance'], 100000);
    expect(finance['safeToSpend'], 100000);
    expect(finance['availableToday'] != null, isTrue);
  });
}
