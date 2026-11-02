import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PaydayApp()));
}
