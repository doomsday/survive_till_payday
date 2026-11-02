import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../planning_providers.dart';

final _money = NumberFormat.currency(
  locale: 'ru_KZ',
  symbol: '₸',
  decimalDigits: 0,
);
final _date = DateFormat('d MMMM y', 'ru');

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(financeSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Обзор')),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Не удалось загрузить финансовые данные: $error'),
          ),
        ),
        data: (finance) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Payday',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Можно потратить до зарплаты',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      finance.safeToSpend == null
                          ? 'Укажите дату зарплаты'
                          : _money.format(finance.safeToSpend),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                finance.safeToSpend != null &&
                                    finance.safeToSpend! < 0
                                ? Theme.of(context).colorScheme.error
                                : null,
                          ),
                    ),
                    if (finance.safeToSpend != null && finance.safeToSpend! < 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('Дефицит до следующего поступления'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _MetricRow(
                      'Дневной лимит',
                      finance.dailySafeToSpend == null
                          ? '—'
                          : _money.format(finance.dailySafeToSpend),
                    ),
                    _MetricRow(
                      'Остаток на счетах',
                      _money.format(finance.currentBalance),
                    ),
                    _MetricRow(
                      'Ожидаемые доходы',
                      _money.format(finance.expectedIncome),
                    ),
                    _MetricRow(
                      'Обязательные платежи',
                      _money.format(finance.reservedPayments),
                    ),
                    _MetricRow('Резерв', _money.format(finance.reserve)),
                    const Divider(height: 24),
                    _MetricRow(
                      'Следующая зарплата',
                      finance.nextPayday == null
                          ? 'Не задана'
                          : _date.format(finance.nextPayday!),
                    ),
                    _MetricRow(
                      'Дней до зарплаты',
                      finance.daysUntilPayday == null
                          ? '—'
                          : '${finance.daysUntilPayday}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _quickExpense(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Добавить расход'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _quickExpense(BuildContext context, WidgetRef ref) async {
    final service = ref.read(financialPlanningServiceProvider);
    final accounts = await service.getActiveAccounts();
    if (!context.mounted) return;
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сначала добавьте активный счет')),
      );
      return;
    }
    final amount = TextEditingController();
    final description = TextEditingController();
    var accountId = accounts.first.id;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Новый расход'),
          content: Column(
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
                  if (value != null) setState(() => accountId = value);
                },
              ),
            ],
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Введите сумму больше нуля')),
          );
        }
      } else {
        try {
          await service.addManualExpense(
            accountId: accountId,
            amount: parsedAmount,
            description: description.text,
          );
          ref.invalidate(financeSnapshotProvider);
        } catch (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось добавить расход: $error')),
            );
          }
        }
      }
    }
    amount.dispose();
    description.dispose();
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow(this.label, this.value);
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
