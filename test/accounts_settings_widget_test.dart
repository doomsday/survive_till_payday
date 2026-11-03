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
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

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
}
