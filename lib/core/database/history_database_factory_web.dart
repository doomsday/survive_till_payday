import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'app_database.dart';

final Future<WasmSqlite3> _sqlite = _loadSqlite();

Future<WasmSqlite3> _loadSqlite() async {
  final sqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
  sqlite.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return sqlite;
}

Future<AppDatabase> createHistoryDatabase() async {
  final sqlite = await _sqlite;
  final previousWarningSetting =
      driftRuntimeOptions.dontWarnAboutMultipleDatabases;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  try {
    return AppDatabase(WasmDatabase.inMemory(sqlite));
  } finally {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarningSetting;
  }
}
