import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../analytics_repository.dart';
import '../domain/analytics_models.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  AnalyticsPeriod _period = AnalyticsPeriod.currentMonth;
  DateTimeRange? _customRange;
  String _currency = 'KZT';

  @override
  Widget build(BuildContext context) {
    final range = _period == AnalyticsPeriod.custom && _customRange != null
        ? analyticsRangeFor(
            _period,
            customStart: _customRange!.start,
            customEnd: _customRange!.end,
          )
        : analyticsRangeFor(_period);
    final query = AnalyticsQuery(
      period: _period,
      range: range,
      currency: _currency,
    );
    final report = ref.watch(analyticsReportProvider(query));
    final currencies = ref.watch(analyticsCurrenciesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Аналитика')),
      body: report.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _loadError(error),
        data: (data) => currencies.when(
          loading: () => _reportContent(data, query, ['KZT']),
          error: (error, _) => _loadError(error),
          data: (items) =>
              _reportContent(data, query, {'KZT', ...items}.toList()..sort()),
        ),
      ),
    );
  }

  Widget _loadError(Object error) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text('Не удалось загрузить аналитику: $error'),
    ),
  );

  Widget _reportContent(
    AnalyticsReport report,
    AnalyticsQuery query,
    List<String> currencies,
  ) {
    final selectedCurrency = currencies.contains(_currency)
        ? _currency
        : currencies.first;
    if (selectedCurrency != _currency) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currency = selectedCurrency);
      });
    }
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(analyticsReportProvider(query));
        await ref.read(analyticsReportProvider(query).future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _filters(currencies),
          const SizedBox(height: 8),
          _ReportSections(report: report),
        ],
      ),
    );
  }

  Widget _filters(List<String> currencies) => Wrap(
    spacing: 12,
    runSpacing: 8,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      SizedBox(
        width: 250,
        child: DropdownButtonFormField<AnalyticsPeriod>(
          initialValue: _period,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Период',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            for (final period in AnalyticsPeriod.values)
              DropdownMenuItem(value: period, child: Text(period.label)),
          ],
          onChanged: (period) async {
            if (period == null) return;
            if (period == AnalyticsPeriod.custom) {
              final now = DateTime.now();
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(now.year + 1),
                initialDateRange:
                    _customRange ??
                    DateTimeRange(
                      start: DateTime(now.year, now.month, 1),
                      end: now,
                    ),
              );
              if (range == null || !mounted) return;
              setState(() {
                _customRange = range;
                _period = period;
              });
            } else {
              setState(() => _period = period);
            }
          },
        ),
      ),
      SizedBox(
        width: 130,
        child: DropdownButtonFormField<String>(
          initialValue: currencies.contains(_currency)
              ? _currency
              : currencies.first,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Валюта',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            for (final currency in currencies)
              DropdownMenuItem(value: currency, child: Text(currency)),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _currency = value);
          },
        ),
      ),
      if (_period == AnalyticsPeriod.custom && _customRange != null)
        Text(
          '${_date(_customRange!.start)} — ${_date(_customRange!.end)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
    ],
  );

  String _date(DateTime date) => DateFormat('dd.MM.yyyy').format(date);
}

class _ReportSections extends StatelessWidget {
  const _ReportSections({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 12),
      _SummaryGrid(report: report),
      const SizedBox(height: 16),
      _ComparisonCard(report: report),
      const SizedBox(height: 16),
      _TrendCard(report: report),
      const SizedBox(height: 16),
      _CategoryCard(report: report),
      const SizedBox(height: 16),
      _RegularExpensesCard(report: report),
      const SizedBox(height: 16),
      _MerchantsCard(report: report),
      const SizedBox(height: 16),
      _InsightsCard(report: report),
    ],
  );
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final totals = report.totals;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _MetricCard(
              width: width,
              title: 'Расходы',
              amount: _money(totals.expenses, report.currency),
              icon: Icons.south_west,
              color: Theme.of(context).colorScheme.error,
            ),
            _MetricCard(
              width: width,
              title: 'Доходы',
              amount: _money(totals.income, report.currency),
              icon: Icons.north_east,
              color: Colors.green,
            ),
            _MetricCard(
              width: width,
              title: 'Чистый поток',
              amount: _money(totals.net, report.currency),
              icon: Icons.account_balance_wallet_outlined,
              color: totals.net < 0
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.primary,
            ),
            _MetricCard(
              width: width,
              title: 'В среднем в день',
              amount: _money(totals.averageExpensePerDay, report.currency),
              icon: Icons.today_outlined,
              color: Theme.of(context).colorScheme.secondary,
            ),
            _MetricCard(
              width: width,
              title: 'В среднем в месяц',
              amount: _money(totals.averageExpensePerMonth, report.currency),
              icon: Icons.calendar_month_outlined,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.width,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final double width;
  final String title;
  final String amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final change = report.totals.expenses - report.previousTotals.expenses;
    final percent = report.previousTotals.expenses == 0
        ? null
        : (change * 100 / report.previousTotals.expenses).round();
    final color = change > 0
        ? Theme.of(context).colorScheme.error
        : Colors.green;
    return _SectionCard(
      title: 'Сравнение периодов',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_rangeLabel(report.range)}  ·  ${_money(report.totals.expenses, report.currency)}',
          ),
          const SizedBox(height: 4),
          Text(
            '${_rangeLabel(report.comparisonRange)}  ·  ${_money(report.previousTotals.expenses, report.currency)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${change > 0 ? '+' : ''}${_money(change, report.currency)}'
            '${percent == null ? '' : ' (${percent > 0 ? '+' : ''}$percent%)'}',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Динамика расходов',
    subtitle: 'Текущий период и предыдущий сопоставимый период',
    child:
        report.trend.isEmpty ||
            (report.totals.expenses == 0 && report.previousTotals.expenses == 0)
        ? const _NoData()
        : Column(
            children: [
              SizedBox(
                height: 210,
                child: BarChart(
                  BarChartData(
                    barGroups: [
                      for (var index = 0; index < report.trend.length; index++)
                        BarChartGroupData(
                          x: index,
                          barsSpace: 4,
                          barRods: [
                            BarChartRodData(
                              toY: report.trend[index].amount.toDouble(),
                              color: Theme.of(context).colorScheme.primary,
                              width: 9,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            BarChartRodData(
                              toY: report.trend[index].previousAmount
                                  .toDouble(),
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 9,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                    ],
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= report.trend.length) {
                              return const SizedBox.shrink();
                            }
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                report.trend[index].label,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(enabled: false),
                  ),
                ),
              ),
              const _ChartLegend(),
            ],
          ),
  );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final categories = report.categories
        .where((category) => category.amount > 0)
        .take(5)
        .toList();
    final total = report.totals.expenses;
    final otherAmount =
        total -
        categories.fold<int>(0, (sum, category) => sum + category.amount);
    return _SectionCard(
      title: 'Расходы по категориям',
      child: Column(
        children: [
          if (categories.isEmpty)
            const _NoData()
          else ...[
            SizedBox(
              height: 210,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 38,
                  sections: [
                    for (final category in categories)
                      PieChartSectionData(
                        value: category.amount.toDouble(),
                        color: Color(category.color),
                        radius: 72,
                        title: total == 0
                            ? ''
                            : '${category.amount * 100 ~/ total}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (otherAmount > 0)
                      PieChartSectionData(
                        value: otherAmount.toDouble(),
                        color: Colors.blueGrey,
                        radius: 72,
                        title: '${otherAmount * 100 ~/ total}%',
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            for (final category in categories)
              _CategoryLine(category: category, report: report),
            if (otherAmount > 0)
              _LegendValue(
                color: Colors.blueGrey,
                label: 'Другие категории',
                value: _money(otherAmount, report.currency),
              ),
          ],
          if (report.categories.any((category) => category.previousAmount > 0))
            _CategoryComparisonChart(report: report),
        ],
      ),
    );
  }
}

class _CategoryComparisonChart extends StatelessWidget {
  const _CategoryComparisonChart({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final categories = report.categories
        .where((category) => category.amount > 0 || category.previousAmount > 0)
        .take(5)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Сравнение категорий',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 210,
          child: BarChart(
            BarChartData(
              barGroups: [
                for (var index = 0; index < categories.length; index++)
                  BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      BarChartRodData(
                        toY: categories[index].amount.toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                        width: 9,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      BarChartRodData(
                        toY: categories[index].previousAmount.toDouble(),
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 9,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= categories.length) {
                        return const SizedBox.shrink();
                      }
                      final name = categories[index].name;
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          name.length > 9 ? '${name.substring(0, 8)}…' : name,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              barTouchData: BarTouchData(enabled: false),
            ),
          ),
        ),
        const _ChartLegend(),
      ],
    );
  }
}

class _CategoryLine extends StatelessWidget {
  const _CategoryLine({required this.category, required this.report});

  final CategoryExpense category;
  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: Color(category.color)),
        const SizedBox(width: 8),
        Expanded(child: Text(category.name)),
        Text(_money(category.amount, report.currency)),
        if (category.previousAmount > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${category.difference > 0 ? '+' : ''}${_money(category.difference, report.currency)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: category.difference > 0
                  ? Theme.of(context).colorScheme.error
                  : Colors.green,
            ),
          ),
        ],
      ],
    ),
  );
}

class _RegularExpensesCard extends StatelessWidget {
  const _RegularExpensesCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    final regular = report.totals.regularExpenses;
    final irregular = report.totals.irregularExpenses;
    final total = regular + irregular;
    return _SectionCard(
      title: 'Регулярные и разовые расходы',
      child: total == 0
          ? const _NoData()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    children: [
                      if (regular > 0)
                        Expanded(
                          flex: regular,
                          child: Container(
                            height: 12,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      if (irregular > 0)
                        Expanded(
                          flex: irregular,
                          child: Container(
                            height: 12,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _LegendValue(
                  color: Theme.of(context).colorScheme.primary,
                  label: 'Регулярные',
                  value: _money(regular, report.currency),
                ),
                _LegendValue(
                  color: Theme.of(context).colorScheme.tertiary,
                  label: 'Разовые',
                  value: _money(irregular, report.currency),
                ),
              ],
            ),
    );
  }
}

class _MerchantsCard extends StatelessWidget {
  const _MerchantsCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Крупнейшие получатели',
    child: report.topMerchants.isEmpty
        ? const _NoData()
        : Column(
            children: [
              for (final merchant in report.topMerchants)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(merchant.name),
                  subtitle: Text('${merchant.count} операций'),
                  trailing: Text(_money(merchant.amount, report.currency)),
                ),
            ],
          ),
  );
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.report});

  final AnalyticsReport report;

  @override
  Widget build(BuildContext context) => _SectionCard(
    title: 'Возможности для экономии',
    subtitle:
        'Период: ${_rangeLabel(report.range)}. Факты и оценки по правилам, без ИИ.',
    child: report.insights.isEmpty
        ? const _NoData(
            text: 'За выбранный период не найдено подтверждённых закономерностей.',
          )
        : Column(
            children: [
              for (final insight in report.insights)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lightbulb_outline),
                  title: Text(insight.title),
                  subtitle: Text(insight.evidence),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 105),
                    child: Text(
                      'до ${_money(insight.potentialSaving, report.currency)}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    ),
  );
}

class _NoData extends StatelessWidget {
  const _NoData({this.text = 'Нет данных за выбранный период.'});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(child: Text(text, textAlign: TextAlign.center)),
  );
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _ChartLegendItem(
        color: Theme.of(context).colorScheme.primary,
        label: 'Период',
      ),
      const SizedBox(width: 16),
      _ChartLegendItem(
        color: Theme.of(context).colorScheme.tertiary,
        label: 'Предыдущий',
      ),
    ],
  );
}

class _ChartLegendItem extends StatelessWidget {
  const _ChartLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 8),
      Text(label),
    ],
  );
}

class _LegendValue extends StatelessWidget {
  const _LegendValue({required this.color, required this.label, this.value});

  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
        if (value != null) Text(value!),
      ],
    ),
  );
}

String _money(int amount, String currency) {
  final symbol = currency == 'KZT' ? '₸' : currency;
  return NumberFormat.currency(
    locale: 'ru_KZ',
    symbol: symbol,
    decimalDigits: 0,
  ).format(amount);
}

String _rangeLabel(AnalyticsRange range) {
  final date = DateFormat('dd.MM.yyyy');
  return '${date.format(range.start)}–${date.format(range.end)}';
}
