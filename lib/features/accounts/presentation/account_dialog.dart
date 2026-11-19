import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../planning/planning_providers.dart';
import '../accounts_repository.dart';

final _money = NumberFormat.currency(
  locale: 'ru_KZ',
  symbol: '₸',
  decimalDigits: 0,
);

const _accountColors = [
  Color(0xFF607D8B),
  Color(0xFF3F51B5),
  Color(0xFF00897B),
  Color(0xFF2E7D32),
  Color(0xFFF57C00),
  Color(0xFFC62828),
  Color(0xFF8E24AA),
  Color(0xFF6D4C41),
];

Future<void> showCreateAccountDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => const _AccountDialog(),
  );
  ref.invalidate(allAccountsProvider);
  ref.invalidate(financeSnapshotProvider);
}

Future<void> showEditAccountDialog(
  BuildContext context,
  WidgetRef ref,
  Account account,
) async {
  await showDialog<void>(
    context: context,
    builder: (_) => _AccountDialog(account: account),
  );
  ref.invalidate(allAccountsProvider);
  ref.invalidate(financeSnapshotProvider);
}

class _AccountDialog extends ConsumerStatefulWidget {
  const _AccountDialog({this.account});

  final Account? account;

  @override
  ConsumerState<_AccountDialog> createState() => _AccountDialogState();
}

class _AccountDialogState extends ConsumerState<_AccountDialog> {
  final _name = TextEditingController();
  late final TextEditingController _currentBalance;
  late String _type;
  late bool _isNoWithdrawal;
  late bool _isDeposit;
  late int _color;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final account = widget.account;
    _name.text = account?.name ?? '';
    _type = account?.type ?? 'BANK';
    _isNoWithdrawal = account?.isNoWithdrawal ?? false;
    _isDeposit = account?.isDeposit ?? false;
    _color = account?.color ?? _accountColors.first.toARGB32();
    _currentBalance = TextEditingController(
      text: '${account?.currentBalance ?? account?.initialBalance ?? 0}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _currentBalance.dispose();
    super.dispose();
  }

  Future<void> _showAddAmountDialog() async {
    final result = await showDialog<int>(
      context: context,
      builder: (_) => const _AddBalanceDialog(),
    );

    if (result != null && mounted) {
      final current = int.tryParse(_currentBalance.text.trim()) ?? 0;
      setState(() {
        _currentBalance.text = '${current + result}';
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.account == null ? 'Новый счет' : 'Изменить счет'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: widget.account == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Название'),
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: const InputDecoration(labelText: 'Цвет'),
            child: Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                for (final color in _accountColors)
                  InkWell(
                    onTap: () => setState(() => _color = color.toARGB32()),
                    borderRadius: BorderRadius.circular(20),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: color,
                      child: _color == color.toARGB32()
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Тип'),
            items: const [
              DropdownMenuItem(value: 'BANK', child: Text('Банковский')),
              DropdownMenuItem(value: 'CASH', child: Text('Наличные')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _type = value);
            },
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Без снятия'),
            subtitle: const Text(
              'Перевод на этот счет будет считаться тратой. Его остаток не войдет в доступные деньги и лимиты.',
            ),
            value: _isNoWithdrawal,
            onChanged: (value) =>
                setState(() => _isNoWithdrawal = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Депозит'),
            subtitle: const Text(
              'Переводы на этот счет будут считаться расходами категории «Перевод на депозит».',
            ),
            value: _isDeposit,
            onChanged: (value) => setState(() => _isDeposit = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _currentBalance,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: InputDecoration(
              labelText: 'Текущий остаток',
              suffixText: '₸',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Прибавить сумму',
                onPressed: _showAddAmountDialog,
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.account == null ? 'Создать' : 'Сохранить'),
      ),
    ],
  );

  Future<void> _save() async {
    final balance = int.tryParse(_currentBalance.text.trim());
    if (_name.text.trim().isEmpty ||
        balance == null ||
        (widget.account == null && balance < 0)) {
      setState(() => _error = 'Укажите название и корректный остаток');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repository = ref.read(accountsRepositoryProvider);
      final account = widget.account;
      if (account == null) {
        await repository.create(
          name: _name.text,
          type: _type,
          initialBalance: balance,
          isNoWithdrawal: _isNoWithdrawal,
          isDeposit: _isDeposit,
          color: _color,
        );
      } else {
        await repository.update(
          id: account.id,
          name: _name.text,
          type: _type,
          initialBalance: account.initialBalance,
          currentBalance: balance,
          isNoWithdrawal: _isNoWithdrawal,
          isDeposit: _isDeposit,
          color: _color,
        );
      }
      ref.invalidate(allAccountsProvider);
      ref.invalidate(financeSnapshotProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Не удалось сохранить счет: $error';
        });
      }
    }
  }
}

class _AddBalanceDialog extends StatefulWidget {
  const _AddBalanceDialog();

  @override
  State<_AddBalanceDialog> createState() => _AddBalanceDialogState();
}

class _AddBalanceDialogState extends State<_AddBalanceDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Прибавить к остатку'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: const InputDecoration(
            labelText: 'Сумма',
            suffixText: '₸',
          ),
          onSubmitted: (value) {
            final amount = int.tryParse(value.trim());
            if (amount != null && amount != 0) {
              Navigator.pop(context, amount);
            }
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final delta in [1000, 5000, 10000, 50000, 100000])
              ActionChip(
                label: Text('+${_money.format(delta)}'),
                onPressed: () {
                  final current = int.tryParse(_controller.text.trim()) ?? 0;
                  _controller.text = '${current + delta}';
                },
              ),
          ],
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(
        onPressed: () {
          final amount = int.tryParse(_controller.text.trim());
          if (amount != null) {
            Navigator.pop(context, amount);
          }
        },
        child: const Text('Прибавить'),
      ),
    ],
  );
}

class AccountsSettingsSection extends ConsumerStatefulWidget {
  const AccountsSettingsSection({super.key});

  @override
  ConsumerState<AccountsSettingsSection> createState() =>
      _AccountsSettingsSectionState();
}

class _AccountsSettingsSectionState
    extends ConsumerState<AccountsSettingsSection> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(allAccountsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Счета',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            IconButton(
              tooltip: 'Добавить счет',
              onPressed: () => showCreateAccountDialog(context, ref),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Показать архивные счета'),
          value: _showArchived,
          onChanged: (value) => setState(() => _showArchived = value ?? false),
        ),
        accounts.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text('Не удалось загрузить счета: $error'),
          data: (items) {
            final visibleItems = items
                .where((account) => _showArchived || account.isActive)
                .toList();
            if (visibleItems.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    items.isEmpty ? 'Добавьте банковский счет или наличные.' : 'Активных счетов нет. Включите показ архивных счетов, чтобы восстановить счет.',
                  ),
                ),
              );
            }
            return Card(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                buildDefaultDragHandles: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleItems.length,
                onReorderItem: (oldIndex, newIndex) =>
                    _reorderAccounts(items, visibleItems, oldIndex, newIndex),
                itemBuilder: (context, index) {
                  final account = visibleItems[index];
                  return ListTile(
                    key: ValueKey(account.id),
                    leading: Icon(
                      account.type == 'CASH'
                          ? Icons.account_balance_wallet_outlined
                          : Icons.account_balance_outlined,
                    ),
                    title: Text(account.name),
                    subtitle: Text(
                      '${_money.format(account.currentBalance)} · ${account.currency}'
                      '${account.isNoWithdrawal ? ' · Без снятия' : ''}'
                      '${account.isActive ? '' : ' · В архиве'}',
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Действия со счетом',
                      onSelected: (action) =>
                          _handleAccountAction(account, action),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Изменить'),
                        ),
                        PopupMenuItem(
                          value: account.isActive ? 'archive' : 'restore',
                          child: Text(
                            account.isActive
                                ? 'Скрыть / удалить'
                                : 'Восстановить',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _reorderAccounts(
    List<Account> allItems,
    List<Account> visibleItems,
    int oldIndex,
    int newIndex,
  ) async {
    final reorderedVisible = [...visibleItems];
    final moved = reorderedVisible.removeAt(oldIndex);
    reorderedVisible.insert(newIndex, moved);
    final visibleIds = reorderedVisible.map((account) => account.id).toSet();
    var visibleIndex = 0;
    final reorderedAll = [
      for (final account in allItems)
        visibleIds.contains(account.id)
            ? reorderedVisible[visibleIndex++]
            : account,
    ];
    try {
      await ref
          .read(accountsRepositoryProvider)
          .reorder(reorderedAll.map((account) => account.id).toList());
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось изменить порядок: $error')),
        );
      }
    }
  }

  Future<void> _handleAccountAction(Account account, String action) async {
    if (action == 'edit') {
      await showEditAccountDialog(context, ref, account);
      return;
    }

    final repository = ref.read(accountsRepositoryProvider);
    try {
      if (action == 'restore') {
        await repository.setActive(account.id, true);
        ref.invalidate(allAccountsProvider);
        ref.invalidate(financeSnapshotProvider);
        return;
      }

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Скрыть или удалить счет?'),
          content: const Text(
            'Если к счету привязаны операции или регулярные платежи, он будет помещен в архив. Если привязок нет, счет будет удален без возможности восстановления.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      final archived = await repository.archiveOrDelete(account.id);
      ref.invalidate(allAccountsProvider);
      ref.invalidate(financeSnapshotProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(archived ? 'Счет помещен в архив' : 'Счет удален'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось изменить счет: $error')),
        );
      }
    }
  }
}
