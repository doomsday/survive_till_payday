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
    if (name.trim().isEmpty) throw ArgumentError.value(name, 'name');
    if (initialBalance < 0) {
      throw ArgumentError.value(initialBalance, 'initialBalance');
    }
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

  Future<void> setActive(int id, bool isActive) async {
    await (_database.update(_database.accounts)
          ..where((account) => account.id.equals(id)))
        .write(AccountsCompanion(isActive: Value(isActive)));
  }
}
