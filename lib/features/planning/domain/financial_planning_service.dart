import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

DateTime calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

enum PlanningFrequency { once, weekly, monthly, quarterly, yearly }

PlanningFrequency parseFrequency(String value) => switch (value.toUpperCase()) {
  'WEEKLY' => PlanningFrequency.weekly,
  'MONTHLY' => PlanningFrequency.monthly,
  'QUARTERLY' => PlanningFrequency.quarterly,
  'YEARLY' => PlanningFrequency.yearly,
  _ => PlanningFrequency.once,
};

String frequencyLabel(PlanningFrequency frequency) => switch (frequency) {
  PlanningFrequency.once => 'Разово',
  PlanningFrequency.weekly => 'Еженедельно',
  PlanningFrequency.monthly => 'Ежемесячно',
  PlanningFrequency.quarterly => 'Ежеквартально',
  PlanningFrequency.yearly => 'Ежегодно',
};

DateTime? nextScheduledDate({
  required DateTime date,
  required PlanningFrequency frequency,
  int? paymentDay,
}) {
  final day = paymentDay ?? date.day;
  return switch (frequency) {
    PlanningFrequency.once => null,
    PlanningFrequency.weekly => calendarDate(date.add(const Duration(days: 7))),
    PlanningFrequency.monthly => _monthDate(date.year, date.month + 1, day),
    PlanningFrequency.quarterly => _monthDate(date.year, date.month + 3, day),
    PlanningFrequency.yearly => _monthDate(date.year + 1, date.month, day),
  };
}

DateTime _monthDate(int year, int month, int day) {
  final first = DateTime(year, month);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, day.clamp(1, lastDay));
}

class FinanceSnapshot {
  const FinanceSnapshot({
    required this.currentBalance,
    required this.expectedIncome,
    required this.reservedPayments,
    required this.reserve,
    required this.nextPayday,
    required this.daysUntilPayday,
    required this.safeToSpend,
    required this.dailySafeToSpend,
  });

  final int currentBalance;
  final int expectedIncome;
  final int reservedPayments;
  final int reserve;
  final DateTime? nextPayday;
  final int? daysUntilPayday;
  final int? safeToSpend;
  final int? dailySafeToSpend;
}

class CategorySpending {
  const CategorySpending({
    required this.name,
    required this.color,
    required this.amount,
  });

  final String name;
  final int color;
  final int amount;
}

class DashboardTransaction {
  const DashboardTransaction({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.categoryColor,
  });

  final Transaction transaction;
  final String accountName;
  final String? categoryName;
  final int? categoryColor;
}

class DashboardPayment {
  const DashboardPayment({required this.occurrence, required this.name});

  final PaymentOccurrence occurrence;
  final String name;
}

class DashboardData {
  const DashboardData({
    required this.monthIncome,
    required this.monthExpense,
    required this.categorySpending,
    required this.recentTransactions,
    required this.upcomingPayments,
  });

  final int monthIncome;
  final int monthExpense;
  final List<CategorySpending> categorySpending;
  final List<DashboardTransaction> recentTransactions;
  final List<DashboardPayment> upcomingPayments;
}

FinanceSnapshot calculateFinanceSnapshot({
  required int currentBalance,
  required int expectedIncome,
  required int reservedPayments,
  required int reserve,
  required DateTime today,
  required DateTime? nextPayday,
}) {
  final normalizedToday = calendarDate(today);
  final normalizedPayday = switch (nextPayday) {
    null => null,
    final date => calendarDate(date),
  };
  final days = normalizedPayday?.difference(normalizedToday).inDays;
  final safeToSpend = switch (normalizedPayday) {
    null => null,
    _ => currentBalance + expectedIncome - reservedPayments - reserve,
  };
  return FinanceSnapshot(
    currentBalance: currentBalance,
    expectedIncome: expectedIncome,
    reservedPayments: reservedPayments,
    reserve: reserve,
    nextPayday: normalizedPayday,
    daysUntilPayday: days,
    safeToSpend: safeToSpend,
    dailySafeToSpend: safeToSpend == null || days == null || days <= 0
        ? null
        : (safeToSpend < 0 ? 0 : safeToSpend) ~/ days,
  );
}

class FinancialPlanningService {
  FinancialPlanningService(this.db);

  final AppDatabase db;

  static const _reserveKey = 'financial_reserve';
  static const _paydayKey = 'next_payday';
  static const _reserveEnabledKey = 'financial_reserve_enabled';

  Stream<List<PaymentOccurrence>> watchOccurrences() async* {
    await generateOccurrences();
    yield* (db.select(
      db.paymentOccurrences,
    )..orderBy([(row) => OrderingTerm.asc(row.dueDate)])).watch();
  }

  Stream<List<RecurringPayment>> watchRecurringPayments() => (db.select(
    db.recurringPayments,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).watch();

  Future<List<RecurringPayment>> getRecurringPayments() => (db.select(
    db.recurringPayments,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();

  Stream<List<IncomeSchedule>> watchIncomeSchedules() => (db.select(
    db.incomeSchedules,
  )..orderBy([(row) => OrderingTerm.asc(row.expectedDate)])).watch();

  Stream<FinanceSnapshot> watchSnapshot() async* {
    await generateOccurrences();
    yield* db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.accounts,
            db.paymentOccurrences,
            db.incomeSchedules,
            db.appSettings,
          },
        )
        .watch()
        .asyncMap((_) => getSnapshot());
  }

  Stream<DashboardData> watchDashboardData() async* {
    yield* db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.transactions,
            db.categories,
            db.accounts,
            db.paymentOccurrences,
            db.recurringPayments,
          },
        )
        .watch()
        .asyncMap((_) => getDashboardData());
  }

  Future<DashboardData> getDashboardData({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    final monthStart = DateTime(today.year, today.month);
    final nextMonth = DateTime(today.year, today.month + 1);
    final currentMonthTransactions =
        await (db.select(db.transactions)..where(
              (row) =>
                  row.transactionDate.isBiggerOrEqualValue(monthStart) &
                  row.transactionDate.isSmallerThanValue(nextMonth) &
                  row.isExcludedFromStatistics.equals(false) &
                  row.type.isIn(['INCOME', 'EXPENSE']),
            ))
            .get();
    var monthIncome = 0;
    var monthExpense = 0;
    final spendingByCategory = <int?, int>{};
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == 'INCOME') {
        monthIncome += transaction.amount;
      } else if (transaction.type == 'EXPENSE') {
        monthExpense += transaction.amount;
        spendingByCategory.update(
          transaction.categoryId,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    final categories = await db.select(db.categories).get();
    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final categorySpending = [
      for (final entry in spendingByCategory.entries)
        CategorySpending(
          name: categoryById[entry.key]?.name ?? 'Без категории',
          color: categoryById[entry.key]?.color ?? 0xFF607D8B,
          amount: entry.value,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final accounts = await db.select(db.accounts).get();
    final accountById = {for (final account in accounts) account.id: account};
    final recent =
        await (db.select(db.transactions)
              ..orderBy([(row) => OrderingTerm.desc(row.transactionDate)])
              ..limit(5))
            .get();
    final recentTransactions = [
      for (final transaction in recent)
        DashboardTransaction(
          transaction: transaction,
          accountName: accountById[transaction.accountId]?.name ?? 'Счет',
          categoryName: categoryById[transaction.categoryId]?.name,
          categoryColor: categoryById[transaction.categoryId]?.color,
        ),
    ];

    final payments =
        await (db.select(db.paymentOccurrences)
              ..where(
                (row) =>
                    row.status.isIn(['UPCOMING', 'PARTIALLY_PAID', 'OVERDUE']) &
                    row.dueDate.isBiggerOrEqualValue(
                      today.subtract(const Duration(days: 30)),
                    ) &
                    row.dueDate.isSmallerThanValue(
                      DateTime(today.year, today.month, today.day + 31),
                    ),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.dueDate)])
              ..limit(5))
            .get();
    final recurring = await db.select(db.recurringPayments).get();
    final paymentNames = {
      for (final payment in recurring) payment.id: payment.name,
    };
    final upcomingPayments = [
      for (final payment in payments)
        DashboardPayment(
          occurrence: payment,
          name: paymentNames[payment.recurringPaymentId] ?? 'Платеж',
        ),
    ];
    return DashboardData(
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      categorySpending: categorySpending,
      recentTransactions: recentTransactions,
      upcomingPayments: upcomingPayments,
    );
  }

  Future<FinanceSnapshot> getSnapshot({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    await generateOccurrences(now: today);
    final activeAccounts = await (db.select(
      db.accounts,
    )..where((account) => account.isActive)).get();
    final currentBalance = activeAccounts.fold<int>(
      0,
      (total, account) => total + account.currentBalance,
    );
    final settings = await db.select(db.appSettings).get();
    final settingValues = {
      for (final setting in settings) setting.key: setting.value,
    };
    final reserveEnabled = settingValues[_reserveEnabledKey] != 'false';
    final reserve = reserveEnabled
        ? int.tryParse(settingValues[_reserveKey] ?? '') ?? 0
        : 0;
    final configuredPayday = DateTime.tryParse(settingValues[_paydayKey] ?? '');
    final incomes = await (db.select(
      db.incomeSchedules,
    )..where((schedule) => schedule.isActive)).get();
    final nextPayday = _resolvePayday(
      configuredPayday,
      incomes,
      today,
      settingValues,
    );
    var expectedIncome = 0;
    if (nextPayday != null && nextPayday.isAfter(today)) {
      for (final income in incomes) {
        var date = calendarDate(income.expectedDate);
        final frequency = parseFrequency(income.frequency);
        final paymentDay =
            int.tryParse(
              settingValues['income_schedule_${income.id}_day'] ?? '',
            ) ??
            income.expectedDate.day;
        for (var index = 0; date.isBefore(today) && index < 600; index++) {
          final next = nextScheduledDate(
            date: date,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          date = next;
        }
        for (
          var index = 0;
          !date.isBefore(today) && date.isBefore(nextPayday) && index < 600;
          index++
        ) {
          expectedIncome += income.expectedAmount;
          final next = nextScheduledDate(
            date: date,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          date = next;
        }
      }
    }

    var reservedPayments = 0;
    if (nextPayday != null) {
      final occurrences =
          await (db.select(db.paymentOccurrences)..where(
                (occurrence) =>
                    occurrence.dueDate.isBiggerOrEqualValue(today) &
                    occurrence.dueDate.isSmallerThanValue(nextPayday),
              ))
              .get();
      for (final occurrence in occurrences) {
        if (occurrence.status == 'PAID' || occurrence.status == 'CANCELLED') {
          continue;
        }
        final remaining = occurrence.expectedAmount - occurrence.paidAmount;
        if (remaining > 0) reservedPayments += remaining;
      }
    }
    return calculateFinanceSnapshot(
      currentBalance: currentBalance,
      expectedIncome: expectedIncome,
      reservedPayments: reservedPayments,
      reserve: reserve,
      today: today,
      nextPayday: nextPayday,
    );
  }

  DateTime? _resolvePayday(
    DateTime? configured,
    List<IncomeSchedule> incomes,
    DateTime today,
    Map<String, String> settings,
  ) {
    if (configured != null && calendarDate(configured).isAfter(today)) {
      return calendarDate(configured);
    }
    DateTime? next;
    for (final income in incomes) {
      if (!income.name.toLowerCase().contains('зарплат') &&
          !income.name.toLowerCase().contains('salary')) {
        continue;
      }
      var date = calendarDate(income.expectedDate);
      final frequency = parseFrequency(income.frequency);
      final paymentDay =
          int.tryParse(settings['income_schedule_${income.id}_day'] ?? '') ??
          income.expectedDate.day;
      for (var index = 0; date.isBefore(today) && index < 600; index++) {
        final following = nextScheduledDate(
          date: date,
          frequency: frequency,
          paymentDay: paymentDay,
        );
        if (following == null) break;
        date = following;
      }
      if (!date.isBefore(today) && (next == null || date.isBefore(next))) {
        next = date;
      }
    }
    return next ??
        (configured != null && !calendarDate(configured).isBefore(today)
            ? calendarDate(configured)
            : null);
  }

  Future<void> setReserve(int amount, {required bool enabled}) async {
    if (amount < 0) throw ArgumentError.value(amount, 'amount');
    await db.transaction(() async {
      await _setSetting(_reserveKey, '$amount');
      await _setSetting(_reserveEnabledKey, '$enabled');
    });
  }

  Future<void> setNextPayday(DateTime? date) async {
    if (date == null) {
      await (db.delete(
        db.appSettings,
      )..where((setting) => setting.key.equals(_paydayKey))).go();
    } else {
      await _setSetting(_paydayKey, calendarDate(date).toIso8601String());
    }
  }

  Future<Map<String, String>> getSettings() async {
    final settings = await db.select(db.appSettings).get();
    return {for (final setting in settings) setting.key: setting.value};
  }

  Future<void> _setSetting(String key, String value) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );

  Future<void> createRecurringPayment({
    required String name,
    required int amount,
    required String frequency,
    required DateTime startDate,
    int? categoryId,
    int? accountId,
    int? paymentDay,
    String description = '',
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await _validateRecurringCategory(categoryId);
    final start = calendarDate(startDate);
    await db
        .into(db.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            name: name.trim(),
            amount: amount,
            categoryId: Value(categoryId),
            accountId: Value(accountId),
            frequency: frequency,
            paymentDay: Value(paymentDay),
            startDate: start,
            description: Value(description),
          ),
        );
    await generateOccurrences(now: start);
  }

  Future<void> updateRecurringPayment({
    required int id,
    required String name,
    required int amount,
    required String frequency,
    required DateTime startDate,
    int? categoryId,
    int? accountId,
    int? paymentDay,
    required bool isActive,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final today = calendarDate(DateTime.now());
    await db.transaction(() async {
      final existing = await (db.select(
        db.recurringPayments,
      )..where((row) => row.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        throw StateError('Recurring payment $id not found.');
      }
      await _validateRecurringCategory(
        categoryId,
        allowArchivedCategoryId: categoryId == existing.categoryId
            ? existing.categoryId
            : null,
      );
      await (db.update(
        db.recurringPayments,
      )..where((row) => row.id.equals(id))).write(
        RecurringPaymentsCompanion(
          name: Value(name.trim()),
          amount: Value(amount),
          categoryId: Value(categoryId),
          accountId: Value(accountId),
          frequency: Value(frequency),
          paymentDay: Value(paymentDay),
          startDate: Value(calendarDate(startDate)),
          isActive: Value(isActive),
        ),
      );
      if (!isActive) {
        await (db.delete(db.paymentOccurrences)..where(
              (row) =>
                  row.recurringPaymentId.equals(id) &
                  row.dueDate.isBiggerOrEqualValue(today) &
                  row.status.equals('UPCOMING'),
            ))
            .go();
      } else {
        await (db.delete(db.paymentOccurrences)..where(
              (row) =>
                  row.recurringPaymentId.equals(id) &
                  row.dueDate.isBiggerOrEqualValue(today) &
                  row.status.equals('UPCOMING'),
            ))
            .go();
      }
    });
    await generateOccurrences();
  }

  Future<void> _validateRecurringCategory(
    int? categoryId, {
    int? allowArchivedCategoryId,
  }) async {
    if (categoryId == null) return;
    final category = await (db.select(
      db.categories,
    )..where((row) => row.id.equals(categoryId))).getSingleOrNull();
    if (category == null ||
        category.type != 'EXPENSE' ||
        (category.isArchived && category.id != allowArchivedCategoryId)) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
  }

  Future<void> generateOccurrences({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    final horizon = _monthDate(today.year, today.month + 12, today.day);
    await db.transaction(() async {
      final schedules = await (db.select(
        db.recurringPayments,
      )..where((row) => row.isActive)).get();
      for (final schedule in schedules) {
        final frequency = parseFrequency(schedule.frequency);
        if (frequency == PlanningFrequency.once) continue;
        final start = calendarDate(schedule.startDate);
        final paymentDay = schedule.paymentDay ?? start.day;
        final lowerBound = calendarDate(
          today.subtract(const Duration(days: 365)),
        );
        var index = 0;
        var dueDate = start;
        while (dueDate.isBefore(lowerBound) && index < 10000) {
          final next = nextScheduledDate(
            date: dueDate,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          dueDate = next;
          index++;
        }
        final existing =
            await (db.select(db.paymentOccurrences)..where(
                  (occurrence) =>
                      occurrence.recurringPaymentId.equals(schedule.id),
                ))
                .get();
        final knownDates = existing
            .map((item) => calendarDate(item.dueDate))
            .toSet();
        for (; !dueDate.isAfter(horizon) && index < 10000; index++) {
          if (schedule.endDate != null &&
              dueDate.isAfter(calendarDate(schedule.endDate!))) {
            break;
          }
          if (!dueDate.isBefore(lowerBound) && !knownDates.contains(dueDate)) {
            await db
                .into(db.paymentOccurrences)
                .insert(
                  PaymentOccurrencesCompanion.insert(
                    recurringPaymentId: schedule.id,
                    expectedAmount: schedule.amount,
                    dueDate: dueDate,
                  ),
                );
          }
          final next = nextScheduledDate(
            date: dueDate,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          dueDate = next;
        }
      }
      final unpaidOccurrences = await (db.select(
        db.paymentOccurrences,
      )..where((row) => row.status.isIn(['UPCOMING', 'OVERDUE']))).get();
      for (final occurrence in unpaidOccurrences) {
        final status = calendarDate(occurrence.dueDate).isBefore(today)
            ? 'OVERDUE'
            : 'UPCOMING';
        if (occurrence.status != status) {
          await (db.update(db.paymentOccurrences)
                ..where((row) => row.id.equals(occurrence.id)))
              .write(PaymentOccurrencesCompanion(status: Value(status)));
        }
      }
    });
  }

  Future<void> updateOccurrence({
    required int id,
    required int amount,
    required DateTime dueDate,
  }) async {
    final occurrence = await (db.select(
      db.paymentOccurrences,
    )..where((row) => row.id.equals(id))).getSingle();
    if (amount <= 0 || amount < occurrence.paidAmount) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than or equal to the amount already paid.',
      );
    }
    if (occurrence.status == 'PAID' || occurrence.status == 'CANCELLED') {
      throw StateError('Paid or cancelled obligations cannot be edited.');
    }
    final normalizedDueDate = calendarDate(dueDate);
    final status = occurrence.paidAmount > 0
        ? 'PARTIALLY_PAID'
        : normalizedDueDate.isBefore(calendarDate(DateTime.now()))
        ? 'OVERDUE'
        : 'UPCOMING';
    await (db.update(
      db.paymentOccurrences,
    )..where((row) => row.id.equals(id))).write(
      PaymentOccurrencesCompanion(
        expectedAmount: Value(amount),
        dueDate: Value(normalizedDueDate),
        status: Value(status),
      ),
    );
  }

  Future<void> cancelOccurrence(int id) async {
    await (db.update(db.paymentOccurrences)..where((row) => row.id.equals(id)))
        .write(const PaymentOccurrencesCompanion(status: Value('CANCELLED')));
  }

  Future<void> payOccurrence({
    required PaymentOccurrence occurrence,
    required int accountId,
    required int amount,
    required DateTime paidDate,
  }) async {
    await db.transaction(() async {
      final currentOccurrence = await (db.select(
        db.paymentOccurrences,
      )..where((row) => row.id.equals(occurrence.id))).getSingle();
      final remaining =
          currentOccurrence.expectedAmount - currentOccurrence.paidAmount;
      if (currentOccurrence.status == 'PAID' ||
          currentOccurrence.status == 'CANCELLED' ||
          amount <= 0 ||
          amount > remaining) {
        throw ArgumentError.value(
          amount,
          'amount',
          'Must be within the remaining amount due.',
        );
      }
      final schedule =
          await (db.select(db.recurringPayments)..where(
                (row) => row.id.equals(currentOccurrence.recurringPaymentId),
              ))
              .getSingle();
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      final totalPaid = currentOccurrence.paidAmount + amount;
      final transactionId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: Value(schedule.categoryId),
              type: 'EXPENSE',
              amount: amount,
              currency: Value(account.currency),
              description: Value(schedule.name),
              transactionDate: calendarDate(paidDate),
              linkedPaymentOccurrenceId: Value(currentOccurrence.id),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(account.currentBalance - amount),
        ),
      );
      await (db.update(
        db.paymentOccurrences,
      )..where((row) => row.id.equals(currentOccurrence.id))).write(
        PaymentOccurrencesCompanion(
          paidAmount: Value(totalPaid),
          status: Value(
            totalPaid == currentOccurrence.expectedAmount
                ? 'PAID'
                : 'PARTIALLY_PAID',
          ),
          linkedTransactionId: Value(transactionId),
        ),
      );
    });
  }

  Future<void> createIncomeSchedule({
    required String name,
    required int amount,
    required String frequency,
    required DateTime expectedDate,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final date = calendarDate(expectedDate);
    await db.transaction(() async {
      final id = await db
          .into(db.incomeSchedules)
          .insert(
            IncomeSchedulesCompanion.insert(
              name: name.trim(),
              expectedAmount: amount,
              frequency: frequency,
              expectedDate: date,
            ),
          );
      await _setSetting('income_schedule_${id}_day', '${date.day}');
    });
  }

  Future<void> updateIncomeSchedule({
    required int id,
    required String name,
    required int amount,
    required String frequency,
    required DateTime expectedDate,
    required bool isActive,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final old = await (db.select(
      db.incomeSchedules,
    )..where((row) => row.id.equals(id))).getSingle();
    final normalizedDate = calendarDate(expectedDate);
    await db.transaction(() async {
      await (db.update(
        db.incomeSchedules,
      )..where((row) => row.id.equals(id))).write(
        IncomeSchedulesCompanion(
          name: Value(name.trim()),
          expectedAmount: Value(amount),
          frequency: Value(frequency),
          expectedDate: Value(normalizedDate),
          isActive: Value(isActive),
        ),
      );
      if (old.expectedDate != normalizedDate) {
        await _setSetting('income_schedule_${id}_day', '${normalizedDate.day}');
      }
    });
  }

  Future<void> receiveIncome({
    required IncomeSchedule schedule,
    required int accountId,
    required DateTime receivedDate,
  }) async {
    await db.transaction(() async {
      final currentSchedule = await (db.select(
        db.incomeSchedules,
      )..where((row) => row.id.equals(schedule.id))).getSingle();
      if (!currentSchedule.isActive ||
          calendarDate(currentSchedule.expectedDate) !=
              calendarDate(schedule.expectedDate)) {
        throw StateError(
          'This expected income has already been received or changed.',
        );
      }
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      final transactionId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'INCOME',
              amount: currentSchedule.expectedAmount,
              currency: Value(account.currency),
              description: Value(currentSchedule.name),
              transactionDate: calendarDate(receivedDate),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(
            account.currentBalance + currentSchedule.expectedAmount,
          ),
        ),
      );
      final settings = await getSettings();
      final paymentDay =
          int.tryParse(
            settings['income_schedule_${currentSchedule.id}_day'] ?? '',
          ) ??
          currentSchedule.expectedDate.day;
      final nextDate = nextScheduledDate(
        date: currentSchedule.expectedDate,
        frequency: parseFrequency(currentSchedule.frequency),
        paymentDay: paymentDay,
      );
      await (db.update(
        db.incomeSchedules,
      )..where((row) => row.id.equals(currentSchedule.id))).write(
        IncomeSchedulesCompanion(
          expectedDate: Value(nextDate ?? currentSchedule.expectedDate),
          isActive: Value(nextDate != null),
          linkedTransactionId: Value(transactionId),
        ),
      );
    });
  }

  Future<List<Account>> getActiveAccounts() =>
      (db.select(db.accounts)
            ..where((account) => account.isActive)
            ..orderBy([(account) => OrderingTerm.asc(account.name)]))
          .get();

  Future<List<Category>> getExpenseCategories() =>
      (db.select(db.categories)
            ..where(
              (category) =>
                  category.type.equals('EXPENSE') &
                  category.isArchived.equals(false),
            )
            ..orderBy([(category) => OrderingTerm.asc(category.name)]))
          .get();

  Future<void> addManualExpense({
    required int accountId,
    required int amount,
    required String description,
    int? categoryId,
    DateTime? date,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await db.transaction(() async {
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: Value(categoryId),
              type: 'EXPENSE',
              amount: amount,
              currency: Value(account.currency),
              description: Value(description.trim()),
              transactionDate: calendarDate(date ?? DateTime.now()),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(account.currentBalance - amount),
        ),
      );
    });
  }
}
