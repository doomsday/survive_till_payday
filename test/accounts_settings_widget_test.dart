import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';
import 'package:survive_till_payday/features/accounts/presentation/account_dialog.dart';

void main() {
  testWidgets('accounts can be edited, archived, and restored', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Kaspi'));
    await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            type: 'EXPENSE',
            amount: 1000,
            transactionDate: DateTime(2026, 11, 3),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWith((ref) => database)],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: AccountsSettingsSection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Действия со счетом'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Изменить'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Kaspi Gold');
    await tester.enterText(find.byType(TextField).last, '12000');
    expect(
      find.text(
        'Перевод на этот счет будет считаться тратой. Его остаток не войдет в доступные деньги и лимиты.',
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Без снятия'));
    await tester.tap(find.text('Без снятия'));
    await tester.ensureVisible(find.text('Депозит'));
    await tester.tap(find.text('Депозит'));
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(
      (await database.select(database.accounts).getSingle()).isNoWithdrawal,
      isTrue,
    );
    expect(
      (await database.select(database.accounts).getSingle()).isDeposit,
      isTrue,
    );
    expect(find.text('Kaspi Gold'), findsOneWidget);
    expect(find.textContaining('12 000'), findsOneWidget);

    await tester.tap(find.byTooltip('Действия со счетом'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Скрыть / удалить'));
    await tester.pumpAndSettle();
    expect(find.textContaining('будет помещен в архив'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    expect(find.text('Kaspi Gold'), findsNothing);
    await tester.tap(find.text('Показать архивные счета'));
    await tester.pumpAndSettle();
    expect(find.text('Kaspi Gold'), findsOneWidget);
    expect(find.textContaining('В архиве'), findsOneWidget);

    await tester.tap(find.byTooltip('Действия со счетом'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Восстановить'));
    await tester.pumpAndSettle();
    expect(find.text('Kaspi Gold'), findsOneWidget);
    expect(find.textContaining('В архиве'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await database.close();
  });

  testWidgets(
    'editing account has no initial balance field and allows adding an amount to current balance',
    (tester) async {
      final database = AppDatabase(NativeDatabase.memory());
      await database.into(database.accounts).insert(
            AccountsCompanion.insert(
              name: 'Halyk Bank',
              initialBalance: const Value(50000),
              currentBalance: const Value(20000),
            ),
          );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWith((ref) => database)],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AccountsSettingsSection()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Действия со счетом'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Изменить'));
      await tester.pumpAndSettle();

      // Verify "Начальный остаток" is NOT present and "Текущий остаток" is present
      expect(find.text('Начальный остаток'), findsNothing);
      expect(find.text('Текущий остаток'), findsOneWidget);
      expect(find.text('20000'), findsOneWidget);

      // Verify the add button exists next to the current balance field
      expect(find.byTooltip('Прибавить сумму'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Прибавить сумму'));
      await tester.tap(find.byTooltip('Прибавить сумму'));
      await tester.pumpAndSettle();

      // Verify the add amount dialog
      expect(find.text('Прибавить к остатку'), findsOneWidget);
      expect(find.text('+5 000 ₸'), findsOneWidget);

      // Tap quick chip +5000
      await tester.tap(find.text('+5 000 ₸'));
      await tester.pumpAndSettle();

      // Tap "Прибавить"
      await tester.tap(find.text('Прибавить'));
      await tester.pumpAndSettle();

      // Current balance should now be 25000
      expect(find.text('25000'), findsOneWidget);

      // Add another amount via custom text input in add dialog
      await tester.ensureVisible(find.byTooltip('Прибавить сумму'));
      await tester.tap(find.byTooltip('Прибавить сумму'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField).last,
        '1500',
      );
      await tester.tap(find.text('Прибавить'));
      await tester.pumpAndSettle();

      // Current balance should now be 26500
      expect(find.text('26500'), findsOneWidget);

      // Save the dialog
      await tester.ensureVisible(find.text('Сохранить'));
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();

      // Verify in database: initialBalance is preserved (50000), currentBalance is updated (26500)
      final account = await database.select(database.accounts).getSingle();
      expect(account.initialBalance, 50000);
      expect(account.currentBalance, 26500);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
      await database.close();
    },
  );
}
