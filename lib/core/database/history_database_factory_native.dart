import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'app_database.dart';

Future<AppDatabase> createHistoryDatabase() async {
  final previousWarningSetting =
      driftRuntimeOptions.dontWarnAboutMultipleDatabases;
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  try {
    return AppDatabase(NativeDatabase.memory());
  } finally {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = previousWarningSetting;
  }
}
