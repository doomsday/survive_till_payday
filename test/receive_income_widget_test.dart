import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/app/app.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';

void main() {
  testWidgets('creates an account and records income when no account exists', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final today = DateTime.now();
    await database
        .into(database.incomeSchedules)
        .insert(
          IncomeSchedulesCompanion.insert(
            name: 'Зарплата',
            expectedAmount: 100000,
            frequency: 'MONTHLY',
            expectedDate: DateTime(today.year, today.month, today.day),
          ),
        );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const PaydayApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Платежи').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Отметить полученным'));
    await tester.pumpAndSettle();
    expect(find.text('Нужен активный счет'), findsOneWidget);
    await tester.tap(find.text('Создать счет'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Название'), 'Kaspi');
    await tester.enterText(
      find.widgetWithText(TextField, 'Текущий остаток'),
      '0',
    );
    await tester.tap(find.text('Создать'));
    await tester.pumpAndSettle();

    expect(find.text('Выберите счет'), findsOneWidget);
    await tester.tap(find.text('Kaspi').last);
    await tester.pumpAndSettle();

    final account = (await database.select(database.accounts).get()).single;
    final transaction =
        (await database.select(database.transactions).get()).single;
    expect(account.currentBalance, 100000);
    expect(transaction.type, 'INCOME');
    expect(transaction.amount, 100000);
    expect(find.text('Не удалось записать доход'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
