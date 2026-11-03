import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';
import 'package:survive_till_payday/features/analytics/presentation/analytics_page.dart';

void main() {
  testWidgets('shows analytics sections and period controls', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase(NativeDatabase.memory());
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Основной'));
    final categoryId = await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Покупки',
            type: 'EXPENSE',
            color: const Value(0xFFFFA726),
          ),
        );
    final now = DateTime.now();
    for (final (amount, date) in [
      (3000, DateTime(now.year, now.month)),
      (2000, DateTime(now.year, now.month - 1)),
    ]) {
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: Value(categoryId),
              type: 'EXPENSE',
              amount: amount,
              transactionDate: date,
            ),
          );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: AnalyticsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Аналитика'), findsOneWidget);
    expect(find.text('Период').first, findsOneWidget);
    expect(find.text('Сравнение периодов'), findsOneWidget);
    expect(find.text('Динамика расходов'), findsOneWidget);
    expect(find.text('Расходы по категориям'), findsOneWidget);
    expect(find.text('Регулярные и разовые расходы'), findsOneWidget);
    expect(find.text('Возможности для экономии'), findsOneWidget);

    await database.close();
  });
}
