import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/accounts/accounts_repository.dart';
import 'package:survive_till_payday/features/transactions/transactions_repository.dart';

void main() {
  late AppDatabase database;
  late TransactionsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = TransactionsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> addAccount(String name, int balance) => database
      .into(database.accounts)
      .insert(
        AccountsCompanion.insert(name: name, currentBalance: Value(balance)),
      );

  test(
    'income and expense creation, editing and deletion maintain balances',
    () async {
      final accountId = await addAccount('Kaspi', 100000);
      final foodCategory = await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(name: 'Продукты', type: 'EXPENSE'),
          );
      final transactionId = await repository.addTransaction(
        type: 'EXPENSE',
        accountId: accountId,
        amount: 12000,
        date: DateTime(2026, 11, 2, 20),
        categoryId: foodCategory,
        description: 'Покупки',
      );
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        88000,
      );

      await repository.updateTransaction(
        id: transactionId,
        type: 'INCOME',
        accountId: accountId,
        amount: 5000,
        date: DateTime(2026, 11, 3),
        categoryId: null,
        description: 'Возврат',
        isExcludedFromStatistics: true,
      );
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        105000,
      );

      await repository.deleteTransaction(transactionId);
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        100000,
      );
    },
  );

  test(
    'unavoidable expense is persisted and deducted from account balance',
    () async {
      final accountId = await addAccount('Kaspi', 100000);
      final transactionId = await repository.addTransaction(
        type: 'EXPENSE',
        accountId: accountId,
        amount: 10000,
        date: DateTime(2026, 11, 3),
        description: 'Бензин',
        isUnavoidable: true,
      );

      var transaction = await (database.select(
        database.transactions,
      )..where((row) => row.id.equals(transactionId))).getSingle();
      expect(transaction.isUnavoidable, isTrue);
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        90000,
      );

      await repository.updateTransaction(
        id: transactionId,
        type: 'EXPENSE',
        accountId: accountId,
        amount: 12000,
        date: DateTime(2026, 11, 3),
        description: 'Заправка',
        isExcludedFromStatistics: false,
        isUnavoidable: false,
      );
      transaction = await (database.select(
        database.transactions,
      )..where((row) => row.id.equals(transactionId))).getSingle();
      expect(transaction.isUnavoidable, isFalse);
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        88000,
      );
    },
  );

  test(
    'transfers create a single filtered entry and reverse atomically',
    () async {
      final sourceId = await addAccount('Kaspi', 100000);
      final targetId = await addAccount('Наличные', 20000);
      final transferId = await repository.addTransfer(
        sourceAccountId: sourceId,
        targetAccountId: targetId,
        amount: 15000,
        date: DateTime(2020, 1, 1),
        description: 'Снятие наличных',
      );

      var accounts = await database.select(database.accounts).get();
      expect(
        accounts.firstWhere((item) => item.id == sourceId).currentBalance,
        85000,
      );
      expect(
        accounts.firstWhere((item) => item.id == targetId).currentBalance,
        35000,
      );
      expect(
        accounts.fold<int>(0, (total, item) => total + item.currentBalance),
        120000,
      );

      var entries = await repository.getEntries(type: 'TRANSFER');
      expect(entries, hasLength(1));
      expect(entries.single.transferPeerAccountName, 'Наличные');
      expect((await repository.getEntries(accountId: targetId)), hasLength(1));

      await repository.updateTransfer(
        transactionId: transferId,
        sourceAccountId: sourceId,
        targetAccountId: targetId,
        amount: 10000,
        date: DateTime(2026, 11, 4),
        description: 'Поправка',
      );
      accounts = await database.select(database.accounts).get();
      expect(
        accounts.firstWhere((item) => item.id == sourceId).currentBalance,
        90000,
      );
      expect(
        accounts.firstWhere((item) => item.id == targetId).currentBalance,
        30000,
      );
      entries = await repository.getEntries(query: 'наличные');
      expect(entries, hasLength(1));

      await repository.deleteTransaction(transferId);
      accounts = await database.select(database.accounts).get();
      expect(
        accounts.firstWhere((item) => item.id == sourceId).currentBalance,
        100000,
      );
      expect(
        accounts.firstWhere((item) => item.id == targetId).currentBalance,
        20000,
      );
      expect(await repository.getEntries(), isEmpty);
    },
  );

  test('deposit flag syncs transfer categories for existing pairs', () async {
    final sourceId = await addAccount('Основной', 100000);
    final targetId = await addAccount('Вклад', 0);
    final transferId = await repository.addTransfer(
      sourceAccountId: sourceId,
      targetAccountId: targetId,
      amount: 10000,
      date: DateTime(2026, 11, 3),
    );
    final category =
        await (database.select(database.categories)
              ..where((row) => row.name.equals(depositTransferCategoryName)))
            .getSingle();
    final accountsRepository = AccountsRepository(database);

    await accountsRepository.update(
      id: targetId,
      name: 'Вклад',
      type: 'BANK',
      initialBalance: 0,
      currentBalance: 10000,
      isNoWithdrawal: false,
      isDeposit: true,
    );
    var pair = await (database.select(
      database.transactions,
    )..where((row) => row.transferGroupId.equals(transferId))).get();
    expect(pair.every((item) => item.categoryId == category.id), isTrue);

    await accountsRepository.update(
      id: targetId,
      name: 'Вклад',
      type: 'BANK',
      initialBalance: 0,
      currentBalance: 10000,
      isNoWithdrawal: false,
      isDeposit: false,
    );
    pair = await (database.select(
      database.transactions,
    )..where((row) => row.transferGroupId.equals(transferId))).get();
    expect(pair.every((item) => item.categoryId == null), isTrue);
  });

  test('date, category, type and text filters work together', () async {
    final accountId = await addAccount('Основной', 100000);
    final categoryId = await database
        .into(database.categories)
        .insert(CategoriesCompanion.insert(name: 'Продукты', type: 'EXPENSE'));
    await repository.addTransaction(
      type: 'EXPENSE',
      accountId: accountId,
      amount: 5000,
      date: DateTime(2026, 11, 2),
      categoryId: categoryId,
      description: 'Магазин у дома',
    );
    await repository.addTransaction(
      type: 'INCOME',
      accountId: accountId,
      amount: 10000,
      date: DateTime(2026, 10, 31),
      description: 'Зарплата',
    );

    final matches = await repository.getEntries(
      accountId: accountId,
      categoryId: categoryId,
      type: 'EXPENSE',
      from: DateTime(2026, 11, 2),
      until: DateTime(2026, 11, 2),
      query: 'магазин',
    );
    expect(matches, hasLength(1));
    expect(matches.single.transaction.amount, 5000);
    expect(
      await repository.getEntries(type: 'INCOME', from: DateTime(2026, 11, 1)),
      isEmpty,
    );
  });

  test(
    'editing and deleting payment transactions recalculate occurrence',
    () async {
      final accountId = await addAccount('Основной', 100000);
      final recurringId = await database
          .into(database.recurringPayments)
          .insert(
            RecurringPaymentsCompanion.insert(
              name: 'Интернет',
              amount: 10000,
              frequency: 'MONTHLY',
              startDate: DateTime(2026, 11, 2),
            ),
          );
      final occurrenceId = await database
          .into(database.paymentOccurrences)
          .insert(
            PaymentOccurrencesCompanion.insert(
              recurringPaymentId: recurringId,
              expectedAmount: 10000,
              dueDate: DateTime(2020, 1, 1),
              status: const Value('PARTIALLY_PAID'),
              paidAmount: const Value(4000),
            ),
          );
      final transactionId = await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'EXPENSE',
              amount: 4000,
              transactionDate: DateTime(2020, 1, 1),
              linkedPaymentOccurrenceId: Value(occurrenceId),
            ),
          );
      await (database.update(database.accounts)
            ..where((row) => row.id.equals(accountId)))
          .write(const AccountsCompanion(currentBalance: Value(96000)));

      await repository.updateTransaction(
        id: transactionId,
        type: 'EXPENSE',
        accountId: accountId,
        amount: 6000,
        date: DateTime(2020, 1, 1),
        description: 'Интернет',
        isExcludedFromStatistics: false,
      );
      var occurrence = await (database.select(
        database.paymentOccurrences,
      )..where((row) => row.id.equals(occurrenceId))).getSingle();
      expect(occurrence.paidAmount, 6000);
      expect(occurrence.status, 'PARTIALLY_PAID');

      await repository.deleteTransaction(transactionId);
      occurrence = await (database.select(
        database.paymentOccurrences,
      )..where((row) => row.id.equals(occurrenceId))).getSingle();
      expect(occurrence.paidAmount, 0);
      expect(occurrence.status, 'OVERDUE');
      expect(occurrence.linkedTransactionId, isNull);
      expect(
        (await database.select(database.accounts).getSingle()).currentBalance,
        100000,
      );
    },
  );
}
