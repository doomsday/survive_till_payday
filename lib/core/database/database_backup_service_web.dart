import 'dart:typed_data';

import 'app_database.dart';
import 'database_backup_service.dart';

class DatabaseBackupServiceImpl implements DatabaseBackupService {
  DatabaseBackupServiceImpl(AppDatabase database);

  DatabaseBackupException get _unavailable => const DatabaseBackupException(
    'Импорт и экспорт файлов базы данных недоступны в веб-версии.',
  );

  @override
  Future<Uint8List> createSnapshot() => Future.error(_unavailable);

  @override
  Future<BackupComparison> inspectImport(Uint8List bytes) =>
      Future.error(_unavailable);

  @override
  Future<BackupComparison> inspectLocalBackup(String path) =>
      Future.error(_unavailable);

  @override
  Future<String> replaceImport(Uint8List bytes) => Future.error(_unavailable);

  @override
  Future<String> restoreLocalBackup(String path) => Future.error(_unavailable);

  @override
  Future<List<LocalDatabaseBackup>> localBackups() =>
      Future.error(_unavailable);
}
