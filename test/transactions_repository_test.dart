import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/transactions/transactions_repository.dart';

void main() {
  test('custom transaction order is persisted by date', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Kaspi'));
    final firstId = await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            type: 'EXPENSE',
            amount: 1000,
            transactionDate: DateTime(2026, 11, 13, 10),
            description: const Value('Первая'),
          ),
        );
    final secondId = await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            type: 'EXPENSE',
            amount: 2000,
            transactionDate: DateTime(2026, 11, 13, 11),
            description: const Value('Вторая'),
          ),
        );
    final repository = TransactionsRepository(database);

    await repository.saveDateOrder(DateTime(2026, 11, 13), [firstId, secondId]);

    final entries = await repository.getEntries();
    expect(entries.map((entry) => entry.transaction.id), [firstId, secondId]);
  });
}
