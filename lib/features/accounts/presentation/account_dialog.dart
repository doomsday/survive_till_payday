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
  late final TextEditingController _initialBalance;
  late final TextEditingController _currentBalance;
  late String _type;
  late bool _isNoWithdrawal;
  late bool _isDeposit;
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
    _initialBalance = TextEditingController(
      text: '${account?.initialBalance ?? 0}',
    );
    _currentBalance = TextEditingController(
      text: '${account?.currentBalance ?? 0}',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _initialBalance.dispose();
    _currentBalance.dispose();
    super.dispose();
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
            controller: _initialBalance,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: widget.account == null
                  ? 'Текущий остаток'
                  : 'Начальный остаток',
              suffixText: '₸',
            ),
          ),
          if (widget.account != null) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _currentBalance,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              decoration: const InputDecoration(
                labelText: 'Текущий остаток',
                suffixText: '₸',
              ),
            ),
          ],
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
    final initialBalance = int.tryParse(_initialBalance.text.trim());
    final currentBalance = int.tryParse(_currentBalance.text.trim());
    if (_name.text.trim().isEmpty ||
        initialBalance == null ||
        initialBalance < 0 ||
        (widget.account != null && currentBalance == null)) {
      setState(() => _error = 'Укажите название и корректные остатки');
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
          initialBalance: initialBalance,
          isNoWithdrawal: _isNoWithdrawal,
          isDeposit: _isDeposit,
        );
      } else {
        await repository.update(
          id: account.id,
          name: _name.text,
          type: _type,
          initialBalance: initialBalance,
          currentBalance: currentBalance!,
          isNoWithdrawal: _isNoWithdrawal,
          isDeposit: _isDeposit,
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
              child: Column(
                children: [
                  for (final account in visibleItems)
                    ListTile(
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
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
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
