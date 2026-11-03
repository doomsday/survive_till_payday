import 'dart:math' as math;

import 'package:flutter/foundation.dart';

enum AnalyticsPeriod {
  currentMonth('Текущий месяц'),
  previousMonth('Предыдущий месяц'),
  last3Months('3 месяца'),
  last6Months('6 месяцев'),
  last12Months('12 месяцев'),
  custom('Произвольный период');

  const AnalyticsPeriod(this.label);

  final String label;
}

@immutable
class AnalyticsRange {
  const AnalyticsRange({required this.start, required this.endExclusive});

  final DateTime start;
  final DateTime endExclusive;

  DateTime get end =>
      DateTime(endExclusive.year, endExclusive.month, endExclusive.day - 1);

  int get days => DateTime.utc(
    endExclusive.year,
    endExclusive.month,
    endExclusive.day,
  ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

  bool contains(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return !normalized.isBefore(start) && normalized.isBefore(endExclusive);
  }
}

AnalyticsRange analyticsRangeFor(
  AnalyticsPeriod period, {
  DateTime? now,
  DateTime? customStart,
  DateTime? customEnd,
}) {
  final today = now ?? DateTime.now();
  final tomorrow = DateTime(today.year, today.month, today.day + 1);
  switch (period) {
    case AnalyticsPeriod.currentMonth:
      return AnalyticsRange(
        start: DateTime(today.year, today.month),
        endExclusive: tomorrow,
      );
    case AnalyticsPeriod.previousMonth:
      return AnalyticsRange(
        start: DateTime(today.year, today.month - 1),
        endExclusive: DateTime(today.year, today.month),
      );
    case AnalyticsPeriod.last3Months:
      return AnalyticsRange(
        start: DateTime(today.year, today.month - 2),
        endExclusive: tomorrow,
      );
    case AnalyticsPeriod.last6Months:
      return AnalyticsRange(
        start: DateTime(today.year, today.month - 5),
        endExclusive: tomorrow,
      );
    case AnalyticsPeriod.last12Months:
      return AnalyticsRange(
        start: DateTime(today.year, today.month - 11),
        endExclusive: tomorrow,
      );
    case AnalyticsPeriod.custom:
      if (customStart == null || customEnd == null) {
        throw ArgumentError('Custom period requires both start and end dates.');
      }
      final start = DateTime(
        customStart.year,
        customStart.month,
        customStart.day,
      );
      final end = DateTime(customEnd.year, customEnd.month, customEnd.day);
      if (end.isBefore(start)) {
        throw ArgumentError('Custom period end must not precede its start.');
      }
      return AnalyticsRange(
        start: start,
        endExclusive: end.add(const Duration(days: 1)),
      );
  }
}

AnalyticsRange comparisonRangeFor(
  AnalyticsPeriod period,
  AnalyticsRange range,
) {
  switch (period) {
    case AnalyticsPeriod.currentMonth:
      final previousStart = DateTime(range.start.year, range.start.month - 1);
      final previousMonthEnd = range.start;
      final previousMonthDays =
          DateTime.utc(
                previousMonthEnd.year,
                previousMonthEnd.month,
                previousMonthEnd.day,
              )
              .difference(
                DateTime.utc(
                  previousStart.year,
                  previousStart.month,
                  previousStart.day,
                ),
              )
              .inDays;
      return AnalyticsRange(
        start: previousStart,
        endExclusive: previousStart.add(
          Duration(days: math.min(range.days, previousMonthDays)),
        ),
      );
    case AnalyticsPeriod.previousMonth:
      return AnalyticsRange(
        start: DateTime(range.start.year, range.start.month - 1),
        endExclusive: range.start,
      );
    case AnalyticsPeriod.last3Months:
      return AnalyticsRange(
        start: DateTime(range.start.year, range.start.month - 3),
        endExclusive: range.start,
      );
    case AnalyticsPeriod.last6Months:
      return AnalyticsRange(
        start: DateTime(range.start.year, range.start.month - 6),
        endExclusive: range.start,
      );
    case AnalyticsPeriod.last12Months:
      return AnalyticsRange(
        start: DateTime(range.start.year, range.start.month - 12),
        endExclusive: range.start,
      );
    case AnalyticsPeriod.custom:
      final duration = Duration(days: range.days);
      return AnalyticsRange(
        start: range.start.subtract(duration),
        endExclusive: range.start,
      );
  }
}

@immutable
class AnalyticsQuery {
  const AnalyticsQuery({
    required this.period,
    required this.range,
    required this.currency,
  });

  final AnalyticsPeriod period;
  final AnalyticsRange range;
  final String currency;

  AnalyticsRange get comparisonRange => comparisonRangeFor(period, range);

  @override
  bool operator ==(Object other) =>
      other is AnalyticsQuery &&
      other.period == period &&
      other.range.start == range.start &&
      other.range.endExclusive == range.endExclusive &&
      other.currency == currency;

  @override
  int get hashCode =>
      Object.hash(period, range.start, range.endExclusive, currency);
}

@immutable
class AnalyticsTransaction {
  const AnalyticsTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.description,
    required this.isExcludedFromStatistics,
    required this.isRecurring,
    this.isNoWithdrawalTransfer = false,
    this.categoryId,
    this.categoryName,
    this.categoryColor,
  });

  final int id;
  final String type;
  final int amount;
  final String currency;
  final DateTime date;
  final String description;
  final bool isExcludedFromStatistics;
  final bool isRecurring;
  final bool isNoWithdrawalTransfer;
  final int? categoryId;
  final String? categoryName;
  final int? categoryColor;
}

@immutable
class AnalyticsTotals {
  const AnalyticsTotals({
    required this.income,
    required this.expenses,
    required this.regularExpenses,
    required this.irregularExpenses,
    required this.transactionCount,
    required this.expenseCount,
    required this.days,
  });

  final int income;
  final int expenses;
  final int regularExpenses;
  final int irregularExpenses;
  final int transactionCount;
  final int expenseCount;
  final int days;

  int get net => income - expenses;
  int get averageExpensePerDay => days == 0 ? 0 : expenses ~/ days;
  int get averageExpensePerMonth => days == 0 ? 0 : expenses * 30 ~/ days;
}

@immutable
class CategoryExpense {
  const CategoryExpense({
    required this.id,
    required this.name,
    required this.color,
    required this.amount,
    required this.previousAmount,
  });

  final int? id;
  final String name;
  final int color;
  final int amount;
  final int previousAmount;

  int get difference => amount - previousAmount;
}

@immutable
class MonthlyExpense {
  const MonthlyExpense({
    required this.label,
    required this.amount,
    required this.previousAmount,
  });

  final String label;
  final int amount;
  final int previousAmount;
}

@immutable
class MerchantExpense {
  const MerchantExpense({
    required this.name,
    required this.amount,
    required this.count,
  });

  final String name;
  final int amount;
  final int count;
}

@immutable
class ExpenseInsight {
  const ExpenseInsight({
    required this.title,
    required this.evidence,
    required this.potentialSaving,
    required this.rule,
  });

  final String title;
  final String evidence;
  final int potentialSaving;
  final String rule;
}

@immutable
class AnalyticsReport {
  const AnalyticsReport({
    required this.currency,
    required this.range,
    required this.comparisonRange,
    required this.totals,
    required this.previousTotals,
    required this.categories,
    required this.trend,
    required this.topMerchants,
    required this.insights,
  });

  final String currency;
  final AnalyticsRange range;
  final AnalyticsRange comparisonRange;
  final AnalyticsTotals totals;
  final AnalyticsTotals previousTotals;
  final List<CategoryExpense> categories;
  final List<MonthlyExpense> trend;
  final List<MerchantExpense> topMerchants;
  final List<ExpenseInsight> insights;
}
