import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../accounts/presentation/account_dialog.dart';
import '../../accounts/accounts_repository.dart';
import '../../../core/database/app_database.dart';
import '../../categories/categories_repository.dart';
import '../domain/financial_planning_service.dart';
import '../planning_providers.dart';

final _money = NumberFormat.currency(
  locale: 'ru',
  symbol: '₸',
  decimalDigits: 0,
);
final _shortDate = DateFormat('dd.MM.yyyy');

class PaymentsPage extends ConsumerWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occurrences = ref.watch(paymentOccurrencesProvider);
    final schedules = ref.watch(recurringPaymentsProvider);
    final incomes = ref.watch(incomeSchedulesProvider);
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Планирование'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Добавить',
            icon: const Icon(Icons.add),
            onSelected: (value) =>
                _createSchedule(context, ref, value == 'income'),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'payment', child: Text('Регулярный платеж')),
              PopupMenuItem(value: 'income', child: Text('Ожидаемый доход')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _SectionHeader(
            title: 'Регулярные платежи',
            action: IconButton(
              tooltip: 'Добавить платеж',
              onPressed: () => _createSchedule(context, ref, false),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ),
          schedules.when(
            loading: _loading,
            error: (error, _) => _error(error),
            data: (items) => items.isEmpty
                ? const _EmptyMessage('Регулярных платежей пока нет')
                : Column(
                    children: [
                      for (final item in items) ...[
                        _RecurringPaymentTile(
                          payment: item,
                          categoryName: categories
                              .where(
                                (category) => category.id == item.categoryId,
                              )
                              .firstOrNull
                              ?.name,
                          isAutoPay: item.isAutoPay,
                          nextOccurrence: occurrences.value
                              ?.where(
                                (occurrence) =>
                                    occurrence.recurringPaymentId == item.id &&
                                    occurrence.status != 'PAID' &&
                                    occurrence.status != 'CANCELLED',
                              )
                              .firstOrNull,
                          onEditSchedule: () =>
                              _createSchedule(context, ref, false, item),
                          onPay: (occurrence) =>
                              _payOccurrence(context, ref, occurrence),
                          onCancelOccurrence: (occurrence) =>
                              _cancelOccurrence(context, ref, occurrence),
                        ),
                      ],
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Ожидаемые доходы',
            action: IconButton(
              tooltip: 'Добавить доход',
              onPressed: () => _createSchedule(context, ref, true),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ),
          incomes.when(
            loading: _loading,
            error: (error, _) => _error(error),
            data: (items) => items.isEmpty
                ? const _EmptyMessage('Ожидаемых доходов пока нет')
                : Column(
                    children: [
                      for (final item in items)
                        Card(
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              '${_money.format(item.expectedAmount)} · ${_shortDate.format(_nextIncomeDate(item))}${item.isActive ? '' : ' · Завершен'}',
                            ),
                            leading: const CircleAvatar(
                              child: Icon(Icons.savings_outlined),
                            ),
                            trailing: item.isActive
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Изменить доход',
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () => _createSchedule(
                                          context,
                                          ref,
                                          true,
                                          null,
                                          item,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Отметить полученным',
                                        icon: const Icon(
                                          Icons.check_circle_outline,
                                        ),
                                        onPressed: () =>
                                            _receiveIncome(context, ref, item),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _RecurringPaymentTile extends StatelessWidget {
  const _RecurringPaymentTile({
    required this.payment,
    required this.categoryName,
    required this.isAutoPay,
    required this.nextOccurrence,
    required this.onEditSchedule,
    required this.onPay,
    required this.onCancelOccurrence,
  });

  final RecurringPayment payment;
  final String? categoryName;
  final bool isAutoPay;
  final PaymentOccurrence? nextOccurrence;
  final VoidCallback onEditSchedule;
  final ValueChanged<PaymentOccurrence> onPay;
  final ValueChanged<PaymentOccurrence> onCancelOccurrence;

  @override
  Widget build(BuildContext context) {
    final occurrence = nextOccurrence;
    final dueDate = occurrence?.dueDate;
    final status = occurrence?.status;
    return Card(
      child: ListTile(
        title: Text(payment.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_money.format(payment.amount)} · ${frequencyLabel(parseFrequency(payment.frequency))}',
              ),
              if (categoryName != null) ...[
                const SizedBox(height: 2),
                Text(
                  categoryName!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (isAutoPay) ...[
                const SizedBox(height: 2),
                Text(
                  'Автооплата',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
              const SizedBox(height: 2),
              Text(
                dueDate == null
                    ? 'Следующий платеж: не запланирован'
                    : 'Следующий платеж: ${_shortDate.format(dueDate)}${status == 'OVERDUE' ? ' · просрочен' : ''}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        leading: const CircleAvatar(child: Icon(Icons.event_repeat_outlined)),
        trailing: PopupMenuButton<String>(
          tooltip: 'Действия с платежом',
          onSelected: (action) {
            if (action == 'edit') onEditSchedule();
            if (occurrence == null) return;
            if (action == 'pay') onPay(occurrence);
            if (action == 'cancel') onCancelOccurrence(occurrence);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('Изменить платёж')),
            if (occurrence != null) ...[
              const PopupMenuItem(value: 'pay', child: Text('Оплатить')),
              const PopupMenuItem(
                value: 'cancel',
                child: Text('Отменить платеж'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

DateTime _nextIncomeDate(IncomeSchedule schedule) {
  return calendarDate(schedule.expectedDate);
}

Future<void> _payOccurrence(
  BuildContext context,
  WidgetRef ref,
  PaymentOccurrence occurrence,
) async {
  final service = ref.read(financialPlanningServiceProvider);
  try {
    final account = await _getAccountForAction(context, ref);
    if (!context.mounted) return;
    if (account == null || !context.mounted) return;
    final amount = await _amountDialog(
      context,
      title: 'Сумма оплаты',
      initial: '${occurrence.expectedAmount - occurrence.paidAmount}',
    );
    if (amount == null || !context.mounted) return;
    await service.payOccurrence(
      occurrence: occurrence,
      accountId: account.id,
      amount: amount,
      paidDate: DateTime.now(),
    );
    ref.invalidate(financeSnapshotProvider);
    ref.invalidate(paymentOccurrencesProvider);
  } catch (error) {
    if (context.mounted) _showMessage(context, 'Не удалось оплатить: $error');
  }
}

Future<void> _receiveIncome(
  BuildContext context,
  WidgetRef ref,
  IncomeSchedule schedule,
) async {
  final service = ref.read(financialPlanningServiceProvider);
  try {
    final account = await _getAccountForAction(context, ref);
    if (!context.mounted) return;
    if (account == null || !context.mounted) return;
    await service.receiveIncome(
      schedule: schedule,
      accountId: account.id,
      receivedDate: DateTime.now(),
    );
    ref.invalidate(financeSnapshotProvider);
    ref.invalidate(incomeSchedulesProvider);
  } catch (error) {
    if (context.mounted) {
      _showMessage(context, 'Не удалось записать доход: $error');
    }
  }
}

Future<Account?> _getAccountForAction(
  BuildContext context,
  WidgetRef ref,
) async {
  final service = ref.read(financialPlanningServiceProvider);
  var accounts = await service.getActiveAccounts();
  if (!context.mounted) return null;
  if (accounts.isEmpty) {
    final createAccount = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Нужен активный счет'),
        content: const Text(
          'Создайте счет, чтобы записать поступление или оплату обязательства.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.add),
            label: const Text('Создать счет'),
          ),
        ],
      ),
    );
    if (createAccount != true || !context.mounted) return null;
    await showCreateAccountDialog(context, ref);
    if (!context.mounted) return null;
    accounts = await service.getActiveAccounts();
  }
  if (accounts.isEmpty || !context.mounted) return null;
  return _chooseAccount(context, accounts);
}

Future<void> _cancelOccurrence(
  BuildContext context,
  WidgetRef ref,
  PaymentOccurrence occurrence,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Отменить обязательство?'),
      content: const Text('Оно больше не будет учитываться в Safe to Spend.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Назад'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Отменить'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;
  try {
    await ref
        .read(financialPlanningServiceProvider)
        .cancelOccurrence(occurrence.id);
    ref.invalidate(financeSnapshotProvider);
    ref.invalidate(paymentOccurrencesProvider);
  } catch (error) {
    if (context.mounted) _showMessage(context, 'Не удалось отменить: $error');
  }
}

Future<void> _createSchedule(
  BuildContext context,
  WidgetRef ref,
  bool income, [
  RecurringPayment? recurring,
  IncomeSchedule? incomeSchedule,
]) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => income
        ? _IncomeForm(initial: incomeSchedule)
        : _RecurringForm(initial: recurring),
  );
  if (result == true) {
    ref.invalidate(financeSnapshotProvider);
    ref.invalidate(paymentOccurrencesProvider);
    ref.invalidate(recurringPaymentsProvider);
    ref.invalidate(incomeSchedulesProvider);
  }
}

Future<Account?> _chooseAccount(BuildContext context, List<Account> accounts) {
  return showDialog<Account>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Выберите счет'),
      children: [
        for (final account in accounts)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, account),
            child: Text(account.name),
          ),
      ],
    ),
  );
}

Future<int?> _amountDialog(
  BuildContext context, {
  required String title,
  required String initial,
}) async {
  final controller = TextEditingController(text: initial);
  final result = await showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Сумма, ₸'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, int.tryParse(controller.text.trim())),
          child: const Text('Подтвердить'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Widget _loading() => const Padding(
  padding: EdgeInsets.all(24),
  child: Center(child: CircularProgressIndicator()),
);

Widget _error(Object error) => Padding(
  padding: const EdgeInsets.all(16),
  child: Text('Не удалось загрузить данные: $error'),
);

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
      ),
      ?action,
    ],
  );
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(message, textAlign: TextAlign.center),
  );
}

class _RecurringForm extends ConsumerStatefulWidget {
  const _RecurringForm({this.initial});
  final RecurringPayment? initial;

  @override
  ConsumerState<_RecurringForm> createState() => _RecurringFormState();
}

class _RecurringFormState extends ConsumerState<_RecurringForm> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late DateTime _startDate;
  late PlanningFrequency _frequency;
  int? _categoryId;
  int? _accountId;
  bool _isAutoPay = false;
  bool _isActive = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _name = TextEditingController(text: item?.name ?? '');
    _amount = TextEditingController(text: item == null ? '' : '${item.amount}');
    _startDate = item?.startDate ?? DateTime.now();
    _frequency = parseFrequency(item?.frequency ?? 'MONTHLY');
    _categoryId = item?.categoryId;
    _accountId = item?.accountId;
    _isAutoPay = item?.isAutoPay ?? false;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(allAccountsProvider);
    return AlertDialog(
      title: Text(widget.initial == null ? 'Новый платёж' : 'Изменить платёж'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.initial != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Изменения применятся к будущим неоплаченным платежам. История оплат не изменится.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма, ₸'),
            ),
            const SizedBox(height: 12),
            categories.when(
              data: (items) {
                final expenseCategories = items
                    .where(
                      (category) =>
                          category.type == 'EXPENSE' &&
                          (!category.isArchived || category.id == _categoryId),
                    )
                    .toList();
                return DropdownButtonFormField<int?>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'Категория'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Без категории'),
                    ),
                    for (final category in expenseCategories)
                      DropdownMenuItem<int?>(
                        value: category.id,
                        child: Text(
                          '${category.name}${category.isArchived ? ' · В архиве' : ''}',
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text(
                'Не удалось загрузить категории: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Автооплата'),
              subtitle: const Text(
                'При наступлении даты платеж будет автоматически записан как оплаченный.',
              ),
              value: _isAutoPay,
              onChanged: (value) {
                setState(() {
                  _isAutoPay = value;
                  if (value && _accountId == null) {
                    _accountId = accounts.value
                        ?.where((account) => account.isActive)
                        .firstOrNull
                        ?.id;
                  }
                });
              },
            ),
            if (_isAutoPay) ...[
              const SizedBox(height: 8),
              accounts.when(
                data: (items) {
                  final selectableAccounts = items
                      .where(
                        (account) =>
                            account.isActive || account.id == _accountId,
                      )
                      .toList();
                  return DropdownButtonFormField<int?>(
                    initialValue: _accountId,
                    decoration: const InputDecoration(labelText: 'Счет карты'),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Выберите счет'),
                      ),
                      for (final account in selectableAccounts)
                        DropdownMenuItem<int?>(
                          value: account.id,
                          child: Text(
                            '${account.name}${account.isActive ? '' : ' · Неактивен'}',
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(() => _accountId = value),
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(
                  'Не удалось загрузить счета: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Автооплата создает локальную запись расхода и уменьшает остаток счета. Списание через банк не выполняется.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<PlanningFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Периодичность'),
              items: [
                for (final frequency in PlanningFrequency.values.where(
                  (value) => value != PlanningFrequency.once,
                ))
                  DropdownMenuItem(
                    value: frequency,
                    child: Text(frequencyLabel(frequency)),
                  ),
              ],
              onChanged: (value) =>
                  setState(() => _frequency = value ?? _frequency),
            ),
            TextButton.icon(
              onPressed: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (selected != null) setState(() => _startDate = selected);
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Начало: ${_shortDate.format(_startDate)}'),
            ),
            if (widget.initial != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Активно'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(onPressed: _save, child: const Text('Сохранить')),
      ],
    );
  }

  Future<void> _save() async {
    final amount = int.tryParse(_amount.text.trim());
    if (_name.text.trim().isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Укажите название и сумму больше нуля');
      return;
    }
    if (_isAutoPay && _accountId == null) {
      setState(() => _error = 'Для автооплаты выберите счет');
      return;
    }
    final service = ProviderScope.containerOf(context)
        .read(financialPlanningServiceProvider);
    try {
      final frequency = switch (_frequency) {
        PlanningFrequency.weekly => 'WEEKLY',
        PlanningFrequency.monthly => 'MONTHLY',
        PlanningFrequency.quarterly => 'QUARTERLY',
        PlanningFrequency.yearly => 'YEARLY',
        PlanningFrequency.once => 'MONTHLY',
      };
      final existing = widget.initial;
      if (existing == null) {
        await service.createRecurringPayment(
          name: _name.text,
          amount: amount,
          frequency: frequency,
          startDate: _startDate,
          categoryId: _categoryId,
          accountId: _accountId,
          isAutoPay: _isAutoPay,
        );
      } else {
        await service.updateRecurringPayment(
          id: existing.id,
          name: _name.text,
          amount: amount,
          frequency: frequency,
          startDate: _startDate,
          paymentDay: existing.paymentDay,
          categoryId: _categoryId,
          accountId: _accountId,
          isAutoPay: _isAutoPay,
          isActive: _isActive,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      setState(() => _error = 'Не удалось сохранить: $error');
    }
  }
}

class _IncomeForm extends StatefulWidget {
  const _IncomeForm({this.initial});
  final IncomeSchedule? initial;

  @override
  State<_IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<_IncomeForm> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late DateTime _date;
  late PlanningFrequency _frequency;
  bool _isActive = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _name = TextEditingController(text: item?.name ?? '');
    _amount = TextEditingController(
      text: item == null ? '' : '${item.expectedAmount}',
    );
    _date = item?.expectedDate ?? DateTime.now();
    _frequency = parseFrequency(item?.frequency ?? 'MONTHLY');
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ожидаемый доход'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Название'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Сумма, ₸'),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<PlanningFrequency>(
          initialValue: _frequency,
          decoration: const InputDecoration(labelText: 'Периодичность'),
          items: [
            for (final frequency in PlanningFrequency.values)
              DropdownMenuItem(
                value: frequency,
                child: Text(frequencyLabel(frequency)),
              ),
          ],
          onChanged: (value) =>
              setState(() => _frequency = value ?? _frequency),
        ),
        TextButton.icon(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selected != null) setState(() => _date = selected);
          },
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text('Дата: ${_shortDate.format(_date)}'),
        ),
        if (widget.initial != null)
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Активно'),
            value: _isActive,
            onChanged: (value) => setState(() => _isActive = value),
          ),
        if (_error != null)
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Отмена'),
      ),
      FilledButton(onPressed: _save, child: const Text('Сохранить')),
    ],
  );

  Future<void> _save() async {
    final amount = int.tryParse(_amount.text.trim());
    if (_name.text.trim().isEmpty || amount == null || amount <= 0) {
      setState(() => _error = 'Укажите название и сумму больше нуля');
      return;
    }
    final service = ProviderScope.containerOf(context)
        .read(financialPlanningServiceProvider);
    try {
      final frequency = switch (_frequency) {
        PlanningFrequency.once => 'ONCE',
        PlanningFrequency.weekly => 'WEEKLY',
        PlanningFrequency.monthly => 'MONTHLY',
        PlanningFrequency.quarterly => 'QUARTERLY',
        PlanningFrequency.yearly => 'YEARLY',
      };
      final existing = widget.initial;
      if (existing == null) {
        await service.createIncomeSchedule(
          name: _name.text,
          amount: amount,
          frequency: frequency,
          expectedDate: _date,
        );
      } else {
        await service.updateIncomeSchedule(
          id: existing.id,
          name: _name.text,
          amount: amount,
          frequency: frequency,
          expectedDate: _date,
          isActive: _isActive,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      setState(() => _error = 'Не удалось сохранить: $error');
    }
  }
}
