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
}
