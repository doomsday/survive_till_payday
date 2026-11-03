import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_backup_service.dart';
import '../../../core/database/database_provider.dart';
import '../../accounts/presentation/account_dialog.dart';
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
  bool _databaseBusy = false;

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
            const AccountsSettingsSection(),
            const SizedBox(height: 24),
            Text('Данные', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage_outlined),
                title: const Text('База данных'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _databaseBusy ? null : _openDatabaseDialog,
              ),
            ),
            const SizedBox(height: 24),
            Text('Категории', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: const Text('Управление категориями'),
                subtitle: const Text('Расходы и доходы'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/categories'),
              ),
            ),
            const SizedBox(height: 24),
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

  Future<void> _openDatabaseDialog() async {
    final service = DatabaseBackupService(ref.read(databaseProvider));
    late final List<LocalDatabaseBackup> backups;
    try {
      backups = await service.localBackups();
    } catch (error) {
      if (mounted) await _showDatabaseError(error);
      return;
    }
    if (!mounted) return;
    final action = await showDialog<_DatabaseAction>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('База данных'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _DatabaseAction.export),
            child: const Text('Экспорт'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _DatabaseAction.import),
            child: const Text('Импорт'),
          ),
          if (backups.isNotEmpty)
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, _DatabaseAction.restoreLocal),
              child: const Text('Восстановить локальную копию'),
            ),
        ],
      ),
    );
    if (action == null || !mounted) return;
    setState(() => _databaseBusy = true);
    try {
      switch (action) {
        case _DatabaseAction.export:
          await _exportDatabase(service);
          break;
        case _DatabaseAction.import:
          await _importDatabase(service);
          break;
        case _DatabaseAction.restoreLocal:
          await _restoreLocalBackup(service, backups);
          break;
      }
    } catch (error) {
      if (mounted) await _showDatabaseError(error);
    } finally {
      if (mounted) setState(() => _databaseBusy = false);
    }
  }

  Future<void> _exportDatabase(DatabaseBackupService service) async {
    final saved = await FilePicker.saveFile(
      fileName: 'payday-backup.sqlite',
      bytes: await service.createSnapshot(),
      mimeType: 'application/vnd.sqlite3',
      dialogTitle: 'Сохранить резервную копию',
    );
    if (saved != null && mounted) _showDatabaseSuccess('Экспорт завершён.');
  }

  Future<void> _importDatabase(DatabaseBackupService service) async {
    final selected = await FilePicker.pickFile(
      dialogTitle: 'Выберите резервную копию Payday',
      type: FileType.custom,
      allowedExtensions: const ['sqlite', 'db'],
    );
    if (selected == null) return;
    final bytes = await selected.readAsBytes();
    final comparison = await service.inspectImport(bytes);
    if (!mounted || !await _confirmReplacement(comparison)) return;
    final message = await service.replaceImport(bytes);
    if (mounted) _showDatabaseSuccess(message);
  }

  Future<void> _restoreLocalBackup(
    DatabaseBackupService service,
    List<LocalDatabaseBackup> backups,
  ) async {
    final backup = await showDialog<LocalDatabaseBackup>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Локальные резервные копии'),
        children: [
          for (final item in backups)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, item),
              child: Text(
                DateFormat('dd.MM.yyyy HH:mm').format(item.createdAt),
              ),
            ),
        ],
      ),
    );
    if (backup == null || !mounted) return;
    final comparison = await service.inspectLocalBackup(backup.path);
    if (!mounted || !await _confirmReplacement(comparison)) return;
    final message = await service.restoreLocalBackup(backup.path);
    if (mounted) _showDatabaseSuccess(message);
  }

  Future<bool> _confirmReplacement(BackupComparison comparison) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(switch ((comparison.isOlder, comparison.hasRevision)) {
            (true, _) => 'В резервной копии более старые данные',
            (_, false) => 'Версию данных определить нельзя',
            _ => 'Заменить текущую базу данных?',
          }),
          content: Text(
            comparison.isOlder
                ? 'Выбранная копия старее текущей базы. Заменить текущие данные этой копией? Перед заменой будет сохранена резервная копия.'
                : !comparison.hasRevision
                ? 'В копии нет метки изменений, поэтому нельзя определить, новее ли она. Заменить текущие данные? Перед заменой будет сохранена резервная копия.'
                : 'Текущая база будет заменена выбранной копией. Перед заменой будет сохранена резервная копия.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Заменить'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _showDatabaseError(Object error) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Не удалось обработать базу данных'),
        content: Text(
          error is DatabaseBackupException
              ? error.message
              : 'Проверьте выбранный файл и повторите попытку.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      ),
    );
  }

  void _showDatabaseSuccess(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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

enum _DatabaseAction { export, import, restoreLocal }
