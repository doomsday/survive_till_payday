import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(databaseProvider));
});

final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoriesRepositoryProvider).watchAll();
});

class CategoriesRepository {
  CategoriesRepository(this._database);

  final AppDatabase _database;

  Stream<List<Category>> watchAll() =>
      (_database.select(_database.categories)..orderBy([
            (category) => OrderingTerm.asc(category.type),
            (category) => OrderingTerm.asc(category.name),
          ]))
          .watch();

  Future<int> create({
    required String name,
    required String type,
    required String icon,
    required int color,
  }) {
    _validate(name, type);
    return _database
        .into(_database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name.trim(),
            type: type,
            icon: Value(icon),
            color: Value(color),
          ),
        );
  }

  Future<void> update({
    required int id,
    required String name,
    required String type,
    required String icon,
    required int color,
  }) async {
    _validate(name, type);
    final updated =
        await (_database.update(
          _database.categories,
        )..where((category) => category.id.equals(id))).write(
          CategoriesCompanion(
            name: Value(name.trim()),
            type: Value(type),
            icon: Value(icon),
            color: Value(color),
          ),
        );
    if (updated == 0) throw StateError('Category $id does not exist.');
  }

  Future<void> setArchived(int id, bool isArchived) async {
    final updated =
        await (_database.update(_database.categories)
              ..where((category) => category.id.equals(id)))
            .write(CategoriesCompanion(isArchived: Value(isArchived)));
    if (updated == 0) throw StateError('Category $id does not exist.');
  }

  void _validate(String name, String type) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || trimmedName.length > 80) {
      throw ArgumentError.value(name, 'name');
    }
    if (type != 'EXPENSE' && type != 'INCOME') {
      throw ArgumentError.value(type, 'type');
    }
  }
}
