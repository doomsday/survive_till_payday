import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../features/planning/domain/financial_planning_service.dart';

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.watch(databaseProvider));
});

final transactionEntriesProvider = StreamProvider<List<TransactionEntry>>(
  (ref) => ref.watch(transactionsRepositoryProvider).watchEntries(),
);

final transactionAccountsProvider = StreamProvider<List<Account>>(
  (ref) => ref.watch(transactionsRepositoryProvider).watchAccounts(),
);

final transactionCategoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.watch(transactionsRepositoryProvider).watchCategories(),
);

class TransactionEntry {
  const TransactionEntry({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.categoryColor,
    this.transferPeerAccountName,
    this.transferPeerAccountId,
    this.isTransferSource = false,
  });

  final Transaction transaction;
  final String accountName;
  final String? categoryName;
  final int? categoryColor;
  final String? transferPeerAccountName;
  final int? transferPeerAccountId;
  final bool isTransferSource;

  String get title => transaction.description.isNotEmpty
      ? transaction.description
      : categoryName ??
            (transaction.type == 'TRANSFER' ? 'Перевод' : 'Операция');
}

class TransactionsRepository {
  TransactionsRepository(this._database);

  final AppDatabase _database;

  Stream<List<Account>> watchAccounts() => (_database.select(
    _database.accounts,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).watch();

  Future<List<Account>> getAccounts() => (_database.select(
    _database.accounts,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();

  Stream<List<Category>> watchCategories() =>
      (_database.select(_database.categories)
            ..where((row) => row.isHidden.equals(false))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .watch();

  Future<List<Category>> getCategories() =>
      (_database.select(_database.categories)
            ..where((row) => row.isHidden.equals(false))
            ..orderBy([(row) => OrderingTerm.asc(row.name)]))
          .get();

  Stream<List<TransactionEntry>> watchEntries() => _database
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _database.transactions,
          _database.accounts,
          _database.categories,
        },
      )
      .watch()
      .asyncMap((_) => getEntries());

  Future<List<TransactionEntry>> getEntries({
    int? accountId,
    int? categoryId,
    String? type,
    DateTime? from,
    DateTime? until,
    String query = '',
  }) async {
    final transactions =
        await (_database.select(_database.transactions)..orderBy([
              (row) => OrderingTerm.desc(row.transactionDate),
              (row) => OrderingTerm.desc(row.id),
            ]))
            .get();
    final accounts = await _database.select(_database.accounts).get();
    final categories = await _database.select(_database.categories).get();
    final accountById = {for (final item in accounts) item.id: item};
    final categoryById = {for (final item in categories) item.id: item};
    final transfers = <int, List<Transaction>>{};
    for (final transaction in transactions) {
      final groupId = transaction.transferGroupId;
      if (groupId != null) {
        transfers.putIfAbsent(groupId, () => []).add(transaction);
      }
    }
    final normalizedFrom = from == null ? null : calendarDate(from);
    final normalizedUntil = until == null ? null : calendarDate(until);
    final search = query.trim().toLowerCase();
    return [
      for (final transaction in transactions)
        if (transaction.type != 'TRANSFER' ||
            transaction.transferGroupId == transaction.id)
          if (accountId == null ||
              transaction.accountId == accountId ||
              _transferPeerId(transaction, transfers) == accountId)
            if (categoryId == null || transaction.categoryId == categoryId)
              if (type == null || transaction.type == type)
                if (normalizedFrom == null ||
                    !calendarDate(transaction.transactionDate)
                        .isBefore(normalizedFrom))
                  if (normalizedUntil == null ||
                      calendarDate(
                        transaction.transactionDate,
                      ).isBefore(normalizedUntil.add(const Duration(days: 1))))
                    if (search.isEmpty ||
                        transaction.description.toLowerCase().contains(
                          search,
                        ) ||
                        (accountById[transaction.accountId]?.name
                                    .toLowerCase() ??
                                '')
                            .contains(search) ||
                        (_transferPeer(
                                  transaction,
                                  transfers,
                                  accountById,
                                )?.toLowerCase() ??
                                '')
                            .contains(search) ||
                        (categoryById[transaction.categoryId]?.name
                                    .toLowerCase() ??
                                '')
                            .contains(search))
                      TransactionEntry(
                        transaction: transaction,
                        accountName:
                            accountById[transaction.accountId]?.name ?? 'Счет',
                        categoryName:
                            categoryById[transaction.categoryId]?.name,
                        categoryColor:
                            categoryById[transaction.categoryId]?.color,
                        transferPeerAccountName: _transferPeer(
                          transaction,
                          transfers,
                          accountById,
                        ),
                        transferPeerAccountId: _transferPeerId(
                          transaction,
                          transfers,
                        ),
                        isTransferSource:
                            transaction.transferGroupId == transaction.id,
                      ),
    ];
  }

  String? _transferPeer(
    Transaction transaction,
    Map<int, List<Transaction>> transfers,
    Map<int, Account> accounts,
  ) {
    final groupId = transaction.transferGroupId;
    if (groupId == null) return null;
    final pair = transfers[groupId];
    if (pair == null) return null;
    final peer = pair.where((item) => item.id != transaction.id).firstOrNull;
    return peer == null ? null : accounts[peer.accountId]?.name;
  }

  int? _transferPeerId(
    Transaction transaction,
    Map<int, List<Transaction>> transfers,
  ) {
    final groupId = transaction.transferGroupId;
    if (groupId == null) return null;
    return transfers[groupId]
        ?.where((item) => item.id != transaction.id)
        .firstOrNull
        ?.accountId;
  }

  Future<int> addTransaction({
    required String type,
    required int accountId,
    required int amount,
    required DateTime date,
    int? categoryId,
    String description = '',
    bool isExcludedFromStatistics = false,
  }) async {
    if (type != 'INCOME' && type != 'EXPENSE') {
      throw ArgumentError.value(type, 'type');
    }
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    return _database.transaction(() async {
      final account = await _activeAccount(accountId);
      final category = await _categoryForType(categoryId, type);
      final transactionId = await _database
          .into(_database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: account.id,
              categoryId: Value(category?.id),
              type: type,
              amount: amount,
              currency: Value(account.currency),
              description: Value(description.trim()),
              transactionDate: calendarDate(date),
              isExcludedFromStatistics: Value(isExcludedFromStatistics),
            ),
          );
      await _changeBalance(account.id, type == 'INCOME' ? amount : -amount);
      return transactionId;
    });
  }

  Future<int> addTransfer({
    required int sourceAccountId,
    required int targetAccountId,
    required int amount,
    required DateTime date,
    String description = '',
  }) async {
    if (sourceAccountId == targetAccountId) {
      throw ArgumentError('Source and destination accounts must differ.');
    }
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    return _database.transaction(() async {
      final source = await _activeAccount(sourceAccountId);
      final target = await _activeAccount(targetAccountId);
      if (source.currency != target.currency) {
        throw ArgumentError('Transfers require accounts in the same currency.');
      }
      final normalizedDate = calendarDate(date);
      final memo = Value(description.trim());
      final categoryId = target.isDeposit
          ? await _depositTransferCategoryId()
          : null;
      final sourceId = await _database
          .into(_database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: source.id,
              categoryId: Value(categoryId),
              type: 'TRANSFER',
              amount: amount,
              currency: Value(source.currency),
              description: memo,
              transactionDate: normalizedDate,
            ),
          );
      await (_database.update(_database.transactions)
            ..where((row) => row.id.equals(sourceId)))
          .write(TransactionsCompanion(transferGroupId: Value(sourceId)));
      await _database
          .into(_database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: target.id,
              categoryId: Value(categoryId),
              type: 'TRANSFER',
              amount: amount,
              currency: Value(target.currency),
              description: memo,
              transactionDate: normalizedDate,
              transferGroupId: Value(sourceId),
            ),
          );
      await _changeBalance(source.id, -amount);
      await _changeBalance(target.id, amount);
      return sourceId;
    });
  }

  Future<void> updateTransaction({
    required int id,
    required String type,
    required int accountId,
    required int amount,
    required DateTime date,
    int? categoryId,
    required String description,
    required bool isExcludedFromStatistics,
  }) async {
    if (type != 'INCOME' && type != 'EXPENSE') {
      throw ArgumentError.value(type, 'type');
    }
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await _database.transaction(() async {
      final original = await _getTransaction(id);
      if (original.type == 'TRANSFER') {
        throw StateError('Transfers must be edited as a pair.');
      }
      if (original.linkedPaymentOccurrenceId != null && type != 'EXPENSE') {
        throw StateError('A payment transaction must remain an expense.');
      }
      final targetAccount = await _activeAccount(accountId);
      final category = await _categoryForType(categoryId, type);
      await _adjustLinkedOccurrence(original, amount);
      await _changeBalance(
        original.accountId,
        _balanceEffect(original.type, original.amount) * -1,
      );
      await _changeBalance(targetAccount.id, _balanceEffect(type, amount));
      await (_database.update(
        _database.transactions,
      )..where((row) => row.id.equals(id))).write(
        TransactionsCompanion(
          accountId: Value(targetAccount.id),
          categoryId: Value(category?.id),
          type: Value(type),
          amount: Value(amount),
          currency: Value(targetAccount.currency),
          description: Value(description.trim()),
          transactionDate: Value(calendarDate(date)),
          updatedAt: Value(DateTime.now()),
          isExcludedFromStatistics: Value(isExcludedFromStatistics),
        ),
      );
    });
  }

  Future<void> updateTransfer({
    required int transactionId,
    required int sourceAccountId,
    required int targetAccountId,
    required int amount,
    required DateTime date,
    required String description,
  }) async {
    if (sourceAccountId == targetAccountId) {
      throw ArgumentError('Source and destination accounts must differ.');
    }
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await _database.transaction(() async {
      final transfer = await _getTransaction(transactionId);
      if (transfer.type != 'TRANSFER' || transfer.transferGroupId == null) {
        throw StateError('Transfer pair not found.');
      }
      final pair =
          await (_database.select(_database.transactions)
                ..where(
                  (row) =>
                      row.transferGroupId.equals(transfer.transferGroupId!),
                )
                ..orderBy([(row) => OrderingTerm.asc(row.id)]))
              .get();
      if (pair.length != 2) throw StateError('Transfer pair is incomplete.');
      final source = await _activeAccount(sourceAccountId);
      final target = await _activeAccount(targetAccountId);
      if (source.currency != target.currency) {
        throw ArgumentError('Transfers require accounts in the same currency.');
      }
      final oldSource = pair.first;
      final oldTarget = pair.last;
      final categoryId = target.isDeposit
          ? await _depositTransferCategoryId()
          : null;
      await _changeBalance(oldSource.accountId, oldSource.amount);
      await _changeBalance(oldTarget.accountId, -oldTarget.amount);
      final normalizedDate = calendarDate(date);
      final memo = description.trim();
      await (_database.update(
        _database.transactions,
      )..where((row) => row.id.equals(oldSource.id))).write(
        TransactionsCompanion(
          accountId: Value(source.id),
          categoryId: Value(categoryId),
          amount: Value(amount),
          currency: Value(source.currency),
          description: Value(memo),
          transactionDate: Value(normalizedDate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await (_database.update(
        _database.transactions,
      )..where((row) => row.id.equals(oldTarget.id))).write(
        TransactionsCompanion(
          accountId: Value(target.id),
          categoryId: Value(categoryId),
          amount: Value(amount),
          currency: Value(target.currency),
          description: Value(memo),
          transactionDate: Value(normalizedDate),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await _changeBalance(source.id, -amount);
      await _changeBalance(target.id, amount);
    });
  }

  Future<void> deleteTransaction(int id) async {
    await _database.transaction(() async {
      final transaction = await _getTransaction(id);
      if (transaction.type == 'TRANSFER') {
        final groupId = transaction.transferGroupId;
        if (groupId == null) throw StateError('Transfer pair not found.');
        final pair = await (_database.select(
          _database.transactions,
        )..where((row) => row.transferGroupId.equals(groupId))).get();
        if (pair.length != 2) throw StateError('Transfer pair is incomplete.');
        for (final item in pair) {
          final effect = item.id == groupId ? item.amount : -item.amount;
          await _changeBalance(item.accountId, effect);
        }
        await (_database.delete(
          _database.transactions,
        )..where((row) => row.transferGroupId.equals(groupId))).go();
        return;
      }
      if (transaction.linkedPaymentOccurrenceId != null) {
        await _adjustLinkedOccurrence(transaction, 0);
      }
      await _changeBalance(
        transaction.accountId,
        _balanceEffect(transaction.type, transaction.amount) * -1,
      );
      await (_database.delete(
        _database.transactions,
      )..where((row) => row.id.equals(id))).go();
    });
  }

  Future<Transaction> _getTransaction(int id) => (_database.select(
    _database.transactions,
  )..where((row) => row.id.equals(id))).getSingle();

  Future<Account> _activeAccount(int id) async {
    final account = await (_database.select(
      _database.accounts,
    )..where((row) => row.id.equals(id))).getSingle();
    if (!account.isActive) throw StateError('Account is inactive.');
    return account;
  }

  Future<int> _depositTransferCategoryId() async =>
      (await (_database.select(_database.categories)..where(
                (row) =>
                    row.name.equals(depositTransferCategoryName) &
                    row.type.equals('EXPENSE') &
                    row.isHidden.equals(true),
              ))
              .getSingle())
          .id;

  Future<Category?> _categoryForType(int? categoryId, String type) async {
    if (categoryId == null) return null;
    final category = await (_database.select(
      _database.categories,
    )..where((row) => row.id.equals(categoryId))).getSingle();
    final expectedType = type == 'INCOME' ? 'INCOME' : 'EXPENSE';
    if (category.isArchived || category.type != expectedType) {
      throw ArgumentError(
        'Choose an active category for this transaction type.',
      );
    }
    return category;
  }

  Future<void> _changeBalance(int accountId, int difference) async {
    final account = await (_database.select(
      _database.accounts,
    )..where((row) => row.id.equals(accountId))).getSingle();
    await (_database.update(
      _database.accounts,
    )..where((row) => row.id.equals(accountId))).write(
      AccountsCompanion(
        currentBalance: Value(account.currentBalance + difference),
      ),
    );
  }

  int _balanceEffect(String type, int amount) =>
      type == 'INCOME' ? amount : -amount;

  Future<void> _adjustLinkedOccurrence(
    Transaction original,
    int updatedAmount,
  ) async {
    final occurrenceId = original.linkedPaymentOccurrenceId;
    if (occurrenceId == null) return;
    final occurrence = await (_database.select(
      _database.paymentOccurrences,
    )..where((row) => row.id.equals(occurrenceId))).getSingle();
    final newPaidAmount =
        occurrence.paidAmount - original.amount + updatedAmount;
    if (newPaidAmount < 0 || newPaidAmount > occurrence.expectedAmount) {
      throw ArgumentError(
        'Updated transaction amount must not exceed the payment amount due.',
      );
    }
    final status = newPaidAmount == occurrence.expectedAmount
        ? 'PAID'
        : newPaidAmount > 0
        ? 'PARTIALLY_PAID'
        : occurrence.dueDate.isBefore(calendarDate(DateTime.now()))
        ? 'OVERDUE'
        : 'UPCOMING';
    final otherLinkedTransactions = newPaidAmount == 0
        ? <Transaction>[]
        : await (_database.select(_database.transactions)..where(
                (row) =>
                    row.linkedPaymentOccurrenceId.equals(occurrenceId) &
                    row.id.isNotValue(original.id),
              ))
              .get();
    await (_database.update(
      _database.paymentOccurrences,
    )..where((row) => row.id.equals(occurrenceId))).write(
      PaymentOccurrencesCompanion(
        paidAmount: Value(newPaidAmount),
        status: Value(status),
        linkedTransactionId: newPaidAmount == 0
            ? const Value(null)
            : Value(
                otherLinkedTransactions.isEmpty
                    ? original.id
                    : otherLinkedTransactions.last.id,
              ),
      ),
    );
  }
}
