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
}
