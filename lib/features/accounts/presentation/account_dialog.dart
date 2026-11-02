import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
    builder: (_) => const _CreateAccountDialog(),
  );
}

class _CreateAccountDialog extends ConsumerStatefulWidget {
  const _CreateAccountDialog();

  @override
  ConsumerState<_CreateAccountDialog> createState() =>
      _CreateAccountDialogState();
}

class _CreateAccountDialogState extends ConsumerState<_CreateAccountDialog> {
  final _name = TextEditingController();
  final _balance = TextEditingController(text: '0');
  String _type = 'BANK';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Новый счет'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _name,
          autofocus: true,
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
        TextField(
          controller: _balance,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Текущий остаток',
            suffixText: '₸',
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
            : const Text('Создать'),
      ),
    ],
  );

  Future<void> _save() async {
    final amount = int.tryParse(_balance.text.trim());
    if (_name.text.trim().isEmpty || amount == null || amount < 0) {
      setState(() => _error = 'Укажите название и корректный остаток');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(accountsRepositoryProvider)
          .create(name: _name.text, type: _type, initialBalance: amount);
      ref.invalidate(allAccountsProvider);
      ref.invalidate(financeSnapshotProvider);
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Не удалось создать счет: $error';
        });
      }
    }
  }
}

class AccountsSettingsSection extends ConsumerWidget {
  const AccountsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        accounts.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text('Не удалось загрузить счета: $error'),
          data: (items) => items.isEmpty
              ? const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Добавьте банковский счет или наличные.'),
                  ),
                )
              : Card(
                  child: Column(
                    children: [
                      for (final account in items)
                        ListTile(
                          leading: Icon(
                            account.type == 'CASH'
                                ? Icons.account_balance_wallet_outlined
                                : Icons.account_balance_outlined,
                          ),
                          title: Text(account.name),
                          subtitle: Text(
                            '${_money.format(account.currentBalance)} · ${account.currency}'
                            '${account.isActive ? '' : ' · Неактивен'}',
                          ),
                          trailing: Switch(
                            value: account.isActive,
                            onChanged: (value) async {
                              try {
                                await ref
                                    .read(accountsRepositoryProvider)
                                    .setActive(account.id, value);
                                ref.invalidate(financeSnapshotProvider);
                              } catch (error) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Не удалось изменить счет: $error',
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
