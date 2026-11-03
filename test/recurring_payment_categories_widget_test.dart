import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';
import 'package:survive_till_payday/features/planning/presentation/payments_page.dart';

void main() {
  testWidgets('a recurring payment can be assigned an expense category', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Kaspi Gold'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const MaterialApp(home: PaymentsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Добавить платеж'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Покупки');
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(find.byType(TextField).last, '15000');

    final categoryDropdown = find.byType(DropdownButtonFormField<int?>);
    await tester.ensureVisible(categoryDropdown);
    final automobile = await (database.select(
      database.categories,
    )..where((row) => row.name.equals('Автомобиль'))).getSingle();
    tester.widget<DropdownButtonFormField<int?>>(categoryDropdown).onChanged!(
      automobile.id,
    );
    await tester.pumpAndSettle();
    final autoPaySwitch = find.byType(SwitchListTile).first;
    tester.widget<SwitchListTile>(autoPaySwitch).onChanged!(true);
    await tester.pumpAndSettle();
    expect(find.text('Счет карты'), findsOneWidget);
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Покупки'), findsOneWidget);
    final payment =
        (await database.select(database.recurringPayments).get()).single;
    expect(payment.isAutoPay, isTrue);
    expect(payment.accountId, accountId);
    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals(payment.categoryId!))).getSingle();
    expect(category.name, 'Автомобиль');
    final autoTransaction = await (database.select(
      database.transactions,
    )..where((row) => row.linkedPaymentOccurrenceId.isNotNull())).getSingle();
    expect(autoTransaction.accountId, accountId);

    await tester.tap(find.byTooltip('Действия с платежом'));
    await tester.pumpAndSettle();
    expect(find.text('Изменить платёж'), findsOneWidget);
    expect(find.text('Изменить расписание'), findsNothing);
    expect(find.text('Изменить платеж'), findsNothing);
    await tester.tap(find.text('Изменить платёж'));
    await tester.pumpAndSettle();
    expect(find.text('Изменить платёж'), findsOneWidget);
    expect(find.text('Периодичность'), findsOneWidget);
    expect(find.text('Категория'), findsOneWidget);
    expect(find.text('Автооплата'), findsWidgets);
    expect(
      find.text(
        'Изменения применятся к будущим неоплаченным платежам. История оплат не изменится.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
