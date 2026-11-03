import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_backup_service.dart';
import 'package:survive_till_payday/core/database/database_backup_service_native.dart';

void main() {
  test('tracks changes and replaces a database from a snapshot', () async {
    final directory = await Directory.systemTemp.createTemp('payday-transfer-');
    final databaseFile = File('${directory.path}/payday.sqlite');
    final database = AppDatabase(NativeDatabase(databaseFile));
    try {
      final service = DatabaseBackupServiceImpl(
        database,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => databaseFile.path,
      );
      final startRevision =
          (await database.select(database.databaseMetadata).getSingle())
              .revision;
      final accountId = await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Исходный счет',
              isNoWithdrawal: const Value(true),
              isDeposit: const Value(true),
            ),
          );
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'EXPENSE',
              amount: 10000,
              transactionDate: DateTime(2026, 11, 3),
              isUnavoidable: const Value(true),
            ),
          );
      final changedRevision =
          (await database.select(database.databaseMetadata).getSingle())
              .revision;
      expect(changedRevision, greaterThan(startRevision));

      final snapshot = await service.createSnapshot();
      expect(await service.inspectImport(snapshot), isA<BackupComparison>());
      await (database.update(database.accounts)
            ..where((account) => account.id.equals(accountId)))
          .write(const AccountsCompanion(name: Value('Измененный счет')));
      final stale = await service.inspectImport(snapshot);
      expect(stale.isOlder, isTrue);

      await service.replaceImport(snapshot);
      final restored = await database.select(database.accounts).getSingle();
      expect(restored.name, 'Исходный счет');
      expect(restored.isNoWithdrawal, isTrue);
      expect(restored.isDeposit, isTrue);
      expect(
        (await database.select(database.transactions).getSingle())
            .isUnavoidable,
        isTrue,
      );
      expect(await service.localBackups(), hasLength(1));
      expect(
        (await database.select(database.databaseMetadata).getSingle()).revision,
        greaterThan(changedRevision),
      );
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('compares change times for independent database copies', () async {
    final previousWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final directory = await Directory.systemTemp.createTemp(
      'payday-independent-import-',
    );
    final sourceFile = File('${directory.path}/source.sqlite');
    final targetFile = File('${directory.path}/target.sqlite');
    final sourceDatabase = AppDatabase(NativeDatabase(sourceFile));
    final targetDatabase = AppDatabase(NativeDatabase(targetFile));
    try {
      await sourceDatabase.customStatement(
        'UPDATE database_metadata SET last_changed_at = 1 WHERE id = 1',
      );
      final sourceService = DatabaseBackupServiceImpl(
        sourceDatabase,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => sourceFile.path,
      );
      final targetService = DatabaseBackupServiceImpl(
        targetDatabase,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => targetFile.path,
      );

      final comparison = await targetService.inspectImport(
        await sourceService.createSnapshot(),
      );

      expect(comparison.hasRevision, isTrue);
      expect(comparison.isOlder, isTrue);
    } finally {
      await sourceDatabase.close();
      await targetDatabase.close();
      await directory.delete(recursive: true);
      driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningSetting;
    }
  });

  test('upgrades a v4 database without losing its records', () async {
    final directory = await Directory.systemTemp.createTemp(
      'payday-v4-migration-',
    );
    final databaseFile = File('${directory.path}/payday.sqlite');
    final previousWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    AppDatabase? database;
    try {
      database = AppDatabase(NativeDatabase(databaseFile));
      await database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(name: 'Keep through migration'));
      final accountId =
          (await database.select(database.accounts).getSingle()).id;
      await database
          .into(database.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'EXPENSE',
              amount: 500,
              transactionDate: DateTime(2026, 11, 3),
            ),
          );
      await database.close();
      database = null;

      final oldDatabase = sqlite.sqlite3.open(databaseFile.path);
      try {
        final triggers = oldDatabase
            .select("SELECT name FROM sqlite_master WHERE type = 'trigger'")
            .map((row) => row['name']! as String)
            .toList();
        for (final trigger in triggers) {
          oldDatabase.execute('DROP TRIGGER "$trigger"');
        }
        oldDatabase.execute('DROP TABLE database_metadata');
        oldDatabase.execute(
          'ALTER TABLE accounts DROP COLUMN is_no_withdrawal',
        );
        oldDatabase.execute('ALTER TABLE accounts DROP COLUMN is_deposit');
        oldDatabase.execute('ALTER TABLE categories DROP COLUMN is_hidden');
        oldDatabase.execute(
          'ALTER TABLE transactions DROP COLUMN is_unavoidable',
        );
        oldDatabase.execute('PRAGMA user_version = 4');
      } finally {
        oldDatabase.close();
      }

      database = AppDatabase(NativeDatabase(databaseFile));
      expect(
        (await database.select(database.accounts).getSingle()).name,
        'Keep through migration',
      );
      expect(
        (await database.select(database.accounts).getSingle()).isNoWithdrawal,
        isFalse,
      );
      final migratedTransaction = await database
          .select(database.transactions)
          .getSingle();
      expect(migratedTransaction.amount, 500);
      expect(migratedTransaction.isUnavoidable, isFalse);
      final beforeInsert =
          (await database.select(database.databaseMetadata).getSingle())
              .revision;
      await database
          .into(database.accounts)
          .insert(AccountsCompanion.insert(name: 'Tracked after migration'));
      expect(
        (await database.select(database.databaseMetadata).getSingle()).revision,
        greaterThan(beforeInsert),
      );
    } finally {
      await database?.close();
      await directory.delete(recursive: true);
      driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningSetting;
    }
  });

  test('keeps six verified local backups', () async {
    final directory = await Directory.systemTemp.createTemp(
      'payday-backup-retention-',
    );
    final databaseFile = File('${directory.path}/payday.sqlite');
    final database = AppDatabase(NativeDatabase(databaseFile));
    try {
      final service = DatabaseBackupServiceImpl(
        database,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => databaseFile.path,
      );
      final snapshot = await service.createSnapshot();
      for (var index = 0; index < 7; index++) {
        await service.replaceImport(snapshot);
      }
      final backups = await service.localBackups();
      expect(backups, hasLength(6));
      for (final backup in backups) {
        expect(File(backup.path).existsSync(), isTrue);
      }
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test('imports v5 snapshots with a default no-withdrawal flag', () async {
    final directory = await Directory.systemTemp.createTemp(
      'payday-v5-import-',
    );
    final databaseFile = File('${directory.path}/payday.sqlite');
    final oldSnapshotFile = File('${directory.path}/old-snapshot.sqlite');
    final database = AppDatabase(NativeDatabase(databaseFile));
    try {
      await database
          .into(database.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Старый счет',
              isNoWithdrawal: const Value(true),
            ),
          );
      final service = DatabaseBackupServiceImpl(
        database,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => databaseFile.path,
      );
      await oldSnapshotFile.writeAsBytes(await service.createSnapshot());

      final oldDatabase = sqlite.sqlite3.open(oldSnapshotFile.path);
      try {
        oldDatabase.execute(
          'ALTER TABLE accounts DROP COLUMN is_no_withdrawal',
        );
        oldDatabase.execute('ALTER TABLE accounts DROP COLUMN is_deposit');
        oldDatabase.execute('ALTER TABLE categories DROP COLUMN is_hidden');
        oldDatabase.execute(
          'ALTER TABLE transactions DROP COLUMN is_unavoidable',
        );
        oldDatabase.execute('PRAGMA user_version = 5');
      } finally {
        oldDatabase.close();
      }

      await service.replaceImport(await oldSnapshotFile.readAsBytes());

      final imported = await database.select(database.accounts).getSingle();
      expect(imported.name, 'Старый счет');
      expect(imported.isNoWithdrawal, isFalse);
    } finally {
      await database.close();
      await directory.delete(recursive: true);
    }
  });

  test(
    'a failed replacement rolls back and preserves the pre-import backup',
    () async {
      final previousWarningSetting =
          driftRuntimeOptions.dontWarnAboutMultipleDatabases;
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      final directory = await Directory.systemTemp.createTemp(
        'payday-replacement-rollback-',
      );
      final sourceFile = File('${directory.path}/source.sqlite');
      final targetFile = File('${directory.path}/target.sqlite');
      final sourceDatabase = AppDatabase(NativeDatabase(sourceFile));
      final targetDatabase = AppDatabase(NativeDatabase(targetFile));
      try {
        await sourceDatabase
            .into(sourceDatabase.accounts)
            .insert(AccountsCompanion.insert(name: 'Rejected account'));
        await targetDatabase
            .into(targetDatabase.accounts)
            .insert(AccountsCompanion.insert(name: 'Keep existing account'));
        await targetDatabase.customStatement('''
        CREATE TRIGGER reject_test_account
        BEFORE INSERT ON accounts
        WHEN NEW.name = 'Rejected account'
        BEGIN
          SELECT RAISE(ABORT, 'test replacement failure');
        END
      ''');
        final sourceService = DatabaseBackupServiceImpl(
          sourceDatabase,
          documentsDirectory: () async => directory,
          databaseFilePath: () async => sourceFile.path,
        );
        final targetService = DatabaseBackupServiceImpl(
          targetDatabase,
          documentsDirectory: () async => directory,
          databaseFilePath: () async => targetFile.path,
        );
        await expectLater(
          targetService.replaceImport(await sourceService.createSnapshot()),
          throwsA(isA<DatabaseBackupException>()),
        );
        final accounts = await targetDatabase
            .select(targetDatabase.accounts)
            .get();
        expect(accounts.map((account) => account.name), [
          'Keep existing account',
        ]);
        expect(await targetService.localBackups(), hasLength(1));
      } finally {
        await sourceDatabase.close();
        await targetDatabase.close();
        await directory.delete(recursive: true);
        driftRuntimeOptions.dontWarnAboutMultipleDatabases =
            previousWarningSetting;
      }
    },
  );

  test('clears only a dangling optional link from a backup', () async {
    final previousWarningSetting =
        driftRuntimeOptions.dontWarnAboutMultipleDatabases;
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final directory = await Directory.systemTemp.createTemp(
      'payday-dangling-link-',
    );
    final sourceFile = File('${directory.path}/source.sqlite');
    final targetFile = File('${directory.path}/target.sqlite');
    final sourceDatabase = AppDatabase(NativeDatabase(sourceFile));
    final targetDatabase = AppDatabase(NativeDatabase(targetFile));
    try {
      await sourceDatabase
          .into(sourceDatabase.accounts)
          .insert(
            AccountsCompanion.insert(
              name: 'Source account',
              currentBalance: const Value(5000),
            ),
          );
      await sourceDatabase
          .into(sourceDatabase.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: 1,
              type: 'EXPENSE',
              amount: 100,
              transactionDate: DateTime(2026, 11, 3),
            ),
          );
      await sourceDatabase
          .into(sourceDatabase.incomeSchedules)
          .insert(
            IncomeSchedulesCompanion.insert(
              name: 'Schedule with old link',
              expectedAmount: 1000,
              frequency: 'MONTHLY',
              expectedDate: DateTime(2026, 12, 1),
              linkedTransactionId: const Value(99999),
            ),
          );
      final sourceService = DatabaseBackupServiceImpl(
        sourceDatabase,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => sourceFile.path,
      );
      final targetService = DatabaseBackupServiceImpl(
        targetDatabase,
        documentsDirectory: () async => directory,
        databaseFilePath: () async => targetFile.path,
      );
      final snapshot = await sourceService.createSnapshot();
      final legacyFile = File('${directory.path}/legacy-v4.sqlite');
      await legacyFile.writeAsBytes(snapshot, flush: true);
      final legacyDatabase = sqlite.sqlite3.open(legacyFile.path);
      try {
        final triggers = legacyDatabase
            .select("SELECT name FROM sqlite_master WHERE type = 'trigger'")
            .map((row) => row['name']! as String)
            .toList();
        for (final trigger in triggers) {
          legacyDatabase.execute('DROP TRIGGER "$trigger"');
        }
        legacyDatabase.execute('DROP TABLE database_metadata');
        legacyDatabase.execute('ALTER TABLE accounts DROP COLUMN is_deposit');
        legacyDatabase.execute('ALTER TABLE categories DROP COLUMN is_hidden');
        legacyDatabase.execute(
          'ALTER TABLE transactions DROP COLUMN is_unavoidable',
        );
        legacyDatabase.execute(
          "INSERT OR REPLACE INTO app_settings (key, value) "
          "VALUES ('backup_database_id', 'legacy-copy')",
        );
        legacyDatabase.execute('PRAGMA user_version = 4');
      } finally {
        legacyDatabase.close();
      }
      final legacyBytes = await legacyFile.readAsBytes();
      final comparison = await targetService.inspectImport(legacyBytes);
      expect(comparison.hasRevision, isFalse);
      expect(comparison.isOlder, isFalse);
      await targetService.replaceImport(legacyBytes);
      expect(
        await targetDatabase.select(targetDatabase.accounts).get(),
        hasLength(1),
      );
      expect(
        await targetDatabase.select(targetDatabase.transactions).get(),
        hasLength(1),
      );
      final schedule = await targetDatabase
          .select(targetDatabase.incomeSchedules)
          .getSingle();
      expect(schedule.name, 'Schedule with old link');
      expect(schedule.linkedTransactionId, null);
    } finally {
      await sourceDatabase.close();
      await targetDatabase.close();
      await directory.delete(recursive: true);
      driftRuntimeOptions.dontWarnAboutMultipleDatabases =
          previousWarningSetting;
    }
  });
}
