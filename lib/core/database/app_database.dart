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
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get type => text()();
  IntColumn get amount => integer()();
  TextColumn get currency => text().withDefault(const Constant('KZT'))();
  TextColumn get description => text().withDefault(const Constant(''))();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isExcludedFromStatistics =>
      boolean().withDefault(const Constant(false))();
  IntColumn get linkedPaymentOccurrenceId => integer().nullable()();
  IntColumn get transferGroupId => integer().nullable()();
}

class RecurringPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 120)();
  IntColumn get amount => integer()();
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get accountId => integer().nullable().references(Accounts, #id)();
  TextColumn get frequency => text()();
  IntColumn get paymentDay => integer().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isAutoPay => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().withDefault(const Constant(''))();
}

class PaymentOccurrences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recurringPaymentId =>
      integer().references(RecurringPayments, #id)();
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

class BackupImportIdentities extends Table {
  TextColumn get sourceDatabaseId => text()();
  TextColumn get sourceTable => text()();
  IntColumn get sourceId => integer()();
  IntColumn get targetId => integer()();

  @override
  Set<Column<Object>> get primaryKey => {
    sourceDatabaseId,
    sourceTable,
    sourceId,
  };
}

class DatabaseMetadata extends Table {
  IntColumn get id => integer()();
  TextColumn get databaseId => text()();
  IntColumn get revision => integer()();
  IntColumn get lastChangedAt => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Accounts,
    Categories,
    Transactions,
    RecurringPayments,
    PaymentOccurrences,
    IncomeSchedules,
    AppSettings,
    BackupImportIdentities,
    DatabaseMetadata,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'payday',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
      await _ensureMetadata();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await _seedDefaultCategories();
      if (from < 3) {
        await m.addColumn(recurringPayments, recurringPayments.isAutoPay);
      }
      if (from < 4) await m.createTable(backupImportIdentities);
      if (from < 5) {
        await m.createTable(databaseMetadata);
        await _ensureMetadata();
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await _ensureMetadata();
      await _installRevisionTriggers();
    },
  );

  Future<void> _ensureMetadata() => customStatement(
    'INSERT OR IGNORE INTO database_metadata '
    '(id, database_id, revision, last_changed_at) '
    "VALUES (1, lower(hex(randomblob(16))), 0, CAST(strftime('%s', 'now') AS INTEGER))",
  );

  Future<void> _installRevisionTriggers() async {
    const trackedTables = [
      'accounts',
      'categories',
      'transactions',
      'recurring_payments',
      'payment_occurrences',
      'income_schedules',
      'app_settings',
      'backup_import_identities',
    ];
    for (final table in trackedTables) {
      for (final event in const ['INSERT', 'UPDATE', 'DELETE']) {
        final trigger = 'revision_${table}_${event.toLowerCase()}';
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS "$trigger"
          AFTER $event ON "$table"
          BEGIN
            UPDATE database_metadata
            SET revision = revision + 1,
                last_changed_at = CAST(strftime('%s', 'now') AS INTEGER)
            WHERE id = 1;
          END
        ''');
      }
    }
  }

  Future<void> _seedDefaultCategories() async {
    const defaults = [
      ('Жильё', 'EXPENSE', 'home', 0xFF5C6BC0),
      ('Коммунальные услуги', 'EXPENSE', 'water', 0xFF42A5F5),
      ('Продукты', 'EXPENSE', 'groceries', 0xFF66BB6A),
      ('Кафе и рестораны', 'EXPENSE', 'restaurant', 0xFFFF7043),
      ('Транспорт', 'EXPENSE', 'transport', 0xFF26A69A),
      ('Автомобиль', 'EXPENSE', 'car', 0xFF78909C),
      ('Здоровье', 'EXPENSE', 'health', 0xFFEC407A),
      ('Подписки', 'EXPENSE', 'subscriptions', 0xFFAB47BC),
      ('Развлечения', 'EXPENSE', 'entertainment', 0xFF7E57C2),
      ('Покупки', 'EXPENSE', 'shopping', 0xFFFFA726),
      ('Алкоголь', 'EXPENSE', 'wine', 0xFF8D6E63),
      ('Налоги', 'EXPENSE', 'taxes', 0xFF607D8B),
      ('Образование', 'EXPENSE', 'education', 0xFF29B6F6),
      ('Другое', 'EXPENSE', 'category', 0xFF78909C),
      ('Зарплата', 'INCOME', 'salary', 0xFF43A047),
      ('Премия', 'INCOME', 'bonus', 0xFF7CB342),
      ('Фриланс', 'INCOME', 'work', 0xFF26A69A),
      ('Инвестиции', 'INCOME', 'investments', 0xFF00897B),
      ('Прочие доходы', 'INCOME', 'income', 0xFF009688),
    ];
    final existing = await select(categories).get();
    final existingKeys = {
      for (final category in existing) '${category.type}:${category.name}',
    };

    await batch((batch) {
      for (final (name, type, icon, color) in defaults) {
        if (existingKeys.add('$type:$name')) {
          batch.insert(
            categories,
            CategoriesCompanion.insert(
              name: name,
              type: type,
              icon: Value(icon),
              color: Value(color),
              isSystem: const Value(true),
            ),
          );
        }
      }
    });
  }
}
