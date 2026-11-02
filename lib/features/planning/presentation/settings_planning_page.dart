import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../planning_providers.dart';

class PlanningSettingsPage extends ConsumerStatefulWidget {
  const PlanningSettingsPage({super.key});

  @override
  ConsumerState<PlanningSettingsPage> createState() =>
      _PlanningSettingsPageState();
}

class _PlanningSettingsPageState extends ConsumerState<PlanningSettingsPage> {
  late Future<Map<String, String>> _settings;
  final _reserveController = TextEditingController();
  DateTime? _payday;
  bool _reserveEnabled = false;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _settings = ref.read(financialPlanningServiceProvider).getSettings();
  }

  @override
  void dispose() {
    _reserveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Финансовый план')),
    body: FutureBuilder<Map<String, String>>(
      future: _settings,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Не удалось загрузить настройки: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!_initialized) {
          final values = snapshot.data!;
          _reserveController.text = values['financial_reserve'] ?? '0';
          _reserveEnabled =
              (values['financial_reserve_enabled'] ?? 'true') == 'true';
          _payday = DateTime.tryParse(values['next_payday'] ?? '');
          _initialized = true;
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Следующая зарплата',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_outlined),
                title: Text(
                  _payday == null
                      ? 'Дата не задана'
                      : DateFormat('dd.MM.yyyy').format(_payday!),
                ),
                trailing: const Icon(Icons.edit_outlined),
                onTap: _selectPayday,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Финансовый резерв',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Учитывать резерв'),
              value: _reserveEnabled,
              onChanged: (value) => setState(() => _reserveEnabled = value),
            ),
            TextField(
              controller: _reserveController,
              enabled: _reserveEnabled,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Минимальный остаток',
                suffixText: '₸',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Сохранить'),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _selectPayday() async {
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _payday ?? today,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(2100),
    );
    if (selected != null) setState(() => _payday = selected);
  }

  Future<void> _save() async {
    final reserve = int.tryParse(_reserveController.text.trim());
    if (reserve == null || reserve < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите корректную сумму резерва')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final service = ref.read(financialPlanningServiceProvider);
      await service.setReserve(reserve, enabled: _reserveEnabled);
      await service.setNextPayday(_payday);
      ref.invalidate(financeSnapshotProvider);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Настройки сохранены')));
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Не удалось сохранить: $error')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
