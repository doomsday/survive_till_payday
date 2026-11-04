import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../domain/financial_planning_service.dart';
import '../planning_providers.dart';

final _money = NumberFormat.currency(
  locale: 'ru_KZ',
  symbol: '₸',
  decimalDigits: 0,
);
final _date = DateFormat('d MMM', 'ru');
final _longDate = DateFormat('d MMMM y', 'ru');

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  late DateTime _selectedDate = calendarDate(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final dashboardDay = ref.watch(dashboardDayAtDateProvider(_selectedDate));
    if (dashboardDay.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (dashboardDay.hasError) {
      final error = dashboardDay.error;
      return Scaffold(
        appBar: AppBar(title: const Text('Обзор')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить финансовые данные: $error'),
          ),
        ),
      );
    }
    final day = dashboardDay.value!;
    final snapshot = day.finance;
    final data = day.dashboard;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Обзор'),
            const SizedBox(width: 4),
            Expanded(
              child: Tooltip(
                message: 'Выбрать дату',
                child: TextButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    DateFormat('EEEE, d MMMM', 'ru').format(_selectedDate),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.onSurfaceVariant,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDayAtDateProvider(_selectedDate));
          await ref.read(dashboardDayAtDateProvider(_selectedDate).future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            _SafeToSpendCard(finance: snapshot),
            const SizedBox(height: 12),
            _FinanceSummary(finance: snapshot),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'За ${DateFormat('LLLL', 'ru').format(_selectedDate)}',
            ),
            _MonthlySummary(data: data),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Ближайшие платежи',
              action: TextButton(
                onPressed: () => context.go('/payments'),
                child: const Text('Все'),
              ),
            ),
            _UpcomingPayments(
              payments: data.upcomingPayments,
              asOfDate: _selectedDate,
            ),
            const SizedBox(height: 20),
            _SectionTitle(title: 'Расходы по категориям'),
            _CategoryBreakdown(categories: data.categorySpending),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Последние операции',
              action: TextButton(
                onPressed: () => context.go('/transactions'),
                child: const Text('Все'),
              ),
            ),
            _RecentTransactions(transactions: data.recentTransactions),
            if (data.remainingTransactionsThisMonth > 0)
              Padding(
                padding: const EdgeInsets.only(left: 12, top: 4),
                child: Text(
                  'и еще ${data.remainingTransactionsThisMonth} в этом месяце',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _quickExpense(context, ref, day),
              icon: const Icon(Icons.add),
              label: const Text('Добавить расход'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final today = calendarDate(DateTime.now());
    late final DateTime firstAvailableDate;
    try {
      firstAvailableDate = calendarDate(
        await ref
            .read(financialPlanningServiceProvider)
            .getHistoryFirstAvailableDate(),
      );
    } catch (error) {
      if (mounted) {
        _showMessage(context, 'Не удалось открыть календарь: $error');
      }
      return;
    }
    if (!mounted) return;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstAvailableDate.isAfter(today) ? today : firstAvailableDate,
      lastDate: today,
      locale: const Locale('ru'),
    );
    if (selectedDate != null && mounted) {
      setState(() => _selectedDate = calendarDate(selectedDate));
    }
  }

  Future<void> _quickExpense(
    BuildContext context,
    WidgetRef ref,
    DashboardDay day,
  ) async {
    final service = ref.read(financialPlanningServiceProvider);
    try {
      final accounts = day.accounts;
      if (!context.mounted) return;
      if (accounts.isEmpty) {
        _showMessage(context, 'Сначала добавьте активный счет');
        return;
      }
      final categories = day.expenseCategories;
      final amount = TextEditingController();
      final description = TextEditingController();
      var accountId = accounts.first.id;
      int? categoryId;
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Новый расход'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amount,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Сумма, ₸'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: description,
                    decoration: const InputDecoration(labelText: 'Описание'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: accountId,
                    decoration: const InputDecoration(labelText: 'Счет'),
                    items: [
                      for (final account in accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => accountId = value);
                      }
                    },
                  ),
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int?>(
                      initialValue: categoryId,
                      decoration: const InputDecoration(labelText: 'Категория'),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Без категории'),
                        ),
                        for (final category in categories)
                          DropdownMenuItem<int?>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                      ],
                      onChanged: (value) => setState(() => categoryId = value),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Отмена'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Добавить'),
              ),
            ],
          ),
        ),
      );
      if (result == true) {
        final parsedAmount = int.tryParse(amount.text.trim());
        if (parsedAmount == null || parsedAmount <= 0) {
          if (context.mounted) {
            _showMessage(context, 'Введите сумму больше нуля');
          }
        } else {
          await service.addManualExpense(
            accountId: accountId,
            amount: parsedAmount,
            description: description.text,
            categoryId: categoryId,
            date: _selectedDate,
          );
          ref.invalidate(dashboardDayAtDateProvider(_selectedDate));
        }
      }
      amount.dispose();
      description.dispose();
    } catch (error) {
      if (context.mounted) {
        _showMessage(context, 'Не удалось добавить расход: $error');
      }
    }
  }
}

class _SafeToSpendCard extends StatelessWidget {
  const _SafeToSpendCard({required this.finance});
  final FinanceSnapshot finance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final deficit = finance.safeToSpend != null && finance.safeToSpend! < 0;
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
      color: deficit ? scheme.onErrorContainer : scheme.onPrimaryContainer,
      height: 1.4,
    );
    final showSavings =
        finance.accumulatedBalance != null &&
        finance.accumulatedBalance! > 0 &&
        finance.availableToday != null;
    final messageParts = [
      finance.safeToSpend == null
          ? 'Укажите дату зарплаты.'
          : 'Можно потратить до зарплаты '
                '${_money.format(finance.safeToSpend)}, '
                'а сегодня '
                '${finance.dailyLimitBalance == null ? '—' : _money.format(finance.dailyLimitBalance)}.',
      if (finance.dailySafeToSpend != null)
        'Норма трат за день на сегодня — '
            '${_money.format(finance.dailySafeToSpend)}.',
      if (finance.todayExpenses != null)
        'По факту вы потратили ${_money.format(finance.todayExpenses)}.',
      if (showSavings)
        'В прошедшие дни после ЗП вы тратили меньше, поэтому '
            'с учётом экономии сегодня можете потратить '
            '${_money.format(finance.availableToday)}, '
            'осталось '
            '${finance.dayBalance == null ? '—' : _money.format(finance.dayBalance)}.',
    ];
    return Card(
      color: deficit ? scheme.errorContainer : scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Text(messageParts.join(' '), style: textStyle),
      ),
    );
  }
}

class _FinanceSummary extends StatelessWidget {
  const _FinanceSummary({required this.finance});
  final FinanceSnapshot finance;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          _MetricRow(
            label: 'Остаток доступных счетов',
            value: _money.format(finance.currentBalance),
          ),
          _MetricRow(
            label: 'Ожидаемые доходы',
            value: _money.format(finance.expectedIncome),
          ),
          _MetricRow(
            label: 'Неоплаченные платежи',
            value: _money.format(finance.reservedPayments),
          ),
          _MetricRow(label: 'Резерв', value: _money.format(finance.reserve)),
          const Divider(height: 20),
          _MetricRow(
            label: 'Следующая зарплата',
            value: finance.nextPayday == null
                ? 'Не задана'
                : _longDate.format(finance.nextPayday!),
          ),
          _MetricRow(
            label: 'Дней до зарплаты',
            value: finance.daysUntilPayday?.toString() ?? '—',
          ),
        ],
      ),
    ),
  );
}

class _MonthlySummary extends StatelessWidget {
  const _MonthlySummary({required this.data});
  final DashboardData data;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _MonthlyMetric(
          label: 'Доходы',
          amount: data.monthIncome,
          icon: Icons.south_west,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _MonthlyMetric(
          label: 'Расходы',
          amount: data.monthExpense,
          icon: Icons.north_east,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    ],
  );
}

class _MonthlyMetric extends StatelessWidget {
  const _MonthlyMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });
  final String label;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _money.format(amount),
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    ),
  );
}

class _UpcomingPayments extends StatelessWidget {
  const _UpcomingPayments({required this.payments, required this.asOfDate});
  final List<DashboardPayment> payments;
  final DateTime asOfDate;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return const _EmptyCard(message: 'Ближайших платежей нет');
    }
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < payments.length; index++) ...[
            if (index > 0) const Divider(height: 1, indent: 64),
            _PaymentRow(payment: payments[index], asOfDate: asOfDate),
          ],
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.asOfDate});
  final DashboardPayment payment;
  final DateTime asOfDate;

  @override
  Widget build(BuildContext context) {
    final item = payment.occurrence;
    final dueDate = calendarDate(item.dueDate);
    final daysLeft = dueDate.difference(asOfDate).inDays;
    final overdue = item.status == 'OVERDUE' || daysLeft < 0;
    final dueSoon = !overdue && daysLeft <= 3;
    final color = overdue || dueSoon
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final remaining = item.expectedAmount - item.paidAmount;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        foregroundColor: color,
        child: Icon(overdue ? Icons.warning_amber_rounded : Icons.event),
      ),
      title: Text(payment.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        overdue
            ? 'Просрочен · ${_date.format(dueDate)}'
            : dueSoon
            ? 'Скоро · ${_date.format(dueDate)}'
            : '${_date.format(dueDate)} · ${_paymentStatus(item.status)}',
        style: TextStyle(color: overdue || dueSoon ? color : null),
      ),
      trailing: Text(
        _money.format(remaining),
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: overdue || dueSoon ? color : null,
        ),
      ),
    );
  }
}

String _paymentStatus(String status) => switch (status) {
  'PARTIALLY_PAID' => 'Оплачен частично',
  'OVERDUE' => 'Просрочен',
  _ => 'Ожидает',
};

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.categories});
  final List<CategorySpending> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const _EmptyCard(message: 'Расходов в этом месяце пока нет');
    }
    final maxAmount = categories.first.amount;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            for (var index = 0; index < categories.length; index++) ...[
              if (index > 0) const SizedBox(height: 16),
              _CategoryRow(category: categories[index], maxAmount: maxAmount),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.maxAmount});
  final CategorySpending category;
  final int maxAmount;

  @override
  Widget build(BuildContext context) {
    final color = Color(category.color);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(_money.format(category.amount)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: maxAmount == 0 ? 0 : category.amount / maxAmount,
          color: color,
          backgroundColor: color.withValues(alpha: 0.12),
          minHeight: 6,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.transactions});
  final List<DashboardTransaction> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const _EmptyCard(message: 'Операций пока нет');
    }
    return Card(
      child: Column(
        children: [
          for (var index = 0; index < transactions.length; index++) ...[
            if (index > 0) const Divider(height: 1, indent: 64),
            _TransactionRow(item: transactions[index]),
          ],
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.item});
  final DashboardTransaction item;

  @override
  Widget build(BuildContext context) {
    final transaction = item.transaction;
    final isIncome = transaction.type == 'INCOME';
    final isTransfer = transaction.type == 'TRANSFER';
    final color = isTransfer
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : isIncome
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final amount =
        '${isIncome
            ? '+'
            : isTransfer
            ? ''
            : '−'}${_money.format(transaction.amount)}';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: item.categoryColor == null
            ? color.withValues(alpha: 0.12)
            : Color(item.categoryColor!).withValues(alpha: 0.12),
        foregroundColor: item.categoryColor == null
            ? color
            : Color(item.categoryColor!),
        child: Icon(
          isTransfer
              ? Icons.swap_horiz
              : isIncome
              ? Icons.south_west
              : Icons.north_east,
        ),
      ),
      title: Text(
        transaction.description.isEmpty
            ? item.categoryName ?? (isTransfer ? 'Перевод' : 'Операция')
            : transaction.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${item.accountName} · ${_date.format(transaction.transactionDate)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        amount,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?action,
      ],
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label)),
        const SizedBox(width: 12),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
