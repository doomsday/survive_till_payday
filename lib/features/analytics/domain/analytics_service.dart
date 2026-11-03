import 'dart:math' as math;

import 'analytics_models.dart';

const _defaultCategoryColor = 0xFF78909C;

class AnalyticsService {
  const AnalyticsService();

  AnalyticsReport buildReport({
    required List<AnalyticsTransaction> transactions,
    required AnalyticsQuery query,
  }) {
    final periodTransactions = transactions
        .where(
          (transaction) =>
              transaction.currency == query.currency &&
              !transaction.isExcludedFromStatistics &&
              (transaction.type != 'TRANSFER' ||
                  transaction.isNoWithdrawalTransfer),
        )
        .toList();
    final current = periodTransactions
        .where((transaction) => query.range.contains(transaction.date))
        .toList();
    final previous = periodTransactions
        .where(
          (transaction) => query.comparisonRange.contains(transaction.date),
        )
        .toList();

    final totals = _totals(current, query.range);
    final previousTotals = _totals(previous, query.comparisonRange);
    final categories = _categories(current, previous);
    final insights = _insights(
      current: current,
      categories: categories,
      comparisonRange: query.comparisonRange,
      currency: query.currency,
    );
    return AnalyticsReport(
      currency: query.currency,
      range: query.range,
      comparisonRange: query.comparisonRange,
      totals: totals,
      previousTotals: previousTotals,
      categories: categories,
      trend: _trend(query.range, query.comparisonRange, current, previous),
      topMerchants: _topMerchants(current),
      insights: insights,
    );
  }

  AnalyticsTotals _totals(
    List<AnalyticsTransaction> transactions,
    AnalyticsRange range,
  ) {
    var income = 0;
    var expenses = 0;
    var regularExpenses = 0;
    var irregularExpenses = 0;
    var expenseCount = 0;
    for (final transaction in transactions) {
      if (transaction.type == 'INCOME') {
        income += transaction.amount;
      } else if (_isExpense(transaction)) {
        expenses += transaction.amount;
        expenseCount++;
        if (transaction.isRecurring) {
          regularExpenses += transaction.amount;
        } else {
          irregularExpenses += transaction.amount;
        }
      }
    }
    return AnalyticsTotals(
      income: income,
      expenses: expenses,
      regularExpenses: regularExpenses,
      irregularExpenses: irregularExpenses,
      transactionCount: transactions.length,
      expenseCount: expenseCount,
      days: range.days,
    );
  }

  List<CategoryExpense> _categories(
    List<AnalyticsTransaction> current,
    List<AnalyticsTransaction> previous,
  ) {
    final amounts = <int?, int>{};
    final previousAmounts = <int?, int>{};
    final names = <int?, String>{};
    final colors = <int?, int>{};
    for (final transaction in current) {
      if (!_isExpense(transaction)) continue;
      final id = transaction.categoryId;
      amounts.update(
        id,
        (amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      names[id] = transaction.categoryName ?? 'Без категории';
      colors[id] = transaction.categoryColor ?? _defaultCategoryColor;
    }
    for (final transaction in previous) {
      if (!_isExpense(transaction)) continue;
      final id = transaction.categoryId;
      previousAmounts.update(
        id,
        (amount) => amount + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
      names[id] = transaction.categoryName ?? 'Без категории';
      colors[id] = transaction.categoryColor ?? _defaultCategoryColor;
    }
    return [
      for (final id in {...amounts.keys, ...previousAmounts.keys})
        CategoryExpense(
          id: id,
          name: names[id] ?? 'Без категории',
          color: colors[id] ?? _defaultCategoryColor,
          amount: amounts[id] ?? 0,
          previousAmount: previousAmounts[id] ?? 0,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
  }

  List<MonthlyExpense> _trend(
    AnalyticsRange currentRange,
    AnalyticsRange previousRange,
    List<AnalyticsTransaction> current,
    List<AnalyticsTransaction> previous,
  ) {
    final useWeeks = currentRange.days <= 45 || previousRange.days <= 45;
    final count = useWeeks
        ? math.max((currentRange.days + 6) ~/ 7, (previousRange.days + 6) ~/ 7)
        : math.max(_monthCount(currentRange), _monthCount(previousRange));
    return [
      for (var index = 0; index < count; index++)
        MonthlyExpense(
          label: useWeeks ? 'Неделя ${index + 1}' : 'Месяц ${index + 1}',
          amount: _bucketAmount(current, currentRange, index, useWeeks),
          previousAmount: _bucketAmount(
            previous,
            previousRange,
            index,
            useWeeks,
          ),
        ),
    ];
  }

  int _monthCount(AnalyticsRange range) =>
      (range.endExclusive.year - range.start.year) * 12 +
      range.endExclusive.month -
      range.start.month +
      (range.endExclusive.day > 1 ? 1 : 0);

  int _bucketAmount(
    List<AnalyticsTransaction> transactions,
    AnalyticsRange range,
    int index,
    bool useWeeks,
  ) {
    final bucketStart = useWeeks
        ? range.start.add(Duration(days: index * 7))
        : DateTime(range.start.year, range.start.month + index);
    final bucketEnd = useWeeks
        ? bucketStart.add(const Duration(days: 7))
        : DateTime(bucketStart.year, bucketStart.month + 1);
    return transactions
        .where(
          (transaction) =>
              _isExpense(transaction) &&
              !transaction.date.isBefore(bucketStart) &&
              transaction.date.isBefore(bucketEnd) &&
              range.contains(transaction.date),
        )
        .fold(0, (total, transaction) => total + transaction.amount);
  }

  List<MerchantExpense> _topMerchants(List<AnalyticsTransaction> current) {
    final totals = <String, (int, int)>{};
    for (final transaction in current) {
      if (transaction.type != 'EXPENSE') continue;
      final name = transaction.description.trim().isEmpty
          ? transaction.categoryName ?? 'Без описания'
          : transaction.description.trim();
      final existing = totals[name] ?? (0, 0);
      totals[name] = (existing.$1 + transaction.amount, existing.$2 + 1);
    }
    final result = [
      for (final entry in totals.entries)
        MerchantExpense(
          name: entry.key,
          amount: entry.value.$1,
          count: entry.value.$2,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    return result.take(5).toList();
  }

  List<ExpenseInsight> _insights({
    required List<AnalyticsTransaction> current,
    required List<CategoryExpense> categories,
    required AnalyticsRange comparisonRange,
    required String currency,
  }) {
    final insights = <ExpenseInsight>[];
    final increases =
        categories
            .where(
              (category) =>
                  category.amount >= 5000 &&
                  category.previousAmount > 0 &&
                  category.difference >= 5000 &&
                  category.amount > category.previousAmount * 1.25,
            )
            .toList()
          ..sort((a, b) => b.difference.compareTo(a.difference));
    if (increases.isNotEmpty) {
      final category = increases.first;
      final percent = category.previousAmount == 0
          ? 100
          : (category.difference * 100 / category.previousAmount).round();
      insights.add(
        ExpenseInsight(
          rule: 'category_growth',
          title: 'Рост расходов: ${category.name}',
          evidence:
              'За период потрачено ${category.amount} $currency, '
              'на ${category.difference} $currency больше, чем за '
              '${_rangeName(comparisonRange)} (+$percent%).',
          potentialSaving: category.difference,
        ),
      );
    }

    final repeated =
        _topMerchants(current)
            .where(
              (merchant) => merchant.count >= 3 && merchant.amount >= 10000,
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));
    if (repeated.isNotEmpty) {
      final merchant = repeated.first;
      insights.add(
        ExpenseInsight(
          rule: 'repeated_spending',
          title: 'Повторяющиеся покупки: ${merchant.name}',
          evidence:
              '${merchant.count} операций на общую сумму '
              '${merchant.amount} $currency; сокращение на одну среднюю '
              'покупку составило бы около ${merchant.amount ~/ merchant.count} $currency.',
          potentialSaving: merchant.amount ~/ merchant.count,
        ),
      );
    }

    final subscriptions = current.where((transaction) {
      final category = transaction.categoryName?.toLowerCase() ?? '';
      final description = transaction.description.toLowerCase();
      return _isExpense(transaction) &&
          transaction.isRecurring &&
          (category.contains('подпис') ||
              description.contains('подпис') ||
              description.contains('subscription'));
    }).toList();
    if (subscriptions.isNotEmpty) {
      final subscriptionTotal = subscriptions.fold<int>(
        0,
        (sum, transaction) => sum + transaction.amount,
      );
      final averageCharge = subscriptionTotal ~/ subscriptions.length;
      final subscriptionNames = subscriptions
          .map((transaction) => transaction.description.trim())
          .where((name) => name.isNotEmpty)
          .toSet();
      final names = subscriptionNames.isEmpty
          ? ''
          : ' (${subscriptionNames.join(', ')})';
      insights.add(
        ExpenseInsight(
          rule: 'subscriptions',
          title: 'Регулярные подписки',
          evidence:
              '${subscriptions.length} операций$names на '
              '$subscriptionTotal $currency; '
              'одна средняя оплата — около $averageCharge $currency.',
          potentialSaving: averageCharge,
        ),
      );
    }

    final expenses = current
        .where((transaction) => transaction.type == 'EXPENSE')
        .toList();
    final totalExpenses = current
        .where(_isExpense)
        .fold<int>(0, (total, transaction) => total + transaction.amount);
    final smallPurchases = _frequentSmallPurchases(current);
    if (smallPurchases != null) {
      insights.add(
        ExpenseInsight(
          rule: 'frequent_small_purchases',
          title: 'Частые небольшие покупки: ${smallPurchases.name}',
          evidence:
              '${smallPurchases.count} операций до 3 000 $currency, '
              'всего ${smallPurchases.amount} $currency; снижение таких '
              'расходов на 10% дало бы ${smallPurchases.amount ~/ 10} $currency экономии.',
          potentialSaving: smallPurchases.amount ~/ 10,
        ),
      );
    }
    if (totalExpenses > 0 && categories.isNotEmpty) {
      final largest = categories.first;
      final sharePercent = largest.amount * 100 ~/ totalExpenses;
      if (sharePercent >= 30 && largest.amount >= 10000) {
        insights.add(
          ExpenseInsight(
            rule: 'category_share',
            title: 'Крупная статья расходов: ${largest.name}',
            evidence:
                '${largest.amount} $currency из $totalExpenses $currency расходов за период '
                '($sharePercent%); снижение этой статьи на 10% дало бы '
                '${largest.amount ~/ 10} $currency экономии.',
            potentialSaving: largest.amount ~/ 10,
          ),
        );
      }
    }

    final largeExpense = _largeOutlier(expenses);
    if (largeExpense != null) {
      insights.add(
        ExpenseInsight(
          rule: 'large_expense',
          title: 'Крупная отдельная покупка',
          evidence:
              'Операция «${largeExpense.description.trim().isEmpty ? largeExpense.categoryName ?? 'Без описания' : largeExpense.description.trim()}» '
              'на ${largeExpense.amount} $currency заметно выше среднего расхода; '
              'снижение на 10% дало бы ${largeExpense.amount ~/ 10} $currency экономии.',
          potentialSaving: largeExpense.amount ~/ 10,
        ),
      );
    }
    return insights;
  }

  MerchantExpense? _frequentSmallPurchases(
    List<AnalyticsTransaction> transactions,
  ) {
    final groups = <String, (int, int)>{};
    for (final transaction in transactions) {
      if (transaction.type != 'EXPENSE' || transaction.amount > 3000) continue;
      final name = transaction.description.trim().isEmpty
          ? transaction.categoryName ?? 'Без категории'
          : transaction.description.trim();
      final previous = groups[name] ?? (0, 0);
      groups[name] = (previous.$1 + transaction.amount, previous.$2 + 1);
    }
    final candidates = [
      for (final entry in groups.entries)
        if (entry.value.$2 >= 8 && entry.value.$1 >= 10000)
          MerchantExpense(
            name: entry.key,
            amount: entry.value.$1,
            count: entry.value.$2,
          ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));
    return candidates.firstOrNull;
  }

  AnalyticsTransaction? _largeOutlier(List<AnalyticsTransaction> expenses) {
    if (expenses.length < 5) return null;
    final mean =
        expenses.fold<int>(0, (sum, item) => sum + item.amount) /
        expenses.length;
    final variance =
        expenses.fold<double>(
          0,
          (sum, item) => sum + math.pow(item.amount - mean, 2),
        ) /
        expenses.length;
    final threshold = math.max(10000, mean + 2 * math.sqrt(variance));
    final outliers = expenses.where((item) => item.amount > threshold).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return outliers.firstOrNull;
  }

  String _rangeName(AnalyticsRange range) =>
      '${range.start.day}.${range.start.month}.${range.start.year}–'
      '${range.end.day}.${range.end.month}.${range.end.year}';

  bool _isExpense(AnalyticsTransaction transaction) =>
      transaction.type == 'EXPENSE' || transaction.isNoWithdrawalTransfer;
}
