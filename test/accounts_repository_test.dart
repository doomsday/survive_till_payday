import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/accounts/accounts_repository.dart';

void main() {
  late AppDatabase database;
  late AccountsRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = AccountsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates an active account with the supplied opening balance', () async {
    final id = await repository.create(
      name: 'Kaspi Gold',
      initialBalance: 125000,
    );

    final account = await repository.getById(id);
    expect(account, isNotNull);
    expect(account!.name, 'Kaspi Gold');
    expect(account.initialBalance, 125000);
    expect(account.currentBalance, 125000);
    expect(account.currency, 'KZT');
    expect(account.isActive, isTrue);
    expect(account.isNoWithdrawal, isFalse);
    expect(account.isDeposit, isFalse);
  });

  test('creates and updates accounts without withdrawal', () async {
    final id = await repository.create(
      name: 'Сейф',
      initialBalance: 20000,
      isNoWithdrawal: true,
    );

    await repository.update(
      id: id,
      name: 'Сейф',
      type: 'BANK',
      initialBalance: 20000,
      currentBalance: 18000,
      isNoWithdrawal: false,
      isDeposit: true,
    );

    expect((await repository.getById(id))!.isNoWithdrawal, isFalse);
    expect((await repository.getById(id))!.isDeposit, isTrue);
  });

  test('rejects invalid accounts and can deactivate an account', () async {
    expect(
      () => repository.create(name: ' ', initialBalance: 0),
      throwsArgumentError,
    );
    expect(
      () => repository.create(name: 'Cash', initialBalance: -1),
      throwsArgumentError,
    );

    final id = await repository.create(name: 'Cash', initialBalance: 0);
    await repository.setActive(id, false);

    expect((await repository.getById(id))!.isActive, isFalse);
  });

  test('updates account details and both balances', () async {
    final id = await repository.create(name: 'Kaspi', initialBalance: 100000);

    await repository.update(
      id: id,
      name: 'Kaspi Gold',
      type: 'CASH',
      initialBalance: 80000,
      currentBalance: 72000,
      isNoWithdrawal: true,
      isDeposit: true,
    );

    final account = (await repository.getById(id))!;
    expect(account.name, 'Kaspi Gold');
    expect(account.type, 'CASH');
    expect(account.initialBalance, 80000);
    expect(account.currentBalance, 72000);
    expect(account.isNoWithdrawal, isTrue);
    expect(account.isDeposit, isTrue);
  });

  test(
    'archives referenced accounts and permanently deletes unused accounts',
    () async {
      final referencedId = await repository.create(
        name: 'Kaspi',
        initialBalance: 10000,
      );
      final unusedId = await repository.create(
        name: 'Наличные',
        initialBalance: 5000,
      );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: referencedId,
              type: 'EXPENSE',
              amount: 1000,
              transactionDate: DateTime(2026, 11, 3),
            ),
          );

      expect(await repository.archiveOrDelete(referencedId), isTrue);
      expect((await repository.getById(referencedId))!.isActive, isFalse);

      expect(await repository.archiveOrDelete(unusedId), isFalse);
      expect(await repository.getById(unusedId), isNull);

      await repository.setActive(referencedId, true);
      expect((await repository.getById(referencedId))!.isActive, isTrue);
    },
  );

  test('archives an account referenced by a recurring payment', () async {
    final accountId = await repository.create(
      name: 'Карта',
      initialBalance: 20000,
    );
    await database
        .into(database.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            name: 'Интернет',
            amount: 5000,
            accountId: Value(accountId),
            frequency: 'MONTHLY',
            startDate: DateTime(2026, 11, 3),
          ),
        );

    expect(await repository.archiveOrDelete(accountId), isTrue);
    expect((await repository.getById(accountId))!.isActive, isFalse);
  });
}
