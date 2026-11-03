import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/planning/domain/financial_planning_service.dart';

void main() {
  late AppDatabase database;
  late FinancialPlanningService planning;
  final today = DateTime(2026, 11, 2);

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    planning = FinancialPlanningService(database);
  });

  tearDown(() async {
    await database.close();
  });

  Future<int> addAccount({int balance = 100000}) {
    return database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Основной',
            currentBalance: Value(balance),
          ),
        );
  }

  test(
    'generates occurrences once and excludes paid portions from obligations',
    () async {
      final accountId = await addAccount();
      await planning.createRecurringPayment(
        name: 'Интернет',
        amount: 10000,
        frequency: 'MONTHLY',
        startDate: today,
      );
      final before = await database.select(database.paymentOccurrences).get();
      await planning.generateOccurrences(now: today);
      final after = await database.select(database.paymentOccurrences).get();
      expect(after.length, before.length);

      await planning.setNextPayday(DateTime(2026, 11, 7));
      await planning.setReserve(20000, enabled: true);
      var snapshot = await planning.getSnapshot(now: today);
      expect(snapshot.reservedPayments, 10000);
      expect(snapshot.safeToSpend, 70000);

      final dueToday = after.firstWhere((item) => item.dueDate == today);
      await planning.payOccurrence(
        occurrence: dueToday,
        accountId: accountId,
        amount: 4000,
        paidDate: today,
      );
      snapshot = await planning.getSnapshot(now: today);
      expect(snapshot.currentBalance, 96000);
      expect(snapshot.reservedPayments, 6000);
      expect(snapshot.safeToSpend, 70000);

      final partiallyPaid = await (database.select(
        database.paymentOccurrences,
      )..where((row) => row.id.equals(dueToday.id))).getSingle();
      await planning.payOccurrence(
        occurrence: partiallyPaid,
        accountId: accountId,
        amount: 6000,
        paidDate: today,
      );
      snapshot = await planning.getSnapshot(now: today);
      expect(snapshot.currentBalance, 90000);
      expect(snapshot.reservedPayments, 0);
      expect(snapshot.safeToSpend, 70000);
    },
  );

  test(
    'no-withdrawal account balances do not increase available limits',
    () async {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Доступный',
              currentBalance: const Value(60000),
            ),
          );
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Без снятия',
              currentBalance: const Value(40000),
              isNoWithdrawal: const Value(true),
            ),
          );
      await planning.setNextPayday(DateTime(2026, 11, 7));

      final snapshot = await planning.getSnapshot(now: today);

      expect(snapshot.currentBalance, 60000);
      expect(snapshot.safeToSpend, 60000);
      expect(snapshot.dailySafeToSpend, 12000);
    },
  );

  test(
    'recurring payments accept expense categories and retain them on edit',
    () async {
      final categories = await database.select(database.categories).get();
      final expense = categories.firstWhere(
        (category) => category.name == 'Продукты',
      );
      final income = categories.firstWhere(
        (category) => category.type == 'INCOME',
      );

      await planning.createRecurringPayment(
        name: 'Покупки продуктов',
        amount: 15000,
        frequency: 'MONTHLY',
        startDate: today,
        categoryId: expense.id,
      );
      var payment =
          (await database.select(database.recurringPayments).get()).single;
      expect(payment.categoryId, expense.id);

      final archivedId = await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Архивная категория',
              type: 'EXPENSE',
              isArchived: const Value(true),
            ),
          );
      await planning.updateRecurringPayment(
        id: payment.id,
        name: payment.name,
        amount: payment.amount,
        frequency: payment.frequency,
        startDate: payment.startDate,
        categoryId: payment.categoryId,
        isActive: payment.isActive,
      );
      payment =
          (await database.select(database.recurringPayments).get()).single;
      expect(payment.categoryId, expense.id);

      final accountId = await addAccount();
      final occurrence =
          (await (database.select(database.paymentOccurrences)
                    ..where((row) => row.recurringPaymentId.equals(payment.id)))
                  .get())
              .first;
      await planning.payOccurrence(
        occurrence: occurrence,
        accountId: accountId,
        amount: 15000,
        paidDate: today,
      );
      final paidTransaction =
          (await (database.select(database.transactions)..where(
                    (row) =>
                        row.linkedPaymentOccurrenceId.equals(occurrence.id),
                  ))
                  .get())
              .single;
      expect(paidTransaction.categoryId, expense.id);

      await expectLater(
        planning.updateRecurringPayment(
          id: payment.id,
          name: payment.name,
          amount: payment.amount,
          frequency: payment.frequency,
          startDate: payment.startDate,
          categoryId: income.id,
          isActive: payment.isActive,
        ),
        throwsArgumentError,
      );
      await expectLater(
        planning.updateRecurringPayment(
          id: payment.id,
          name: payment.name,
          amount: payment.amount,
          frequency: payment.frequency,
          startDate: payment.startDate,
          categoryId: archivedId,
          isActive: payment.isActive,
        ),
        throwsArgumentError,
      );
    },
  );

  test(
    'auto-pay closes due occurrences and records a single linked expense',
    () async {
      final accountId = await addAccount(balance: 46000);
      final category = (await database.select(database.categories).get())
          .firstWhere((item) => item.name == 'Коммунальные услуги');
      final scheduleId = await database
          .into(database.recurringPayments)
          .insert(
            RecurringPaymentsCompanion.insert(
              name: 'Коммуналка',
              amount: 12000,
              categoryId: Value(category.id),
              accountId: Value(accountId),
              frequency: 'MONTHLY',
              startDate: today,
              isAutoPay: const Value(true),
            ),
          );
      final occurrenceId = await database
          .into(database.paymentOccurrences)
          .insert(
            PaymentOccurrencesCompanion.insert(
              recurringPaymentId: scheduleId,
              expectedAmount: 14000,
              paidAmount: const Value(4000),
              dueDate: DateTime(2026, 11, 2),
              status: const Value('PARTIALLY_PAID'),
            ),
          );
      await database
          .into(database.recurringPayments)
          .insert(
            RecurringPaymentsCompanion.insert(
              name: 'Интернет',
              amount: 5000,
              accountId: Value(accountId),
              frequency: 'MONTHLY',
              startDate: today,
              isAutoPay: const Value(true),
            ),
          );

      await planning.generateOccurrences(now: today);
      await planning.generateOccurrences(now: today);

      final occurrence = await (database.select(
        database.paymentOccurrences,
      )..where((row) => row.id.equals(occurrenceId))).getSingle();
      final transactions =
          await (database.select(database.transactions)..where(
                (row) => row.linkedPaymentOccurrenceId.equals(occurrenceId),
              ))
              .get();
      final allAutoTransactions = await (database.select(
        database.transactions,
      )..where((row) => row.linkedPaymentOccurrenceId.isNotNull())).get();
      final account = await (database.select(
        database.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();

      expect(occurrence.status, 'PAID');
      expect(occurrence.paidAmount, 14000);
      expect(allAutoTransactions, hasLength(2));
      expect(transactions.single.amount, 10000);
      expect(transactions.single.categoryId, category.id);
      expect(transactions.single.transactionDate, DateTime(2026, 11, 2));
      expect(account.currentBalance, 31000);
    },
  );

  test('auto-pay requires an active account', () async {
    final category = (await database.select(database.categories).get()).first;
    await expectLater(
      planning.createRecurringPayment(
        name: 'Нет счета',
        amount: 1000,
        frequency: 'MONTHLY',
        startDate: today,
        categoryId: category.id,
        isAutoPay: true,
      ),
      throwsArgumentError,
    );

    final accountId = await database
        .into(database.accounts)
        .insert(
          AccountsCompanion.insert(
            name: 'Неактивный',
            isActive: const Value(false),
          ),
        );
    await expectLater(
      planning.createRecurringPayment(
        name: 'Неактивный счет',
        amount: 1000,
        frequency: 'MONTHLY',
        startDate: today,
        categoryId: category.id,
        accountId: accountId,
        isAutoPay: true,
      ),
      throwsArgumentError,
    );
  });

  test('corrects overdue status when an obligation is in the future', () async {
    final recurringPaymentId = await database
        .into(database.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            name: 'Интернет',
            amount: 5000,
            frequency: 'MONTHLY',
            startDate: DateTime(2026, 11, 5),
          ),
        );
    final occurrenceId = await database
        .into(database.paymentOccurrences)
        .insert(
          PaymentOccurrencesCompanion.insert(
            recurringPaymentId: recurringPaymentId,
            expectedAmount: 5000,
            dueDate: DateTime(2026, 11, 5),
            status: const Value('OVERDUE'),
          ),
        );

    await planning.generateOccurrences(now: today);

    final occurrence = await (database.select(
      database.paymentOccurrences,
    )..where((row) => row.id.equals(occurrenceId))).getSingle();
    expect(occurrence.status, 'UPCOMING');
  });

  test('a received scheduled income is not counted twice', () async {
    final accountId = await addAccount();
    await planning.setNextPayday(DateTime(2026, 11, 12));
    await planning.createIncomeSchedule(
      name: 'Salary',
      amount: 50000,
      frequency: 'MONTHLY',
      expectedDate: DateTime(2026, 11, 4),
    );
    var snapshot = await planning.getSnapshot(now: today);
    expect(snapshot.expectedIncome, 50000);
    expect(snapshot.currentBalance, 100000);
    final schedule =
        (await database.select(database.incomeSchedules).get()).single;

    await planning.receiveIncome(
      schedule: schedule,
      accountId: accountId,
      receivedDate: today,
    );
    snapshot = await planning.getSnapshot(now: today);
    expect(snapshot.expectedIncome, 0);
    expect(snapshot.currentBalance, 150000);
    expect(snapshot.safeToSpend, 150000);

    await expectLater(
      planning.receiveIncome(
        schedule: schedule,
        accountId: accountId,
        receivedDate: today,
      ),
      throwsStateError,
    );

    await planning.setNextPayday(DateTime(2026, 12, 12));
    snapshot = await planning.getSnapshot(now: today);
    expect(snapshot.expectedIncome, 50000);
    final nextSchedule =
        (await database.select(database.incomeSchedules).get()).single;
    expect(nextSchedule.expectedDate, DateTime(2026, 12, 4));
    await planning.receiveIncome(
      schedule: nextSchedule,
      accountId: accountId,
      receivedDate: DateTime(2026, 12, 4),
    );
    snapshot = await planning.getSnapshot(now: today);
    expect(snapshot.currentBalance, 200000);
    expect(snapshot.expectedIncome, 0);
  });

  test(
    'advances to the next salary date after the configured payday passes',
    () async {
      await addAccount();
      await planning.setNextPayday(DateTime(2026, 10, 25));
      await planning.createIncomeSchedule(
        name: 'Salary',
        amount: 150000,
        frequency: 'MONTHLY',
        expectedDate: DateTime(2026, 10, 25),
      );

      final snapshot = await planning.getSnapshot(now: today);

      expect(snapshot.nextPayday, DateTime(2026, 11, 25));
      expect(snapshot.daysUntilPayday, 23);
    },
  );

  test(
    'keeps the original month day when a schedule lands on month end',
    () async {
      final accountId = await addAccount();
      await planning.createIncomeSchedule(
        name: 'Monthly payment',
        amount: 10000,
        frequency: 'MONTHLY',
        expectedDate: DateTime(2026, 1, 31),
      );
      final january =
          (await database.select(database.incomeSchedules).get()).single;

      await planning.receiveIncome(
        schedule: january,
        accountId: accountId,
        receivedDate: DateTime(2026, 1, 31),
      );
      final february =
          (await database.select(database.incomeSchedules).get()).single;
      expect(february.expectedDate, DateTime(2026, 2, 28));

      await planning.receiveIncome(
        schedule: february,
        accountId: accountId,
        receivedDate: DateTime(2026, 2, 28),
      );
      final march =
          (await database.select(database.incomeSchedules).get()).single;
      expect(march.expectedDate, DateTime(2026, 3, 31));
    },
  );

  test(
    'dashboard summarizes only current-month income and eligible expenses',
    () async {
      final accountId = await addAccount();
      final restrictedAccountId = await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Без снятия',
              isNoWithdrawal: const Value(true),
            ),
          );
      final categoryId = await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Продукты',
              type: 'EXPENSE',
              color: const Value(0xFF00AA00),
            ),
          );

      Future<void> addTransaction({
        required String type,
        required int amount,
        required DateTime date,
        int? category,
        bool excluded = false,
      }) async {
        await database
            .into(database.transactions)
            .insert(
              TransactionsCompanion.insert(
                accountId: accountId,
                categoryId: Value(category),
                type: type,
                amount: amount,
                transactionDate: date,
                isExcludedFromStatistics: Value(excluded),
              ),
            );
      }

      await addTransaction(
        type: 'EXPENSE',
        amount: 2000,
        date: today,
        category: categoryId,
      );
      await addTransaction(type: 'EXPENSE', amount: 3000, date: today);
      await addTransaction(type: 'INCOME', amount: 50000, date: today);
      await addTransaction(type: 'TRANSFER', amount: 80000, date: today);
      final transferId = await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'TRANSFER',
              amount: 8000,
              transactionDate: today,
            ),
          );
      await (database.update(database.transactions)
            ..where((row) => row.id.equals(transferId)))
          .write(TransactionsCompanion(transferGroupId: Value(transferId)));
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: restrictedAccountId,
              type: 'TRANSFER',
              amount: 8000,
              transactionDate: today,
              transferGroupId: Value(transferId),
            ),
          );
      final outgoingTransferId = await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: restrictedAccountId,
              type: 'TRANSFER',
              amount: 4000,
              transactionDate: today,
            ),
          );
      await (database.update(
        database.transactions,
      )..where((row) => row.id.equals(outgoingTransferId))).write(
        TransactionsCompanion(transferGroupId: Value(outgoingTransferId)),
      );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'TRANSFER',
              amount: 4000,
              transactionDate: today,
              transferGroupId: Value(outgoingTransferId),
            ),
          );
      await addTransaction(
        type: 'EXPENSE',
        amount: 9000,
        date: today,
        excluded: true,
      );
      await addTransaction(
        type: 'EXPENSE',
        amount: 7000,
        date: DateTime(2026, 10, 31),
      );
      await planning.createRecurringPayment(
        name: 'Интернет',
        amount: 12000,
        frequency: 'MONTHLY',
        startDate: DateTime(2026, 11, 4),
      );
      await planning.generateOccurrences(now: today);

      final data = await planning.getDashboardData(now: today);

      expect(data.monthIncome, 50000);
      expect(data.monthExpense, 13000);
      expect(data.categorySpending, hasLength(2));
      expect(data.categorySpending.first.name, 'Без категории');
      expect(data.categorySpending.first.amount, 11000);
      expect(data.categorySpending.last.name, 'Продукты');
      expect(data.categorySpending.last.color, 0xFF00AA00);
      expect(data.recentTransactions, hasLength(5));
      expect(data.upcomingPayments, hasLength(1));
      expect(data.upcomingPayments.single.name, 'Интернет');
    },
  );

  test(
    'dashboard recent transactions match operations order and count',
    () async {
      final accountId = await addAccount();
      final transactionIds = <int>[];
      for (var index = 0; index < 7; index++) {
        transactionIds.add(
          await database
              .into(database.transactions)
              .insert(
                TransactionsCompanion.insert(
                  accountId: accountId,
                  type: 'EXPENSE',
                  amount: 1000,
                  transactionDate: today,
                ),
              ),
        );
      }

      final data = await planning.getDashboardData(now: today);

      expect(
        data.recentTransactions.map((item) => item.transaction.id),
        transactionIds.reversed.take(5),
      );
      expect(data.remainingTransactionsThisMonth, 2);
    },
  );
}
