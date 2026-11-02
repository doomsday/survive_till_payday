import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text().withDefault(const Constant('BANK'))();
  TextColumn get currency => text().withDefault(const Constant('KZT'))();
  IntColumn get initialBalance => integer().withDefault(const Constant(0))();
  IntColumn get currentBalance => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text()();
  TextColumn get icon => text().withDefault(const Constant('category'))();
  IntColumn get color => integer().withDefault(const Constant(0xFF607D8B))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('KZT'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isExcludedFromStatistics => boolean().withDefault(const Constant(false))();
  IntColumn get linkedPaymentOccurrenceId => integer().nullable()();
  IntColumn get transferGroupId => integer().nullable()();
}

class RecurringPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get amount => integer()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get frequency => text()();
  IntColumn get paymentDay => integer().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get description => text().withDefault(const Constant(''))();
}

class PaymentOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recurringPaymentId => integer().references(RecurringPayments, #id)();
  IntColumn get expectedAmount => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('UPCOMING'))();
  IntColumn get paidAmount => integer().withDefault(const Constant(0))();
  IntColumn get linkedTransactionId => integer().nullable()();
}

class IncomeSchedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get expectedAmount => integer()();
  TextColumn get frequency => text()();
  DateTimeColumn get expectedDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get linkedTransactionId => integer().nullable()();
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Accounts,
  Categories,
  Transactions,
  RecurringPayments,
  PaymentOccurrences,
  IncomeSchedules,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'payday'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Add schema changes here in a new versioned migration.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
