import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/features/planning/domain/financial_planning_service.dart';

void main() {
  group('calculateFinanceSnapshot', () {
    final today = DateTime(2026, 11, 2, 20);

    test('includes expected income and subtracts remaining obligations and reserve', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 300000,
        expectedIncome: 50000,
        reservedPayments: 40000,
        reserve: 100000,
        today: today,
        nextPayday: DateTime(2026, 11, 7),
      );

      expect(result.safeToSpend, 210000);
      expect(result.daysUntilPayday, 5);
      expect(result.dailySafeToSpend, 42000);
    });

    test('does not show a negative daily limit for a deficit', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 10000,
        expectedIncome: 0,
        reservedPayments: 30000,
        reserve: 5000,
        today: today,
        nextPayday: DateTime(2026, 11, 7),
      );

      expect(result.safeToSpend, -25000);
      expect(result.dailySafeToSpend, 0);
    });

    test('omits safe-to-spend and daily limit without a payday', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 100000,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: null,
      );

      expect(result.safeToSpend, isNull);
      expect(result.dailySafeToSpend, isNull);
      expect(result.daysUntilPayday, isNull);
    });

    test('does not divide by zero on payday', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 100000,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: DateTime(2026, 11, 2),
      );

      expect(result.daysUntilPayday, 0);
      expect(result.dailySafeToSpend, isNull);
    });

    test('carries unused and overspent amounts into today', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 0,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: DateTime(2026, 11, 7),
        periodDays: 10,
        elapsedDays: 5,
        expensesBeforeToday: 8000,
        expensesToday: 3000,
      );

      expect(result.dailySafeToSpend, 1100);
      expect(result.accumulatedBalance, -2500);
      expect(result.availableToday, -1400);
      expect(result.todayExpenses, 3000);
      expect(result.dailyLimitBalance, -1900);
      expect(result.dayBalance, -4400);
    });

    test('adds past savings to today after spending below the daily limit', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 7235,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: DateTime(2026, 11, 12),
        periodDays: 10,
        elapsedDays: 2,
        expensesBeforeToday: 1500,
        expensesToday: 1265,
      );

      expect(result.dailySafeToSpend, 1000);
      expect(result.accumulatedBalance, 500);
      expect(result.availableToday, 1500);
      expect(result.dayBalance, 235);
    });

    test('has no past savings when spending exactly on the daily limit', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 8000,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: DateTime(2026, 11, 12),
        periodDays: 10,
        elapsedDays: 2,
        expensesBeforeToday: 2000,
      );

      expect(result.accumulatedBalance, 0);
      expect(result.availableToday, 1000);
    });

    test('does not count past overspending as savings for today', () {
      final result = calculateFinanceSnapshot(
        currentBalance: 7500,
        expectedIncome: 0,
        reservedPayments: 0,
        reserve: 0,
        today: today,
        nextPayday: DateTime(2026, 11, 12),
        periodDays: 10,
        elapsedDays: 2,
        expensesBeforeToday: 2500,
      );

      expect(result.accumulatedBalance, -500);
      expect(result.availableToday, 500);
    });

    test(
      'unavoidable expenses reduce the payday budget but not daily spending',
      () {
        final withoutUnavoidableExpense = calculateFinanceSnapshot(
          currentBalance: 8000,
          expectedIncome: 0,
          reservedPayments: 0,
          reserve: 0,
          today: today,
          nextPayday: DateTime(2026, 11, 12),
          periodDays: 10,
          elapsedDays: 2,
          expensesBeforeToday: 1000,
          expensesToday: 500,
        );
        final withUnavoidableExpense = calculateFinanceSnapshot(
          currentBalance: 3000,
          expectedIncome: 0,
          reservedPayments: 0,
          reserve: 0,
          today: today,
          nextPayday: DateTime(2026, 11, 12),
          periodDays: 10,
          elapsedDays: 2,
          expensesBeforeToday: 1000,
          expensesToday: 500,
          unavoidableExpensesInPeriod: 5000,
        );

        expect(withUnavoidableExpense.safeToSpend, 3000);
        expect(withUnavoidableExpense.dailySafeToSpend, 950);
        expect(
          withUnavoidableExpense.dailySafeToSpend,
          withoutUnavoidableExpense.dailySafeToSpend,
        );
        expect(withUnavoidableExpense.todayExpenses, 500);
        expect(withUnavoidableExpense.dayBalance, 1350);
      },
    );
  });

  group('scheduled dates', () {
    test(
      'clamps monthly occurrences to month end without losing anchor day',
      () {
        final february = nextScheduledDate(
          date: DateTime(2026, 1, 31),
          frequency: PlanningFrequency.monthly,
          paymentDay: 31,
        );
        final march = nextScheduledDate(
          date: february!,
          frequency: PlanningFrequency.monthly,
          paymentDay: 31,
        );

        expect(february, DateTime(2026, 2, 28));
        expect(march, DateTime(2026, 3, 31));
      },
    );

    test('advances weekly, quarterly, yearly and one-off schedules', () {
      expect(
        nextScheduledDate(
          date: DateTime(2026, 1, 5),
          frequency: PlanningFrequency.weekly,
        ),
        DateTime(2026, 1, 12),
      );
      expect(
        nextScheduledDate(
          date: DateTime(2026, 1, 31),
          frequency: PlanningFrequency.quarterly,
          paymentDay: 31,
        ),
        DateTime(2026, 4, 30),
      );
      expect(
        nextScheduledDate(
          date: DateTime(2024, 2, 29),
          frequency: PlanningFrequency.yearly,
          paymentDay: 29,
        ),
        DateTime(2025, 2, 28),
      );
      expect(
        nextScheduledDate(
          date: DateTime(2026, 1, 5),
          frequency: PlanningFrequency.once,
        ),
        isNull,
      );
    });

    test('computes a prior scheduled date using its original payment day', () {
      expect(
        previousScheduledDate(
          date: DateTime(2026, 3, 31),
          frequency: PlanningFrequency.monthly,
          paymentDay: 31,
        ),
        DateTime(2026, 2, 28),
      );
    });
  });
}
