import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/app/app.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';

void main() {
  testWidgets('operations tab records, searches, and edits an expense', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final accountId = await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Kaspi',
            currentBalance: const Value(50000),
          ),
        );
    await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(name: 'Продукты', type: 'EXPENSE'));

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
    await tester.tap(find.text('Операции').last);
    await tester.pumpAndSettle();
    expect(find.text('Операций пока нет'), findsOneWidget);

    await tester.tap(find.text('Добавить').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Сумма, ₸'), '2500');
    await tester.enterText(
      find.widgetWithText(TextField, 'Описание'),
      'Покупка продуктов',
    );
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    var transaction =
        (await database.select(database.transactions).get()).single;
    expect(transaction.accountId, accountId);
    expect(transaction.type, 'EXPENSE');
    expect(transaction.amount, 2500);
    expect(
      (await database.select(database.accounts).getSingle()).currentBalance,
      47500,
    );
    expect(find.text('Покупка продуктов'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Поиск по описанию, счету, категории'),
      'несуществующее',
    );
    await tester.pumpAndSettle();
    expect(find.text('Ничего не найдено'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextField, 'Поиск по описанию, счету, категории'),
      'продуктов',
    );
    await tester.pumpAndSettle();
    expect(find.text('Покупка продуктов'), findsOneWidget);

    await tester.tap(find.byTooltip('Действия').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Сумма, ₸'), '3000');
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    transaction = (await database.select(database.transactions).get()).single;
    expect(transaction.amount, 3000);
    expect(
      (await database.select(database.accounts).getSingle()).currentBalance,
      47000,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
