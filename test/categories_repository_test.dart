import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/features/categories/categories_repository.dart';

void main() {
  late AppDatabase database;
  late CategoriesRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CategoriesRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'seeds default expense and income categories on database creation',
    () async {
      final categories = await repository.watchAll().first;

      expect(categories, hasLength(19));
      expect(
        categories.where((category) => category.type == 'EXPENSE'),
        hasLength(14),
      );
      expect(
        categories.where((category) => category.type == 'INCOME'),
        hasLength(5),
      );
      expect(categories.every((category) => category.isSystem), isTrue);
      expect(categories.map((category) => category.name), contains('Продукты'));
      expect(categories.map((category) => category.name), contains('Зарплата'));
      expect(
        categories.map((category) => category.name),
        isNot(contains(depositTransferCategoryName)),
      );
      final hiddenCategory =
          await (database.select(database.categories)..where(
                (category) => category.name.equals(depositTransferCategoryName),
              ))
              .getSingle();
      expect(hiddenCategory.isHidden, isTrue);
    },
  );

  test('custom categories can be edited and archived without breaking transactions', () async {
    final accountId = await database
        .into(database.accounts)
        .insert(AccountsCompanion.insert(name: 'Основной'));
    final categoryId = await repository.create(
      name: 'Питомцы',
      type: 'EXPENSE',
      icon: 'health',
      color: 0xFFEC407A,
    );
    final transactionId = await database
        .into(database.transactions)
        .insert(
          TransactionsCompanion.insert(
            accountId: accountId,
            categoryId: Value(categoryId),
            type: 'EXPENSE',
            amount: 2500,
            transactionDate: DateTime(2026, 11, 3),
          ),
        );

    await repository.update(
      id: categoryId,
      name: 'Уход за питомцами',
      type: 'EXPENSE',
      icon: 'category',
      color: 0xFF607D8B,
    );
    await repository.setArchived(categoryId, true);

    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals(categoryId))).getSingle();
    final transaction = await (database.select(
      database.transactions,
    )..where((row) => row.id.equals(transactionId))).getSingle();

    expect(category.name, 'Уход за питомцами');
    expect(category.isArchived, isTrue);
    expect(transaction.categoryId, categoryId);
  });

  test('rejects invalid category names and types', () async {
    expect(
      () => repository.create(
        name: ' ',
        type: 'EXPENSE',
        icon: 'category',
        color: 0xFF607D8B,
      ),
      throwsArgumentError,
    );
    expect(
      () => repository.create(
        name: 'Вклад',
        type: 'TRANSFER',
        icon: 'category',
        color: 0xFF607D8B,
      ),
      throwsArgumentError,
    );
  });

  test(
    'upgrade from version 1 seeds defaults and preserves user categories',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'payday-migration-',
      );
      final previousWarningSetting =
          driftRuntimeOptions.dontWarnAboutMultipleDatabases;
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      AppDatabase? databaseUnderTest;
      try {
        final file = File('${directory.path}/payday.sqlite');
        databaseUnderTest = AppDatabase(NativeDatabase(file));
        await databaseUnderTest.select(databaseUnderTest.categories).get();
        await databaseUnderTest.customStatement('DELETE FROM categories');
        await databaseUnderTest
            .into(databaseUnderTest.categories)
            .insert(
              CategoriesCompanion.insert(
                name: 'Моя категория',
                type: 'EXPENSE',
              ),
            );
        await databaseUnderTest
            .into(databaseUnderTest.recurringPayments)
            .insert(
              RecurringPaymentsCompanion.insert(
                name: 'Платеж из старой версии',
                amount: 1000,
                frequency: 'MONTHLY',
                startDate: DateTime(2026, 11, 3),
              ),
            );
        await databaseUnderTest.customStatement(
          'ALTER TABLE recurring_payments DROP COLUMN is_auto_pay',
        );
        await databaseUnderTest.customStatement(
          'ALTER TABLE accounts DROP COLUMN is_no_withdrawal',
        );
        await databaseUnderTest.customStatement(
          'ALTER TABLE accounts DROP COLUMN is_deposit',
        );
        await databaseUnderTest.customStatement(
          'ALTER TABLE categories DROP COLUMN is_hidden',
        );
        await databaseUnderTest.customStatement('PRAGMA user_version = 1');
        await databaseUnderTest.close();

        databaseUnderTest = AppDatabase(NativeDatabase(file));
        final categories = await databaseUnderTest
            .select(databaseUnderTest.categories)
            .get();
        expect(categories, hasLength(21));
        expect(
          categories.map((category) => category.name),
          contains('Моя категория'),
        );
        expect(
          categories.map((category) => category.name),
          contains('Зарплата'),
        );
        final migratedPayment =
            (await databaseUnderTest
                    .select(databaseUnderTest.recurringPayments)
                    .get())
                .single;
        expect(migratedPayment.isAutoPay, isFalse);
      } finally {
        await databaseUnderTest?.close();
        await directory.delete(recursive: true);
        driftRuntimeOptions.dontWarnAboutMultipleDatabases =
            previousWarningSetting;
      }
    },
  );
}
