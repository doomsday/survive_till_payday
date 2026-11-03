import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import 'domain/analytics_models.dart';
import 'domain/analytics_service.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(ref.watch(databaseProvider));
});

final analyticsReportProvider =
    StreamProvider.family<AnalyticsReport, AnalyticsQuery>((ref, query) {
      return ref.watch(analyticsRepositoryProvider).watchReport(query);
    });

final analyticsCurrenciesProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(analyticsRepositoryProvider).watchCurrencies();
});

class AnalyticsRepository {
  AnalyticsRepository(
    this._database, {
    this._service = const AnalyticsService(),
  });

  final AppDatabase _database;
  final AnalyticsService _service;

  Stream<List<String>> watchCurrencies() => _database
      .customSelect(
        'SELECT DISTINCT currency FROM transactions ORDER BY currency',
        readsFrom: {_database.transactions},
      )
      .watch()
      .map((rows) => rows.map((row) => row.read<String>('currency')).toList());

  Stream<AnalyticsReport> watchReport(AnalyticsQuery query) => _database
      .customSelect(
        'SELECT 1',
        readsFrom: {
          _database.transactions,
          _database.categories,
          _database.accounts,
        },
      )
      .watch()
      .asyncMap(
        (_) async => _service.buildReport(
          transactions: await _readTransactions(query),
          query: query,
        ),
      );

  Future<AnalyticsReport> getReport(AnalyticsQuery query) async => _service
      .buildReport(transactions: await _readTransactions(query), query: query);

  Future<List<AnalyticsTransaction>> _readTransactions(
    AnalyticsQuery query,
  ) async {
    final comparison = query.comparisonRange;
    final from = query.range.start.isBefore(comparison.start)
        ? query.range.start
        : comparison.start;
    final until = query.range.endExclusive.isAfter(comparison.endExclusive)
        ? query.range.endExclusive
        : comparison.endExclusive;
    final transactions =
        await (_database.select(_database.transactions)..where(
              (transaction) =>
                  transaction.currency.equals(query.currency) &
                  transaction.transactionDate.isBiggerOrEqualValue(from) &
                  transaction.transactionDate.isSmallerThanValue(until),
            ))
            .get();
    final categories = await _database.select(_database.categories).get();
    final accounts = await _database.select(_database.accounts).get();
    final categoriesById = {
      for (final category in categories) category.id: category,
    };
    final accountsById = {for (final account in accounts) account.id: account};
    return [
      for (final transaction in transactions)
        AnalyticsTransaction(
          id: transaction.id,
          type: transaction.type,
          amount: transaction.amount,
          currency: transaction.currency,
          date: transaction.transactionDate,
          description: transaction.description,
          isExcludedFromStatistics: transaction.isExcludedFromStatistics,
          isRecurring: transaction.linkedPaymentOccurrenceId != null,
          isNoWithdrawalTransfer:
              transaction.type == 'TRANSFER' &&
              transaction.transferGroupId != null &&
              transaction.transferGroupId != transaction.id &&
              accountsById[transaction.accountId]?.isNoWithdrawal == true,
          categoryId: transaction.categoryId,
          categoryName: categoriesById[transaction.categoryId]?.name,
          categoryColor: categoriesById[transaction.categoryId]?.color,
        ),
    ];
  }
}
