import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../accounts/presentation/account_dialog.dart';
import '../../planning/planning_providers.dart';
import '../transactions_repository.dart';

final _money = NumberFormat.currency(
  locale: 'ru_KZ',
  symbol: '₸',
  decimalDigits: 0,
);
final _dateFormatter = DateFormat('dd.MM.yyyy');
final _monthDate = DateFormat('d MMMM y', 'ru');

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _search = TextEditingController();
  String _type = 'ALL';
  int? _accountId;
  int? _categoryId;
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(transactionEntriesProvider);
    final accounts = ref.watch(transactionAccountsProvider);
    final categories = ref.watch(transactionCategoriesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Операции'),
        actions: [
          IconButton(
            tooltip: 'Фильтр по датам',
            onPressed: _selectDateRange,
            icon: Icon(
              _dateRange == null
                  ? Icons.date_range_outlined
                  : Icons.event_available,
            ),
          ),
          if (_dateRange != null)
            IconButton(
              tooltip: 'Сбросить период',
              onPressed: () => setState(() => _dateRange = null),
              icon: const Icon(Icons.close),
            ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Поиск по описанию, счету, категории',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Очистить поиск',
                        onPressed: () {
                          _search.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(
                  label: 'Все',
                  selected: _type == 'ALL',
                  onSelected: () => setState(() => _type = 'ALL'),
                ),
                _TypeChip(
                  label: 'Расходы',
                  selected: _type == 'EXPENSE',
                  onSelected: () => setState(() => _type = 'EXPENSE'),
                ),
                _TypeChip(
                  label: 'Доходы',
                  selected: _type == 'INCOME',
                  onSelected: () => setState(() => _type = 'INCOME'),
                ),
                _TypeChip(
                  label: 'Переводы',
                  selected: _type == 'TRANSFER',
                  onSelected: () => setState(() => _type = 'TRANSFER'),
                ),
                accounts.when(
                  data: (items) => _FilterDropdown<int?>(
                    label: 'Все счета',
                    value: _accountId,
                    items: [
                      for (final account in items) (account.id, account.name),
                    ],
                    onChanged: (value) => setState(() => _accountId = value),
                  ),
                  error: (error, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
                categories.when(
                  data: (items) => _FilterDropdown<int?>(
                    label: 'Все категории',
                    value: _categoryId,
                    items: [
                      for (final category in items.where(
                        (item) => !item.isArchived,
                      ))
                        (category.id, category.name),
                    ],
                    onChanged: (value) => setState(() => _categoryId = value),
                  ),
                  error: (error, _) => const SizedBox.shrink(),
                  loading: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          if (_dateRange != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_dateFormatter.format(_dateRange!.start)} — ${_dateFormatter.format(_dateRange!.end)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          Expanded(
            child: entries.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorMessage(
                message: 'Не удалось загрузить операции: $error',
                onRetry: () => ref.invalidate(transactionEntriesProvider),
              ),
              data: (allEntries) {
                final filtered = _filterEntries(allEntries);
                if (filtered.isEmpty) {
                  return _EmptyTransactions(
                    hasFilters: _hasFilters,
                    onClear: _clearFilters,
                    onCreate: _createTransaction,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(transactionEntriesProvider);
                    await ref.read(transactionEntriesProvider.future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _TransactionSummary(entries: filtered);
                      }
                      final entry = filtered[index - 1];
                      final previous = index > 1 ? filtered[index - 2] : null;
                      final showDate =
                          previous == null ||
                          !_sameDate(
                            entry.transaction.transactionDate,
                            previous.transaction.transactionDate,
                          );
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDate)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
                              child: Text(
                                _monthDate.format(
                                  entry.transaction.transactionDate,
                                ),
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                          _TransactionTile(
                            entry: entry,
                            onEdit: () => _editTransaction(entry),
                            onDelete: () => _deleteTransaction(entry),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasFilters =>
      _type != 'ALL' ||
      _accountId != null ||
      _categoryId != null ||
      _dateRange != null ||
      _search.text.trim().isNotEmpty;

  List<TransactionEntry> _filterEntries(List<TransactionEntry> entries) {
    final query = _search.text.trim().toLowerCase();
    return [
      for (final entry in entries)
        if (_type == 'ALL' || entry.transaction.type == _type)
          if (_accountId == null ||
              entry.transaction.accountId == _accountId ||
              (entry.transaction.transferGroupId != null &&
                  entry.transferPeerAccountId == _accountId))
            if (_categoryId == null ||
                entry.transaction.categoryId == _categoryId)
              if (_dateRange == null ||
                  (!_calendarDate(entry.transaction.transactionDate)
                          .isBefore(_calendarDate(_dateRange!.start)) &&
                      !_calendarDate(entry.transaction.transactionDate)
                          .isAfter(_calendarDate(_dateRange!.end))))
                if (query.isEmpty ||
                    entry.transaction.description.toLowerCase().contains(
                      query,
                    ) ||
                    entry.accountName.toLowerCase().contains(query) ||
                    (entry.transferPeerAccountName?.toLowerCase() ?? '')
                        .contains(query) ||
                    (entry.categoryName?.toLowerCase() ?? '').contains(query))
                  entry,
    ];
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _type = 'ALL';
      _accountId = null;
      _categoryId = null;
      _dateRange = null;
    });
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10),
      initialDateRange:
          _dateRange ??
          DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month, now.day),
          ),
      helpText: 'Выберите период операций',
      cancelText: 'Отмена',
      confirmText: 'Применить',
    );
    if (range != null) setState(() => _dateRange = range);
  }

  Future<List<Account>?> _ensureAccounts() async {
    var accounts = await ref.read(transactionsRepositoryProvider).getAccounts();
    if (!mounted) return null;
    var activeAccounts = accounts.where((account) => account.isActive).toList();
    if (activeAccounts.isEmpty) {
      final create = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Нет активного счета'),
          content: const Text(
            'Для регистрации операции нужен активный счет. Создайте новый счет или активируйте существующий в настройках.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Создать счет'),
            ),
          ],
        ),
      );
      if (create != true || !mounted) return null;
      await showCreateAccountDialog(context, ref);
      if (!mounted) return null;
      accounts = await ref.read(transactionsRepositoryProvider).getAccounts();
      activeAccounts = accounts.where((account) => account.isActive).toList();
    }
    return activeAccounts.isEmpty ? null : activeAccounts;
  }

  Future<void> _createTransaction() async {
    try {
      final accounts = await _ensureAccounts();
      if (!mounted || accounts == null || accounts.isEmpty) return;
      final categories = await ref
          .read(transactionsRepositoryProvider)
          .getCategories();
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => _TransactionForm(
          accounts: accounts,
          categories: categories,
          onSave: (form) => _saveForm(form),
        ),
      );
      if (saved == true) _refreshData();
    } catch (error) {
      if (mounted) _showMessage('Не удалось открыть форму операции: $error');
    }
  }

  Future<void> _editTransaction(TransactionEntry entry) async {
    try {
      final accounts = await _ensureAccounts();
      if (!mounted || accounts == null || accounts.isEmpty) return;
      final categories = await ref
          .read(transactionsRepositoryProvider)
          .getCategories();
      if (!mounted) return;
      final saved = await showDialog<bool>(
        context: context,
        builder: (context) => _TransactionForm(
          accounts: accounts,
          categories: categories,
          entry: entry,
          onSave: _saveForm,
        ),
      );
      if (saved == true) _refreshData();
    } catch (error) {
      if (mounted) _showMessage('Не удалось открыть операцию: $error');
    }
  }

  Future<void> _saveForm(TransactionFormData form) async {
    final repository = ref.read(transactionsRepositoryProvider);
    final entry = form.entry;
    if (entry == null) {
      if (form.type == 'TRANSFER') {
        await repository.addTransfer(
          sourceAccountId: form.accountId,
          targetAccountId: form.targetAccountId!,
          amount: form.amount,
          date: form.date,
          description: form.description,
        );
      } else {
        await repository.addTransaction(
          type: form.type,
          accountId: form.accountId,
          amount: form.amount,
          date: form.date,
          categoryId: form.categoryId,
          description: form.description,
          isExcludedFromStatistics: form.isExcludedFromStatistics,
        );
      }
      return;
    }
    if (entry.transaction.type == 'TRANSFER') {
      await repository.updateTransfer(
        transactionId: entry.transaction.id,
        sourceAccountId: form.accountId,
        targetAccountId: form.targetAccountId!,
        amount: form.amount,
        date: form.date,
        description: form.description,
      );
    } else {
      await repository.updateTransaction(
        id: entry.transaction.id,
        type: form.type,
        accountId: form.accountId,
        amount: form.amount,
        date: form.date,
        categoryId: form.categoryId,
        description: form.description,
        isExcludedFromStatistics: form.isExcludedFromStatistics,
      );
    }
  }

  Future<void> _deleteTransaction(TransactionEntry entry) async {
    final isTransfer = entry.transaction.type == 'TRANSFER';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTransfer ? 'Удалить перевод?' : 'Удалить операцию?'),
        content: Text(
          isTransfer
              ? 'Будут удалены обе записи перевода и восстановлены остатки на счетах.'
              : 'Остаток на счете и связанное обязательство будут пересчитаны.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(transactionsRepositoryProvider)
          .deleteTransaction(entry.transaction.id);
      _refreshData();
    } catch (error) {
      if (mounted) _showMessage('Не удалось удалить операцию: $error');
    }
  }

  void _refreshData() {
    ref.invalidate(transactionEntriesProvider);
    ref.invalidate(financeSnapshotProvider);
    ref.invalidate(dashboardDataProvider);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  DateTime _calendarDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}

class _TransactionSummary extends StatelessWidget {
  const _TransactionSummary({required this.entries});
  final List<TransactionEntry> entries;

  @override
  Widget build(BuildContext context) {
    final income = entries
        .where((entry) => entry.transaction.type == 'INCOME')
        .fold<int>(0, (total, entry) => total + entry.transaction.amount);
    final expense = entries
        .where((entry) => entry.transaction.type == 'EXPENSE')
        .fold<int>(0, (total, entry) => total + entry.transaction.amount);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(child: _SummaryValue('Доходы', income, true)),
            const SizedBox(width: 8),
            Expanded(child: _SummaryValue('Расходы', expense, false)),
            const SizedBox(width: 8),
            Expanded(child: _SummaryValue('Операций', entries.length, null)),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue(this.label, this.amount, this.income);
  final String label;
  final int amount;
  final bool? income;

  @override
  Widget build(BuildContext context) {
    final color = income == null
        ? Theme.of(context).colorScheme.onSurface
        : income!
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            income == null ? '$amount' : _money.format(amount),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });
  final TransactionEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final transaction = entry.transaction;
    final income = transaction.type == 'INCOME';
    final transfer = transaction.type == 'TRANSFER';
    final color = transfer
        ? Theme.of(context).colorScheme.tertiary
        : income
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;
    final title = transfer && entry.transferPeerAccountName != null
        ? entry.isTransferSource
              ? '${entry.accountName} → ${entry.transferPeerAccountName}'
              : '${entry.transferPeerAccountName} → ${entry.accountName}'
        : entry.title;
    final sign = income
        ? '+'
        : transfer
        ? ''
        : '−';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(
            transfer
                ? Icons.swap_horiz
                : income
                ? Icons.south_west
                : Icons.north_east,
          ),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          [
            if (entry.categoryName != null) entry.categoryName!,
            if (!transfer) entry.accountName,
            if (transaction.isExcludedFromStatistics) 'Не в статистике',
            if (transaction.linkedPaymentOccurrenceId != null) 'Платеж',
          ].join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign${_money.format(transaction.amount)}',
              style: TextStyle(fontWeight: FontWeight.w600, color: color),
            ),
            PopupMenuButton<String>(
              tooltip: 'Действия',
              onSelected: (action) {
                if (action == 'edit') onEdit();
                if (action == 'delete') onDelete();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Изменить')),
                PopupMenuItem(value: 'delete', child: Text('Удалить')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({
    required this.accounts,
    required this.categories,
    required this.onSave,
    this.entry,
  });

  final List<Account> accounts;
  final List<Category> categories;
  final Future<void> Function(TransactionFormData) onSave;
  final TransactionEntry? entry;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  late final TextEditingController _amount;
  late final TextEditingController _description;
  late String _type;
  late int _accountId;
  late int? _targetAccountId;
  late int? _categoryId;
  late DateTime _date;
  late bool _excluded;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    final transaction = entry?.transaction;
    _type = transaction?.type ?? 'EXPENSE';
    _accountId = entry?.isTransferSource == false
        ? entry?.transferPeerAccountId ?? widget.accounts.first.id
        : transaction?.accountId ?? widget.accounts.first.id;
    _targetAccountId = entry?.isTransferSource == false
        ? transaction?.accountId
        : entry?.transferPeerAccountId;
    if (_targetAccountId == _accountId) {
      _targetAccountId = widget.accounts
          .where((item) => item.id != _accountId)
          .firstOrNull
          ?.id;
    }
    _categoryId = transaction?.categoryId;
    _date = transaction?.transactionDate ?? DateTime.now();
    _excluded = transaction?.isExcludedFromStatistics ?? false;
    _amount = TextEditingController(
      text: transaction == null ? '' : '${transaction.amount}',
    );
    _description = TextEditingController(text: transaction?.description ?? '');
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  List<Category> get _availableCategories {
    final expectedType = _type == 'INCOME' ? 'INCOME' : 'EXPENSE';
    return widget.categories
        .where((item) => !item.isArchived && item.type == expectedType)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final editingTransfer = widget.entry?.transaction.type == 'TRANSFER';
    final isTransfer = _type == 'TRANSFER';
    final accounts = widget.accounts;
    return AlertDialog(
      title: Text(
        widget.entry == null
            ? 'Новая операция'
            : editingTransfer
            ? 'Изменить перевод'
            : 'Изменить операцию',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.entry == null)
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'EXPENSE',
                    label: Text('Расход'),
                    icon: Icon(Icons.north_east),
                  ),
                  ButtonSegment(
                    value: 'INCOME',
                    label: Text('Доход'),
                    icon: Icon(Icons.south_west),
                  ),
                  ButtonSegment(
                    value: 'TRANSFER',
                    label: Text('Перевод'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => setState(() {
                  _type = selection.first;
                  _categoryId = null;
                  if (_type == 'TRANSFER' && _targetAccountId == null) {
                    _targetAccountId = accounts
                        .where((item) => item.id != _accountId)
                        .firstOrNull
                        ?.id;
                  }
                }),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Сумма, ₸'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _accountId,
              decoration: InputDecoration(
                labelText: isTransfer ? 'Со счета' : 'Счет',
              ),
              items: [
                for (final account in accounts)
                  DropdownMenuItem(
                    value: account.id,
                    child: Text('${account.name} · ${account.currency}'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _accountId = value;
                  if (_targetAccountId == value) {
                    _targetAccountId = accounts
                        .where((item) => item.id != value)
                        .firstOrNull
                        ?.id;
                  }
                });
              },
            ),
            if (isTransfer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: _targetAccountId,
                decoration: const InputDecoration(labelText: 'На счет'),
                items: [
                  for (final account in accounts.where(
                    (item) => item.id != _accountId,
                  ))
                    DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} · ${account.currency}'),
                    ),
                ],
                onChanged: (value) => setState(() => _targetAccountId = value),
              ),
            ],
            if (!isTransfer) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Категория'),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Без категории'),
                  ),
                  for (final category in _availableCategories)
                    DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Описание'),
            ),
            TextButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Дата: ${_dateFormatter.format(_date)}'),
            ),
            if (!isTransfer)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Не учитывать в статистике'),
                value: _excluded,
                onChanged: (value) => setState(() => _excluded = value),
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
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _submit() async {
    final amount = int.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Введите сумму больше нуля');
      return;
    }
    if (_type == 'TRANSFER' && _targetAccountId == null) {
      setState(() => _error = 'Выберите счет-получатель');
      return;
    }
    final account = widget.accounts.firstWhere((item) => item.id == _accountId);
    if (_type == 'TRANSFER') {
      final target = widget.accounts.firstWhere(
        (item) => item.id == _targetAccountId,
      );
      if (target.currency != account.currency) {
        setState(() => _error = 'Для перевода выберите счета одной валюты');
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        TransactionFormData(
          entry: widget.entry,
          type: _type,
          accountId: _accountId,
          targetAccountId: _targetAccountId,
          categoryId: _categoryId,
          amount: amount,
          description: _description.text.trim(),
          date: _date,
          isExcludedFromStatistics: _excluded,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Не удалось сохранить: $error';
        });
      }
    }
  }
}

class TransactionFormData {
  const TransactionFormData({
    required this.entry,
    required this.type,
    required this.accountId,
    required this.targetAccountId,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.date,
    required this.isExcludedFromStatistics,
  });

  final TransactionEntry? entry;
  final String type;
  final int accountId;
  final int? targetAccountId;
  final int? categoryId;
  final int amount;
  final String description;
  final DateTime date;
  final bool isExcludedFromStatistics;
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    ),
  );
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T? value;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: PopupMenuButton<T?>(
      tooltip: label,
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        PopupMenuItem<T?>(value: null, child: Text(label)),
        for (final item in items)
          PopupMenuItem<T?>(value: item.$1, child: Text(item.$2)),
      ],
      child: InputChip(
        label: Text(
          value == null
              ? label
              : items.where((item) => item.$1 == value).firstOrNull?.$2 ??
                    label,
        ),
        selected: value != null,
        onPressed: null,
        avatar: const Icon(Icons.filter_list, size: 18),
      ),
    ),
  );
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({
    required this.hasFilters,
    required this.onClear,
    required this.onCreate,
  });
  final bool hasFilters;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
            size: 52,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            hasFilters ? 'Ничего не найдено' : 'Операций пока нет',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Измените параметры поиска или фильтры.'
                : 'Добавьте первую операцию, чтобы начать учет.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            OutlinedButton(
              onPressed: onClear,
              child: const Text('Сбросить фильтры'),
            )
          else
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Добавить операцию'),
            ),
        ],
      ),
    ),
  );
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Повторить')),
        ],
      ),
    ),
  );
}
