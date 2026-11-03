import 'dart:typed_data';

import 'app_database.dart';
import 'database_backup_service_native.dart'
    if (dart.library.js_interop) 'database_backup_service_web.dart'
    as platform;

class DatabaseBackupException implements Exception {
  const DatabaseBackupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackupComparison {
  const BackupComparison({required this.isOlder, required this.hasRevision});

  final bool isOlder;
  final bool hasRevision;
}

class LocalDatabaseBackup {
  const LocalDatabaseBackup({
    required this.path,
    required this.createdAt,
    required this.revision,
  });

  final String path;
  final DateTime createdAt;
  final int? revision;
}

abstract interface class DatabaseBackupService {
  factory DatabaseBackupService(AppDatabase database) =
      platform.DatabaseBackupServiceImpl;

  Future<Uint8List> createSnapshot();

  Future<BackupComparison> inspectImport(Uint8List bytes);

  Future<BackupComparison> inspectLocalBackup(String path);

  Future<String> replaceImport(Uint8List bytes);

  Future<String> restoreLocalBackup(String path);

  Future<List<LocalDatabaseBackup>> localBackups();
}
