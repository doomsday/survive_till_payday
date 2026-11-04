import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'app_database.dart';
import 'database_backup_service.dart';

class DatabaseBackupServiceImpl implements DatabaseBackupService {
  DatabaseBackupServiceImpl(
    this.database, {
    Future<Directory> Function()? documentsDirectory,
    this.databaseFilePath,
  }) : _documentsDirectory =
           documentsDirectory ?? getApplicationDocumentsDirectory;

  final AppDatabase database;
  final Future<Directory> Function() _documentsDirectory;
  final Future<String> Function()? databaseFilePath;

  static const _backupDirectoryName = 'payday-backups';
  static const _backupPrefix = 'payday-before-import-';
  static const _retainedBackupCount = 6;
  static const _schemaVersion = 9;

  static const _columnsByTable = <String, List<String>>{
    'accounts': [
      'id',
      'name',
      'type',
      'currency',
      'is_no_withdrawal',
      'is_deposit',
      'initial_balance',
      'current_balance',
      'is_active',
      'created_at',
    ],
    'categories': [
      'id',
      'name',
      'type',
      'icon',
      'color',
      'is_system',
      'is_archived',
      'is_hidden',
    ],
    'transactions': [
      'id',
      'account_id',
      'category_id',
      'type',
      'amount',
      'currency',
      'description',
      'transaction_date',
      'created_at',
      'updated_at',
      'is_excluded_from_statistics',
      'is_unavoidable',
      'linked_payment_occurrence_id',
      'transfer_group_id',
    ],
    'recurring_payments': [
      'id',
      'name',
      'amount',
      'category_id',
      'account_id',
      'frequency',
      'payment_day',
      'start_date',
      'end_date',
      'is_active',
      'is_auto_pay',
      'description',
    ],
    'payment_occurrences': [
      'id',
      'recurring_payment_id',
      'expected_amount',
      'due_date',
      'status',
      'paid_amount',
      'linked_transaction_id',
    ],
    'income_schedules': [
      'id',
      'name',
      'expected_amount',
      'frequency',
      'expected_date',
      'is_active',
      'linked_transaction_id',
    ],
    'app_settings': ['key', 'value'],
    'database_history_changes': [
      'id',
      'entity_table',
      'row_id',
      'recorded_at',
      'operation',
      'before_json',
      'after_json',
    ],
    'database_history_metadata': ['id', 'first_available_date'],
  };

  static const _replacementOrder = [
    'accounts',
    'categories',
    'recurring_payments',
    'transactions',
    'payment_occurrences',
    'income_schedules',
    'app_settings',
    'database_history_metadata',
    'database_history_changes',
  ];

  @override
  Future<Uint8List> createSnapshot() async {
    final directory = await _documentsDirectory();
    final file = File(
      p.join(directory.path, 'payday-export-${_uniqueSuffix()}.sqlite'),
    );
    try {
      await _backupTo(file.path);
      return await file.readAsBytes();
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<BackupComparison> inspectImport(Uint8List bytes) async {
    final file = await _writeTemporaryImport(bytes);
    try {
      return await inspectLocalBackup(file.path);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<BackupComparison> inspectLocalBackup(String path) async {
    final source = _openAndValidate(path);
    try {
      final metadata = _readSourceMetadata(source);
      final current = await _currentMetadata();
      return BackupComparison(
        hasRevision: metadata.revision != null,
        isOlder:
            metadata.databaseId == current.databaseId &&
                metadata.revision != null
            ? metadata.revision! < current.revision!
            : metadata.lastChangedAt != null &&
                  metadata.lastChangedAt! < current.lastChangedAt!,
      );
    } finally {
      source.close();
    }
  }

  @override
  Future<String> replaceImport(Uint8List bytes) async {
    final file = await _writeTemporaryImport(bytes);
    try {
      return await restoreLocalBackup(file.path);
    } finally {
      if (await file.exists()) await file.delete();
    }
  }

  @override
  Future<String> restoreLocalBackup(String path) async {
    if (p.normalize(p.absolute(path)) ==
        p.normalize(p.absolute(await _liveDatabasePath()))) {
      throw const DatabaseBackupException(
        'Нельзя импортировать текущую базу данных.',
      );
    }
    final source = _openAndValidate(path);
    try {
      final sourceMetadata = _readSourceMetadata(source);
      final sourceVersion =
          source.select('PRAGMA user_version').single.values.first as int;
      final rowsByTable = {
        for (final table in _columnsByTable.keys)
          table:
              source
                  .select(
                    "SELECT 1 FROM sqlite_master WHERE type = 'table' "
                    "AND name = '$table'",
                  )
                  .isEmpty
              ? <Map<String, Object?>>[]
              : source
                    .select('SELECT * FROM "$table"')
                    .map((row) => Map<String, Object?>.from(row))
                    .toList(),
      };
      var backupCreated = false;
      try {
        await database.transaction(() async {
          final currentMetadata = await _currentMetadata();
          final backup = await _createAutomaticBackup();
          backupCreated = true;
          await _rotateBackups();
          final backupDatabase = _openAndValidate(backup.path);
          try {
            final backupMetadata = _readSourceMetadata(backupDatabase);
            if (backupMetadata.revision != currentMetadata.revision ||
                backupMetadata.databaseId != currentMetadata.databaseId) {
              throw const DatabaseBackupException(
                'База изменилась во время подготовки замены. Повторите импорт.',
              );
            }
          } finally {
            backupDatabase.close();
          }

          final importedRevision = sourceMetadata.revision ?? 0;
          final newRevision = currentMetadata.revision! > importedRevision
              ? currentMetadata.revision! + 1
              : importedRevision + 1;
          for (final table in _replacementOrder.reversed) {
            await database.customStatement('DELETE FROM "$table"');
          }
          await database.customStatement(
            'DELETE FROM backup_import_identities',
          );
          for (final table in _replacementOrder.where(
            (table) =>
                table != 'database_history_changes' &&
                table != 'database_history_metadata',
          )) {
            final columns = _columnsByTable[table]!;
            for (final sourceRow in rowsByTable[table]!) {
              final row = _normalizeOptionalLinks(
                table,
                sourceRow,
                rowsByTable,
              );
              await database.customStatement(
                'INSERT INTO "$table" '
                '(${columns.map((column) => '"$column"').join(', ')}) '
                'VALUES (${List.filled(columns.length, '?').join(', ')})',
                columns
                    .map(
                      (column) => column == 'is_unavoidable'
                          ? row[column] ?? 0
                          : row[column],
                    )
                    .toList(),
              );
            }
          }
          await database.customStatement(
            'DELETE FROM database_history_changes',
          );
          await database.customStatement(
            'DELETE FROM database_history_metadata',
          );
          if (sourceVersion >= 9) {
            for (final sourceRow in rowsByTable['database_history_metadata']!) {
              await database.customStatement(
                'INSERT INTO database_history_metadata '
                '(id, first_available_date) VALUES (?, ?)',
                [sourceRow['id'], sourceRow['first_available_date']],
              );
            }
            for (final sourceRow in rowsByTable['database_history_changes']!) {
              await database.customStatement(
                'INSERT INTO database_history_changes '
                '(id, entity_table, row_id, recorded_at, operation, before_json, after_json) '
                'VALUES (?, ?, ?, ?, ?, ?, ?)',
                [
                  sourceRow['id'],
                  sourceRow['entity_table'],
                  sourceRow['row_id'],
                  sourceRow['recorded_at'],
                  sourceRow['operation'],
                  sourceRow['before_json'],
                  sourceRow['after_json'],
                ],
              );
            }
          } else {
            await database.resetHistoryToCurrentState();
          }

          final databaseId =
              sourceMetadata.databaseId ?? currentMetadata.databaseId;
          await database.ensureDepositTransferCategory();
          await database.customStatement(
            'UPDATE database_metadata '
            'SET database_id = ?, revision = ?, '
            "last_changed_at = CAST(strftime('%s', 'now') AS INTEGER) "
            'WHERE id = 1',
            [databaseId, newRevision],
          );

          final integrity = await database
              .customSelect('PRAGMA integrity_check')
              .get();
          if (integrity.length != 1 ||
              integrity.single.data.values.first != 'ok') {
            throw const DatabaseBackupException(
              'Проверка базы после замены не пройдена.',
            );
          }
          final foreignKeyErrors = await database
              .customSelect('PRAGMA foreign_key_check')
              .get();
          if (foreignKeyErrors.isNotEmpty) {
            throw const DatabaseBackupException(
              'В файле нарушены связи финансовых записей.',
            );
          }
        });
      } catch (error) {
        final recoveryMessage = backupCreated
            ? 'Текущие данные сохранены. Перед заменой создана резервная копия.'
            : 'Текущие данные не изменены; резервную копию создать не удалось.';
        throw DatabaseBackupException(
          '${error is DatabaseBackupException ? error.message : 'Не удалось заменить базу данных.'} '
          '$recoveryMessage',
        );
      }

      database.markTablesUpdated([
        database.accounts,
        database.categories,
        database.transactions,
        database.recurringPayments,
        database.paymentOccurrences,
        database.incomeSchedules,
        database.appSettings,
        database.backupImportIdentities,
      ]);
      return 'База данных восстановлена. Перед заменой сохранена резервная копия.';
    } finally {
      source.close();
    }
  }

  Map<String, Object?> _normalizeOptionalLinks(
    String table,
    Map<String, Object?> sourceRow,
    Map<String, List<Map<String, Object?>>> rowsByTable,
  ) {
    final row = Map<String, Object?>.from(sourceRow);
    if (table == 'accounts') {
      row.putIfAbsent('is_no_withdrawal', () => 0);
      row.putIfAbsent('is_deposit', () => 0);
    }
    if (table == 'categories') {
      row.putIfAbsent(
        'is_hidden',
        () => row['name'] == depositTransferCategoryName ? 1 : 0,
      );
    }
    final linkColumn = switch (table) {
      'transactions' => 'linked_payment_occurrence_id',
      'payment_occurrences' || 'income_schedules' => 'linked_transaction_id',
      _ => null,
    };
    if (linkColumn == null || row[linkColumn] == null) return row;
    final linkedTable = table == 'transactions'
        ? 'payment_occurrences'
        : 'transactions';
    final linkedIds = rowsByTable[linkedTable]!
        .map((item) => item['id'])
        .toSet();
    if (!linkedIds.contains(row[linkColumn])) row[linkColumn] = null;
    return row;
  }

  @override
  Future<List<LocalDatabaseBackup>> localBackups() async {
    await _migrateLegacyBackups();
    final directory = await _backupDirectory();
    if (!await directory.exists()) return const [];
    final backups = <LocalDatabaseBackup>[];
    await for (final entity in directory.list()) {
      if (entity is! File ||
          !p.basename(entity.path).startsWith(_backupPrefix) ||
          !entity.path.endsWith('.sqlite')) {
        continue;
      }
      final suffix = p
          .basenameWithoutExtension(entity.path)
          .substring(_backupPrefix.length);
      final parts = suffix.split('-');
      final revision = parts.first.startsWith('r')
          ? int.tryParse(parts.first.substring(1))
          : null;
      final timestampIndex = revision == null ? 0 : 1;
      if (parts.length <= timestampIndex) continue;
      final timestamp = int.tryParse(parts[timestampIndex]);
      if (timestamp == null) continue;
      backups.add(
        LocalDatabaseBackup(
          path: entity.path,
          createdAt: DateTime.fromMicrosecondsSinceEpoch(timestamp),
          revision: revision,
        ),
      );
    }
    backups.sort((a, b) {
      final revisionOrder = (b.revision ?? -1).compareTo(a.revision ?? -1);
      return revisionOrder == 0
          ? b.createdAt.compareTo(a.createdAt)
          : revisionOrder;
    });
    return backups;
  }

  Future<File> _writeTemporaryImport(Uint8List bytes) async {
    final directory = await _documentsDirectory();
    final file = File(
      p.join(directory.path, 'payday-import-${_uniqueSuffix()}.sqlite'),
    );
    try {
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (_) {
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  sqlite.Database _openAndValidate(String path) {
    sqlite.Database? source;
    try {
      source = sqlite.sqlite3.open(path, mode: sqlite.OpenMode.readOnly);
      _validate(source);
      return source;
    } on sqlite.SqliteException {
      source?.close();
      throw const DatabaseBackupException(
        'Не удалось прочитать файл базы данных. Проверьте выбранный файл.',
      );
    } on DatabaseBackupException {
      source?.close();
      rethrow;
    }
  }

  void _validate(sqlite.Database source) {
    final version =
        source.select('PRAGMA user_version').single.values.first as int;
    if (version < 4 || version > _schemaVersion) {
      throw const DatabaseBackupException(
        'Версия файла базы данных не поддерживается.',
      );
    }
    final integrity = source.select('PRAGMA integrity_check');
    if (integrity.length != 1 || integrity.single.values.first != 'ok') {
      throw const DatabaseBackupException(
        'Не удалось прочитать файл базы данных. Проверьте выбранный файл.',
      );
    }
    if (source.select('PRAGMA foreign_key_check').isNotEmpty) {
      throw const DatabaseBackupException(
        'В файле нарушены связи финансовых записей.',
      );
    }
    for (final entry in _columnsByTable.entries) {
      if (version < 9 &&
          (entry.key == 'database_history_changes' ||
              entry.key == 'database_history_metadata')) {
        continue;
      }
      final columns = source
          .select('PRAGMA table_info("${entry.key}")')
          .map((row) => row['name'] as String)
          .toSet();
      final expectedColumns = entry.value.toSet();
      if (entry.key == 'accounts' && !columns.contains('is_no_withdrawal')) {
        expectedColumns.remove('is_no_withdrawal');
      }
      if (version < 7) {
        if (entry.key == 'accounts') expectedColumns.remove('is_deposit');
        if (entry.key == 'categories') expectedColumns.remove('is_hidden');
      }
      if (version < 8 && entry.key == 'transactions') {
        expectedColumns.remove('is_unavoidable');
      }
      if (columns.length != expectedColumns.length ||
          !columns.containsAll(expectedColumns)) {
        throw const DatabaseBackupException(
          'Этот файл относится к другой базе данных или несовместимой версии.',
        );
      }
    }
    if (version == 4 &&
        source
            .select(
              "SELECT 1 FROM sqlite_master WHERE type = 'table' "
              "AND name = 'backup_import_identities'",
            )
            .isEmpty) {
      throw const DatabaseBackupException(
        'Этот файл относится к другой базе данных.',
      );
    }
    if (version >= 5) {
      final metadataColumns = source
          .select('PRAGMA table_info("database_metadata")')
          .map((row) => row['name'] as String)
          .toSet();
      if (!metadataColumns.containsAll(const {
        'id',
        'database_id',
        'revision',
        'last_changed_at',
      })) {
        throw const DatabaseBackupException(
          'Этот файл относится к другой базе данных.',
        );
      }
    }
  }

  _SourceMetadata _readSourceMetadata(sqlite.Database source) {
    final version =
        source.select('PRAGMA user_version').single.values.first as int;
    if (version >= 5) {
      final rows = source.select(
        'SELECT database_id, revision, last_changed_at '
        'FROM database_metadata WHERE id = 1',
      );
      if (rows.length != 1) {
        throw const DatabaseBackupException(
          'В файле отсутствует метка версии данных.',
        );
      }
      return _SourceMetadata(
        databaseId: rows.single['database_id'] as String,
        revision: rows.single['revision'] as int,
        lastChangedAt: rows.single['last_changed_at'] as int,
      );
    }

    final rows = source.select('SELECT value FROM app_settings WHERE key = ?', [
      'backup_database_id',
    ]);
    return _SourceMetadata(
      databaseId: rows.isEmpty ? null : rows.single['value'] as String,
      revision: null,
      lastChangedAt: null,
    );
  }

  Future<_SourceMetadata> _currentMetadata() async {
    final metadata = await database
        .select(database.databaseMetadata)
        .getSingle();
    return _SourceMetadata(
      databaseId: metadata.databaseId,
      revision: metadata.revision,
      lastChangedAt: metadata.lastChangedAt,
    );
  }

  Future<File> _createAutomaticBackup() async {
    final directory = await _backupDirectory();
    await directory.create(recursive: true);
    final temporary = File(
      p.join(directory.path, '.payday-backup-${_uniqueSuffix()}.partial'),
    );
    try {
      await _backupTo(temporary.path);
      final backupDatabase = _openAndValidate(temporary.path);
      late final int revision;
      try {
        revision =
            _readSourceMetadata(backupDatabase).revision ??
            (throw const DatabaseBackupException(
              'В резервной копии отсутствует метка версии данных.',
            ));
      } finally {
        backupDatabase.close();
      }
      final file = File(
        p.join(
          directory.path,
          '$_backupPrefix'
          'r$revision-${_uniqueSuffix()}.sqlite',
        ),
      );
      await temporary.rename(file.path);
      return file;
    } catch (_) {
      if (await temporary.exists()) await temporary.delete();
      rethrow;
    }
  }

  Future<void> _rotateBackups() async {
    final backups = await localBackups();
    for (final oldBackup in backups.skip(_retainedBackupCount)) {
      await File(oldBackup.path).delete();
    }
  }

  Future<Directory> _backupDirectory() async {
    final directory = await _documentsDirectory();
    return Directory(p.join(directory.path, _backupDirectoryName));
  }

  Future<void> _migrateLegacyBackups() async {
    final documents = await _documentsDirectory();
    final legacyFiles = <File>[];
    await for (final entity in documents.list()) {
      if (entity is File &&
          p.dirname(entity.path) == documents.path &&
          p.basename(entity.path).startsWith(_backupPrefix) &&
          entity.path.endsWith('.sqlite')) {
        legacyFiles.add(entity);
      }
    }
    if (legacyFiles.isEmpty) return;

    final directory = await _backupDirectory();
    await directory.create(recursive: true);
    for (final file in legacyFiles) {
      final oldSuffix = p
          .basenameWithoutExtension(file.path)
          .substring(_backupPrefix.length);
      final suffix = int.tryParse(oldSuffix) == null
          ? _uniqueSuffix()
          : '$oldSuffix-0';
      var destination = File(
        p.join(directory.path, '$_backupPrefix$suffix.sqlite'),
      );
      if (await destination.exists()) {
        destination = File(
          p.join(directory.path, '$_backupPrefix${_uniqueSuffix()}.sqlite'),
        );
      }
      await file.rename(destination.path);
    }
  }

  Future<void> _backupTo(String destinationPath) async {
    await _currentMetadata();
    final sourcePath = await _liveDatabasePath();
    sqlite.Database? source;
    sqlite.Database? destination;
    try {
      source = sqlite.sqlite3.open(sourcePath, mode: sqlite.OpenMode.readOnly);
      destination = sqlite.sqlite3.open(destinationPath);
      await source.backup(destination).drain<void>();
      final integrity = destination.select('PRAGMA integrity_check');
      if (integrity.length != 1 || integrity.single.values.first != 'ok') {
        throw const DatabaseBackupException(
          'Не удалось создать целостную резервную копию.',
        );
      }
    } on sqlite.SqliteException {
      throw const DatabaseBackupException(
        'Не удалось создать резервную копию текущей базы данных.',
      );
    } finally {
      destination?.close();
      source?.close();
    }
  }

  Future<String> _liveDatabasePath() async {
    if (databaseFilePath != null) return databaseFilePath!();
    final directory = await _documentsDirectory();
    return p.join(directory.path, 'payday.sqlite');
  }

  String _uniqueSuffix() =>
      '${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
}

class _SourceMetadata {
  const _SourceMetadata({
    required this.databaseId,
    required this.revision,
    required this.lastChangedAt,
  });

  final String? databaseId;
  final int? revision;
  final int? lastChangedAt;
}
