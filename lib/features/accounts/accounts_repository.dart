import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.watch(databaseProvider));
});

final allAccountsProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountsRepositoryProvider).watchAll();
});

class AccountsRepository {
  AccountsRepository(this._database);

  final AppDatabase _database;

  Stream<List<Account>> watchAll() => (_database.select(
    _database.accounts,
  )..orderBy([(account) => OrderingTerm.asc(account.name)])).watch();

  Future<Account?> getById(int id) => (_database.select(
    _database.accounts,
  )..where((account) => account.id.equals(id))).getSingleOrNull();

  Future<int> create({
    required String name,
    required int initialBalance,
    String type = 'BANK',
  }) {
    _validate(name, type, initialBalance);
    return _database
        .into(_database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: name.trim(),
            type: Value(type),
            initialBalance: Value(initialBalance),
            currentBalance: Value(initialBalance),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required String type,
    required int initialBalance,
    required int currentBalance,
  }) async {
    _validate(name, type, initialBalance);
    final updated =
        await (_database.update(
          _database.accounts,
        )..where((account) => account.id.equals(id))).write(
          AccountsCompanion(
            name: Value(name.trim()),
            type: Value(type),
            initialBalance: Value(initialBalance),
            currentBalance: Value(currentBalance),
          ),
        );
    if (updated == 0) throw StateError('Account $id does not exist.');
  }

  void _validate(String name, String type, int initialBalance) {
    if (name.trim().isEmpty) throw ArgumentError.value(name, 'name');
    if (type != 'BANK' && type != 'CASH') {
      throw ArgumentError.value(type, 'type');
    }
    if (initialBalance < 0) {
      throw ArgumentError.value(initialBalance, 'initialBalance');
    }
  }

  Future<void> setActive(int id, bool isActive) async {
    final updated =
        await (_database.update(_database.accounts)
              ..where((account) => account.id.equals(id)))
            .write(AccountsCompanion(isActive: Value(isActive)));
    if (updated == 0) throw StateError('Account $id does not exist.');
  }

  Future<bool> archiveOrDelete(int id) => _database.transaction(() async {
    final account = await getById(id);
    if (account == null) throw StateError('Account $id does not exist.');
    final references = await _database
        .customSelect(
          'SELECT EXISTS (SELECT 1 FROM transactions WHERE account_id = ?) '
          'OR EXISTS (SELECT 1 FROM recurring_payments WHERE account_id = ?) '
          'AS has_references',
          variables: [Variable.withInt(id), Variable.withInt(id)],
          readsFrom: {_database.transactions, _database.recurringPayments},
        )
        .getSingle();
    if (references.read<int>('has_references') != 0) {
      await (_database.update(_database.accounts)
            ..where((row) => row.id.equals(id)))
          .write(const AccountsCompanion(isActive: Value(false)));
      return true;
    }

    await (_database.delete(
      _database.accounts,
    )..where((row) => row.id.equals(id))).go();
    return false;
  });
}
