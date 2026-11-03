import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/features/analytics/domain/analytics_models.dart';
import 'package:survive_till_payday/features/analytics/domain/analytics_service.dart';

void main() {
  const service = AnalyticsService();
  final november = DateTime(2026, 11, 3);

  test('builds month and comparison ranges using calendar dates', () {
    final current = analyticsRangeFor(
      AnalyticsPeriod.currentMonth,
      now: november,
    );
    final previous = comparisonRangeFor(AnalyticsPeriod.currentMonth, current);
    final lastYear = analyticsRangeFor(
      AnalyticsPeriod.last12Months,
      now: november,
    );

    expect(current.start, DateTime(2026, 11, 1));
    expect(current.endExclusive, DateTime(2026, 11, 4));
    expect(current.days, 3);
    expect(previous.start, DateTime(2026, 10, 1));
    expect(previous.endExclusive, DateTime(2026, 10, 4));
    expect(previous.days, current.days);
    expect(lastYear.start, DateTime(2025, 12, 1));
  });

  test('custom date range includes both selected days', () {
    final range = analyticsRangeFor(
      AnalyticsPeriod.custom,
      customStart: DateTime(2026, 10, 30, 18),
      customEnd: DateTime(2026, 11, 2, 8),
    );

    expect(range.start, DateTime(2026, 10, 30));
    expect(range.endExclusive, DateTime(2026, 11, 3));
    expect(range.days, 4);
    expect(range.contains(DateTime(2026, 11, 2, 22)), isTrue);
    expect(range.contains(DateTime(2026, 11, 3)), isFalse);
  });

  test(
    'aggregates currency, statistics exclusions and transfer exclusions',
    () {
      final query = _query(AnalyticsPeriod.currentMonth, november);
      final report = service.buildReport(
        query: query,
        transactions: [
          _transaction(
            1,
            'EXPENSE',
            50000,
            DateTime(2026, 11, 1),
            category: 1,
            categoryName: 'Жильё',
          ),
          _transaction(
            2,
            'EXPENSE',
            5000,
            DateTime(2026, 11, 2),
            category: 2,
            categoryName: 'Еда',
            recurring: true,
          ),
          _transaction(3, 'INCOME', 100000, DateTime(2026, 11, 2)),
          _transaction(4, 'TRANSFER', 7000, DateTime(2026, 11, 2)),
          _transaction(
            5,
            'EXPENSE',
            9000,
            DateTime(2026, 11, 2),
            excluded: true,
          ),
          _transaction(
            6,
            'EXPENSE',
            120000,
            DateTime(2026, 11, 2),
            currency: 'USD',
          ),
          _transaction(
            7,
            'EXPENSE',
            10000,
            DateTime(2026, 10, 2),
            category: 2,
            categoryName: 'Еда',
          ),
        ],
      );

      expect(report.totals.expenses, 55000);
      expect(report.totals.income, 100000);
      expect(report.totals.net, 45000);
      expect(report.totals.regularExpenses, 5000);
      expect(report.totals.irregularExpenses, 50000);
      expect(report.totals.averageExpensePerDay, 18333);
      expect(report.previousTotals.expenses, 10000);
      expect(report.categories.first.name, 'Жильё');
      expect(report.categories.first.difference, 50000);
      expect(report.trend, hasLength(1));
    },
  );

  test('produces factual category-growth and repeated-spending insights', () {
    final transactions = <AnalyticsTransaction>[
      _transaction(
        1,
        'EXPENSE',
        50000,
        DateTime(2026, 11, 1),
        category: 1,
        categoryName: 'Жильё',
      ),
      _transaction(
        2,
        'EXPENSE',
        5000,
        DateTime(2026, 11, 1),
        category: 2,
        categoryName: 'Кафе',
        description: 'Кофейня',
      ),
      _transaction(
        3,
        'EXPENSE',
        5000,
        DateTime(2026, 11, 2),
        category: 2,
        categoryName: 'Кафе',
        description: 'Кофейня',
      ),
      _transaction(
        4,
        'EXPENSE',
        5000,
        DateTime(2026, 11, 3),
        category: 2,
        categoryName: 'Кафе',
        description: 'Кофейня',
      ),
      _transaction(
        5,
        'EXPENSE',
        5000,
        DateTime(2026, 10, 2),
        category: 1,
        categoryName: 'Жильё',
      ),
      _transaction(
        6,
        'EXPENSE',
        1000,
        DateTime(2026, 10, 2),
        category: 2,
        categoryName: 'Кафе',
      ),
    ];
    final report = service.buildReport(
      query: _query(AnalyticsPeriod.currentMonth, november),
      transactions: transactions,
    );

    expect(
      report.insights.map((insight) => insight.rule),
      containsAll(['category_growth', 'repeated_spending', 'category_share']),
    );
    final growth = report.insights.firstWhere(
      (insight) => insight.rule == 'category_growth',
    );
    expect(growth.title, 'Рост расходов: Жильё');
    expect(growth.potentialSaving, 45000);
    final repeated = report.insights.firstWhere(
      (insight) => insight.rule == 'repeated_spending',
    );
    expect(repeated.title, 'Повторяющиеся покупки: Кофейня');
    expect(repeated.potentialSaving, 5000);
  });

  test('does not make recommendations without sufficient expense evidence', () {
    final report = service.buildReport(
      query: _query(AnalyticsPeriod.currentMonth, november),
      transactions: [
        _transaction(1, 'EXPENSE', 5000, DateTime(2026, 11, 1)),
        _transaction(2, 'INCOME', 10000, DateTime(2026, 11, 2)),
      ],
    );

    expect(report.insights, isEmpty);
    expect(report.topMerchants, hasLength(1));
    expect(report.topMerchants.single.name, 'Без описания');
  });

  test('detects frequent low-cost purchases as an estimated opportunity', () {
    final transactions = [
      for (var index = 0; index < 8; index++)
        _transaction(
          index,
          'EXPENSE',
          2000,
          DateTime(2026, 11, 1 + index % 3),
          category: 5,
          categoryName: 'Кофе',
          description: 'Кофейня',
        ),
    ];
    final report = service.buildReport(
      query: _query(AnalyticsPeriod.currentMonth, november),
      transactions: transactions,
    );

    final insight = report.insights.firstWhere(
      (item) => item.rule == 'frequent_small_purchases',
    );
    expect(insight.evidence, contains('8 операций'));
    expect(insight.evidence, contains('16000 KZT'));
    expect(insight.potentialSaving, 1600);
  });

  test('surfaces recurring expenses categorized as subscriptions', () {
    final report = service.buildReport(
      query: _query(AnalyticsPeriod.currentMonth, november),
      transactions: [
        _transaction(
          1,
          'EXPENSE',
          3000,
          DateTime(2026, 11, 1),
          category: 4,
          categoryName: 'Подписки',
          description: 'Музыка',
          recurring: true,
        ),
      ],
    );

    final insight = report.insights.firstWhere(
      (item) => item.rule == 'subscriptions',
    );
    expect(insight.title, 'Регулярные подписки');
    expect(insight.potentialSaving, 3000);
    expect(insight.evidence, contains('одна средняя оплата'));
  });

  test('flags an unusually large transaction against period expenses', () {
    final transactions = [
      for (var index = 0; index < 5; index++)
        _transaction(
          index,
          'EXPENSE',
          1000,
          DateTime(2026, 11, 1 + index % 3),
          description: 'Покупка $index',
        ),
      _transaction(
        6,
        'EXPENSE',
        20000,
        DateTime(2026, 11, 3),
        description: 'Крупная покупка',
      ),
    ];
    final report = service.buildReport(
      query: _query(AnalyticsPeriod.currentMonth, november),
      transactions: transactions,
    );

    final insight = report.insights.firstWhere(
      (item) => item.rule == 'large_expense',
    );
    expect(insight.title, 'Крупная отдельная покупка');
    expect(insight.evidence, contains('Крупная покупка'));
    expect(insight.potentialSaving, 2000);
  });
}

AnalyticsQuery _query(AnalyticsPeriod period, DateTime now) {
  final range = analyticsRangeFor(period, now: now);
  return AnalyticsQuery(period: period, range: range, currency: 'KZT');
}

AnalyticsTransaction _transaction(
  int id,
  String type,
  int amount,
  DateTime date, {
  String currency = 'KZT',
  int? category,
  String? categoryName,
  String description = '',
  bool recurring = false,
  bool excluded = false,
}) => AnalyticsTransaction(
  id: id,
  type: type,
  amount: amount,
  currency: currency,
  date: date,
  description: description,
  isExcludedFromStatistics: excluded,
  isRecurring: recurring,
  categoryId: category,
  categoryName: categoryName,
);
