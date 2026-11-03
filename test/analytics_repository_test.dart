import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/analytics/analytics_repository.dart';
import 'package:survive_till_payday/features/analytics/domain/analytics_models.dart';

void main() {
  late AppDatabase database;
  late AnalyticsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = AnalyticsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('reads category, currency and recurring-payment metadata', () async {
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Основной'));
    final categoryId = await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Связь',
            type: 'EXPENSE',
            color: const Value(0xFF123456),
          ),
        );
    final scheduleId = await database
        .into(database.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            name: 'Интернет',
            amount: 5000,
            frequency: 'MONTHLY',
            startDate: DateTime(2026, 11, 1),
            categoryId: Value(categoryId),
          ),
        );
    final occurrenceId = await database
        .into(database.paymentOccurrences)
        .insert(
          PaymentOccurrencesCompanion.insert(
            recurringPaymentId: scheduleId,
            expectedAmount: 5000,
            dueDate: DateTime(2026, 11, 2),
          ),
        );
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            categoryId: Value(categoryId),
            type: 'EXPENSE',
            amount: 5000,
            transactionDate: DateTime(2026, 11, 2),
            linkedPaymentOccurrenceId: Value(occurrenceId),
          ),
        );

    final currencies = await repository.watchCurrencies().first;
    final report = await repository.getReport(
      AnalyticsQuery(
        period: AnalyticsPeriod.currentMonth,
        range: analyticsRangeFor(
          AnalyticsPeriod.currentMonth,
          now: DateTime(2026, 11, 3),
        ),
        currency: 'KZT',
      ),
    );

    expect(currencies, ['KZT']);
    expect(report.categories.single.name, 'Связь');
    expect(report.categories.single.color, 0xFF123456);
    expect(report.totals.regularExpenses, 5000);
    expect(report.totals.irregularExpenses, 0);
  });
}
