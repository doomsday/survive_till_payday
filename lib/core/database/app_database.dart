import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

const depositTransferCategoryName = 'Перевод на депозит';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get type => text().withDefault(const Constant('BANK'))();
  TextColumn get currency => text().withDefault(const Constant('KZT'))();
  BoolColumn get isNoWithdrawal =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get isDeposit => boolean().withDefault(const Constant(false))();
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
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();
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
  BoolColumn get isUnavoidable =>
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

class DatabaseHistoryChanges extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityTable => text()();
  TextColumn get rowId => text()();
  IntColumn get recordedAt => integer()();
  TextColumn get operation => text()();
  TextColumn get beforeJson => text().nullable()();
  TextColumn get afterJson => text().nullable()();
}

class DatabaseHistoryMetadata extends Table {
  IntColumn get id => integer()();
  IntColumn get firstAvailableDate => integer()();

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
    DatabaseHistoryChanges,
    DatabaseHistoryMetadata,
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
  int get schemaVersion => 9;

  static const historyTables = {
    'accounts': [
      'id',
      'name',
      'type',
      'currency',
      'is_no_withdrawal',
      'is_deposit',
      'initial_balance',
      'current_balance',
      'is_active',
      'created_at',
    ],
    'categories': [
      'id',
      'name',
      'type',
      'icon',
      'color',
      'is_system',
      'is_archived',
      'is_hidden',
    ],
    'transactions': [
      'id',
      'account_id',
      'category_id',
      'type',
      'amount',
      'currency',
      'description',
      'transaction_date',
      'created_at',
      'updated_at',
      'is_excluded_from_statistics',
      'is_unavoidable',
      'linked_payment_occurrence_id',
      'transfer_group_id',
    ],
    'recurring_payments': [
      'id',
      'name',
      'amount',
      'category_id',
      'account_id',
      'frequency',
      'payment_day',
      'start_date',
      'end_date',
      'is_active',
      'is_auto_pay',
      'description',
    ],
    'payment_occurrences': [
      'id',
      'recurring_payment_id',
      'expected_amount',
      'due_date',
      'status',
      'paid_amount',
      'linked_transaction_id',
    ],
    'income_schedules': [
      'id',
      'name',
      'expected_amount',
      'frequency',
      'expected_date',
      'is_active',
      'linked_transaction_id',
    ],
    'app_settings': ['key', 'value'],
  };

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
      await _ensureMetadata();
    },
    onUpgrade: (m, from, to) async {
      if (from < 3) {
        await m.addColumn(recurringPayments, recurringPayments.isAutoPay);
      }
      if (from < 4) await m.createTable(backupImportIdentities);
      if (from < 5) {
        await m.createTable(databaseMetadata);
        await _ensureMetadata();
      }
      if (from < 6) await m.addColumn(accounts, accounts.isNoWithdrawal);
      if (from < 7) {
        await m.addColumn(accounts, accounts.isDeposit);
        await m.addColumn(categories, categories.isHidden);
        await ensureDepositTransferCategory();
      }
      if (from < 8) await m.addColumn(transactions, transactions.isUnavoidable);
      if (from < 9) {
        await m.createTable(databaseHistoryChanges);
        await m.createTable(databaseHistoryMetadata);
      }
      if (from < 2) await _seedDefaultCategories();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await ensureDepositTransferCategory();
      await _ensureMetadata();
      await _ensureHistoryBaseline();
      await _installHistoryTriggers();
      await _installRevisionTriggers();
    },
  );

  Future<DateTime> getHistoryFirstAvailableDate() async {
    await customSelect('SELECT 1').get();
    final metadata = await (select(
      databaseHistoryMetadata,
    )..where((row) => row.id.equals(1))).getSingle();
    return DateTime.fromMillisecondsSinceEpoch(metadata.firstAvailableDate)
        .toLocal();
  }

  Future<void> resetHistoryToCurrentState() async {
    await transaction(() async {
      await delete(databaseHistoryChanges).go();
      await delete(databaseHistoryMetadata).go();
      await _ensureHistoryBaseline();
    });
  }

  Future<void> _ensureHistoryBaseline() async {
    final existing = await (select(
      databaseHistoryMetadata,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    if (existing != null) return;

    final now = DateTime.now();
    final firstAvailableDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).millisecondsSinceEpoch;
    await into(databaseHistoryMetadata).insert(
      DatabaseHistoryMetadataCompanion.insert(
        id: const Value(1),
        firstAvailableDate: firstAvailableDate,
      ),
    );
    for (final table in historyTables.keys) {
      final rows = await customSelect('SELECT * FROM "$table"').get();
      for (final row in rows) {
        final values = row.data;
        final rowId = values['id']?.toString() ?? values['key'].toString();
        await into(databaseHistoryChanges).insert(
          DatabaseHistoryChangesCompanion.insert(
            entityTable: table,
            rowId: rowId,
            recordedAt: now.millisecondsSinceEpoch,
            operation: 'SNAPSHOT',
            afterJson: Value(jsonEncode(values)),
          ),
        );
      }
    }
  }

  Future<void> _installHistoryTriggers() async {
    const recordedAt =
        "(CAST(strftime('%s','now') AS INTEGER) * 1000 + "
        "CAST(substr(strftime('%f','now'), 4, 3) AS INTEGER))";
    for (final entry in historyTables.entries) {
      final table = entry.key;
      final keyColumn = table == 'app_settings' ? 'key' : 'id';
      final columns = entry.value;
      for (final event in const ['INSERT', 'UPDATE', 'DELETE']) {
        final isDelete = event == 'DELETE';
        final isInsert = event == 'INSERT';
        final oldRow = isInsert ? null : 'OLD';
        final newRow = isDelete ? null : 'NEW';
        final trigger = 'history_${table}_${event.toLowerCase()}';
        final beforeJson = oldRow == null
            ? 'NULL'
            : "json_object(${columns.map((column) => "'$column', $oldRow.\"$column\"").join(', ')})";
        final afterJson = newRow == null
            ? 'NULL'
            : "json_object(${columns.map((column) => "'$column', $newRow.\"$column\"").join(', ')})";
        final rowId = isDelete ? 'OLD."$keyColumn"' : 'NEW."$keyColumn"';
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS "$trigger"
          AFTER $event ON "$table"
          BEGIN
            INSERT INTO database_history_changes
              (entity_table, row_id, recorded_at, operation, before_json, after_json)
            VALUES
              ('$table', CAST($rowId AS TEXT), $recordedAt, '$event', $beforeJson, $afterJson);
          END
        ''');
      }
    }
  }

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
    await ensureDepositTransferCategory();
  }

  Future<void> ensureDepositTransferCategory() async {
    final existing =
        await (select(categories)..where(
              (category) =>
                  category.name.equals(depositTransferCategoryName) &
                  category.type.equals('EXPENSE') &
                  category.isHidden.equals(true),
            ))
            .getSingleOrNull();
    if (existing != null) return;
    await into(categories).insert(
      CategoriesCompanion.insert(
        name: depositTransferCategoryName,
        type: 'EXPENSE',
        icon: const Value('savings'),
        color: const Value(0xFF00897B),
        isSystem: const Value(true),
        isHidden: const Value(true),
      ),
    );
  }
}
