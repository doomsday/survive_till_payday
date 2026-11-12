/// Сервис финансового планирования: расчёт доступных средств, управление
/// recurring платежами, расписанием доходов и историей базы.
///
/// Основные возможности:
/// - Расчёт [FinanceSnapshot] — сколько можно потратить до зарплаты и сегодня;
/// - Генерация payment occurrences из recurring платежей;
/// - Автооплата платежей по расписанию;
/// - Восстановление состояния базы на произвольную дату в прошлом;
/// - Управление резервом и датой следующей зарплаты.
///
/// Все финансовые расчёты сосредоточены в функции [calculateFinanceSnapshot],
/// которая принимает сырые данные и возвращает готовый снимок метрик.
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/history_database_factory.dart';

/// Нормализует [DateTime], оставляя только дату (обнуляет время).
/// Используется повсеместно для корректного сравнения дат без учёта времени.
DateTime calendarDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

/// Частота повторения платежей и доходов.
enum PlanningFrequency { once, weekly, monthly, quarterly, yearly }

/// Парсит строковое значение частоты в [PlanningFrequency].
/// Неизвестные значения возвращают [PlanningFrequency.once].
PlanningFrequency parseFrequency(String value) => switch (value.toUpperCase()) {
  'WEEKLY' => PlanningFrequency.weekly,
  'MONTHLY' => PlanningFrequency.monthly,
  'QUARTERLY' => PlanningFrequency.quarterly,
  'YEARLY' => PlanningFrequency.yearly,
  _ => PlanningFrequency.once,
};

/// Возвращает локализованную строку для частоты повторения.
String frequencyLabel(PlanningFrequency frequency) => switch (frequency) {
  PlanningFrequency.once => 'Разово',
  PlanningFrequency.weekly => 'Еженедельно',
  PlanningFrequency.monthly => 'Ежемесячно',
  PlanningFrequency.quarterly => 'Ежеквартально',
  PlanningFrequency.yearly => 'Ежегодно',
};

/// Вычисляет следующую дату по расписанию.
///
/// Для [PlanningFrequency.once] возвращает `null`.
/// Параметр [paymentDay] позволяет задать фиксированный день месяца,
/// что полезно при изменении количества дней в месяце.
DateTime? nextScheduledDate({
  required DateTime date,
  required PlanningFrequency frequency,
  int? paymentDay,
}) {
  final day = paymentDay ?? date.day;
  return switch (frequency) {
    PlanningFrequency.once => null,
    PlanningFrequency.weekly => calendarDate(date.add(const Duration(days: 7))),
    PlanningFrequency.monthly => _monthDate(date.year, date.month + 1, day),
    PlanningFrequency.quarterly => _monthDate(date.year, date.month + 3, day),
    PlanningFrequency.yearly => _monthDate(date.year + 1, date.month, day),
  };
}

/// Вычисляет предыдущую дату по расписанию (аналогично [nextScheduledDate]).
DateTime? previousScheduledDate({
  required DateTime date,
  required PlanningFrequency frequency,
  int? paymentDay,
}) {
  final day = paymentDay ?? date.day;
  return switch (frequency) {
    PlanningFrequency.once => null,
    PlanningFrequency.weekly => calendarDate(
      date.subtract(const Duration(days: 7)),
    ),
    PlanningFrequency.monthly => _monthDate(date.year, date.month - 1, day),
    PlanningFrequency.quarterly => _monthDate(date.year, date.month - 3, day),
    PlanningFrequency.yearly => _monthDate(date.year - 1, date.month, day),
  };
}

/// Создаёт [DateTime] для заданного месяца, корректно обрабатывая переполнение.
///
/// Если [month] выходит за пределы 1–12, год корректируется автоматически.
/// Если [day] больше последнего дня месяца, он обрезается до последнего дня.
DateTime _monthDate(int year, int month, int day) {
  final first = DateTime(year, month);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, day.clamp(1, lastDay));
}

/// Мгновенный снимок ключевых финансовых метрик.
///
/// Рассчитывается на основе текущих балансов, ожидаемых доходов,
/// неоплаченных платежей и настроек резерва. Используется дашбордом
/// для отображения главного KPI — «сколько можно потратить».
///
/// Основные метрики:
/// - [safeToSpend] — общая сумма, доступная до следующей зарплаты;
/// - [dailySafeToSpend] — дневная норма трат;
/// - [accumulatedBalance] — «экономия» за прошедшие дни цикла;
/// - [availableToday] — сколько можно потратить сегодня с учётом экономии;
/// - [dayBalance] — сколько осталось на сегодня после фактических расходов.
class FinanceSnapshot {
  const FinanceSnapshot({
    required this.currentBalance,
    required this.expectedIncome,
    required this.reservedPayments,
    required this.reserve,
    required this.nextPayday,
    required this.daysUntilPayday,
    required this.safeToSpend,
    required this.dailySafeToSpend,
    required this.accumulatedBalance,
    required this.availableToday,
    required this.todayExpenses,
    required this.dailyLimitBalance,
    required this.dayBalance,
  });

  /// Текущий баланс всех активных счетов (без no-withdrawal).
  final int currentBalance;
  /// Сумма ожидаемых доходов до следующей зарплаты.
  final int expectedIncome;
  /// Сумма неоплаченных платежей до следующей зарплаты.
  final int reservedPayments;
  /// Настроенный финансовый резерв (не трогается).
  final int reserve;
  /// Дата следующей зарплаты.
  final DateTime? nextPayday;
  /// Количество дней до следующей зарплаты.
  final int? daysUntilPayday;
  /// Общая сумма, которую можно потратить до зарплаты.
  /// Формула: `currentBalance + expectedIncome - reservedPayments - reserve`.
  final int? safeToSpend;
  /// Дневная норма трат: [safeToSpend] / [daysUntilPayday].
  /// Может быть скорректирована с учётом фактических расходов цикла.
  final int? dailySafeToSpend;
  /// Накопленная «экономия» за прошедшие дни цикла.
  /// Формула: `dailySafeToSpend × elapsedDays − expensesBeforeToday`.
  /// Положительная — тратили меньше нормы, отрицательная — больше.
  final int? accumulatedBalance;
  /// Сколько можно потратить сегодня с учётом экономии.
  /// Формула: `dailySafeToSpend + accumulatedBalance`.
  final int? availableToday;
  /// Фактические расходы за сегодня (ручные, не неизбежные).
  final int? todayExpenses;
  /// Остаток дневной нормы после расходов сегодня.
  /// Формула: `dailySafeToSpend − todayExpenses`.
  final int? dailyLimitBalance;
  /// Остаток доступных средств на сегодня с учётом экономии.
  /// Формула: `availableToday − todayExpenses`.
  final int? dayBalance;
}

/// Расход по одной категории за текущий месяц.
/// Используется для отображения разбивки расходов на дашборде.
class CategorySpending {
  const CategorySpending({
    required this.name,
    required this.color,
    required this.amount,
  });

  /// Название категории.
  final String name;
  /// Цвет категории (ARGB int).
  final int color;
  /// Сумма расходов по категории за месяц.
  final int amount;
}

/// Транзакция с привязанными данными для отображения на дашборде.
class DashboardTransaction {
  const DashboardTransaction({
    required this.transaction,
    required this.accountName,
    required this.categoryName,
    required this.categoryColor,
  });

  /// Сама транзакция из базы.
  final Transaction transaction;
  /// Название счёта, с которого была операция.
  final String accountName;
  /// Название категории (может быть `null`).
  final String? categoryName;
  /// Цвет категории (может быть `null`).
  final int? categoryColor;
}

/// Платеж для отображения на дашборде.
class DashboardPayment {
  const DashboardPayment({required this.occurrence, required this.name});

  /// Конкретное выполнение recurring платежа.
  final PaymentOccurrence occurrence;
  /// Название recurring платежа.
  final String name;
}

/// Данные дашборда: статистика за месяц, последние операции и ближайшие платежи.
///
/// Используется для отображения всех секций дашборда, кроме финансового снимка.
class DashboardData {
  const DashboardData({
    required this.monthIncome,
    required this.monthExpense,
    required this.categorySpending,
    required this.recentTransactions,
    required this.remainingTransactionsThisMonth,
    required this.upcomingPayments,
  });

  /// Сумма доходов за текущий месяц.
  final int monthIncome;
  /// Сумма расходов за текущий месяц.
  final int monthExpense;
  /// Расходы по категориям, отсортированные по убыванию суммы.
  final List<CategorySpending> categorySpending;
  /// Последние 5 транзакций, отсортированные по дате (новые первыми).
  final List<DashboardTransaction> recentTransactions;
  /// Количество транзакций в этом месяце, не вошедших в [recentTransactions].
  final int remainingTransactionsThisMonth;
  /// Ближайшие 5 платежей (UPCOMING, PARTIALLY_PAID, OVERDUE).
  final List<DashboardPayment> upcomingPayments;
}

/// Полные данные дашборда на одну дату.
///
/// Объединяет финансовый снимок, статистику и справочные данные
/// (счета и категории), необходимые для UI и быстрого добавления расхода.
class DashboardDay {
  const DashboardDay({
    required this.finance,
    required this.dashboard,
    required this.accounts,
    required this.expenseCategories,
  });

  /// Финансовый снимок: сколько можно потратить.
  final FinanceSnapshot finance;
  /// Данные дашборда: статистика, операции, платежи.
  final DashboardData dashboard;
  /// Активные счета, доступные для быстрого добавления расхода.
  final List<Account> accounts;
  /// Категории расходов для выбора при добавлении расхода.
  final List<Category> expenseCategories;
}

/// Рассчитывает [FinanceSnapshot] на основе сырых финансовых данных.
///
/// Это чистая функция без побочных эффектов — все данные передаются явно.
/// Вызывается из [FinancialPlanningService.getSnapshot] после сбора данных из базы.
///
/// Алгоритм расчёта:
/// 1. **safeToSpend** = `currentBalance + expectedIncome - reservedPayments - reserve`
///    — общая сумма, доступная до зарплаты.
/// 2. **dailyLimit** (dailySafeToSpend) — дневная норма трат.
///    Если известен период цикла (periodDays), норма рассчитывается с учётом
///    фактических расходов: `(safeToSpend + expensesBeforeToday + expensesToday + unavoidable) / periodDays`.
///    Иначе: `safeToSpend / daysUntilPayday`.
/// 3. **accumulatedBalance** — «экономия» за прошедшие дни:
///    `dailyLimit × elapsedDays − expensesBeforeToday`.
/// 4. **availableToday** — сколько можно потратить сегодня с учётом экономии:
///    `dailyLimit + accumulatedBalance`.
/// 5. **dayBalance** — сколько осталось на сегодня: `availableToday − expensesToday`.
///
/// Параметры:
/// - [currentBalance] — баланс активных счетов;
/// - [expectedIncome] — ожидаемые доходы до зарплаты;
/// - [reservedPayments] — неоплаченные платежи до зарплаты;
/// - [reserve] — финансовый резерв;
/// - [nextPayday] — дата следующей зарплаты;
/// - [periodDays] — общее количество дней в текущем цикле (если известно);
/// - [elapsedDays] — дни, прошедшие с начала цикла;
/// - [expensesBeforeToday] — расходы за прошедшие дни цикла (без неизбежных);
/// - [expensesToday] — расходы за сегодня;
/// - [unavoidableExpensesInPeriod] — неизбежные расходы в цикле (не влияют на dailyLimit).
FinanceSnapshot calculateFinanceSnapshot({
  required int currentBalance,
  required int expectedIncome,
  required int reservedPayments,
  required int reserve,
  required DateTime today,
  required DateTime? nextPayday,
  int? periodDays,
  int elapsedDays = 0,
  int expensesBeforeToday = 0,
  int expensesToday = 0,
  int unavoidableExpensesInPeriod = 0,
}) {
  // Нормализуем даты — обнуляем время для корректного сравнения.
  final normalizedToday = calendarDate(today);
  final normalizedPayday = switch (nextPayday) {
    null => null,
    final date => calendarDate(date),
  };

  // Количество дней до следующей зарплаты.
  final days = normalizedPayday?.difference(normalizedToday).inDays;

  // Шаг 1: Общая сумма, доступная до зарплаты.
  // Без даты зарплаты — невозможно рассчитать.
  final safeToSpend = switch (normalizedPayday) {
    null => null,
    _ => currentBalance + expectedIncome - reservedPayments - reserve,
  };

  // Шаг 2: Дневная норма трат.
  // Если известен период цикла — учитываем фактические расходы,
  // чтобы перераспределить бюджет равномерно.
  final hasPeriod = periodDays != null && periodDays > 0;
  final periodBudget = safeToSpend == null || !hasPeriod
      ? null
      : safeToSpend +
            expensesBeforeToday +
            expensesToday +
            unavoidableExpensesInPeriod;
  final dailyLimit = safeToSpend == null || days == null || days <= 0
      ? null
      : hasPeriod
      ? (periodBudget! < 0 ? 0 : periodBudget) ~/ periodDays
      : (safeToSpend < 0 ? 0 : safeToSpend) ~/ days;

  // Шаг 3: Накопленная «экономия» за прошедшие дни цикла.
  // Положительная — тратили меньше нормы, можно потратить больше сегодня.
  // Отрицательная — превысили норму, сегодня доступная сумма уменьшится.
  final accumulatedBalance = dailyLimit == null
      ? null
      : dailyLimit * elapsedDays - expensesBeforeToday;

  // Шаг 4: Сколько можно потратить сегодня с учётом экономии.
  final availableToday = dailyLimit == null || accumulatedBalance == null
      ? null
      : dailyLimit + accumulatedBalance;
  return FinanceSnapshot(
    currentBalance: currentBalance,
    expectedIncome: expectedIncome,
    reservedPayments: reservedPayments,
    reserve: reserve,
    nextPayday: normalizedPayday,
    daysUntilPayday: days,
    safeToSpend: safeToSpend,
    dailySafeToSpend: dailyLimit,
    accumulatedBalance: accumulatedBalance,
    availableToday: availableToday,
    todayExpenses: dailyLimit == null ? null : expensesToday,
    dailyLimitBalance: dailyLimit == null ? null : dailyLimit - expensesToday,
    dayBalance: availableToday == null ? null : availableToday - expensesToday,
  );
}

/// Основной сервис финансового планирования.
///
/// Предоставляет методы для:
/// - Получение данных дашборда на любую дату (текущую и историческую);
/// - Расчёта финансового снимка ([getSnapshot]);
/// - Управления recurring платежами и их occurrences;
/// - Автооплаты платежей по расписанию;
/// - Управления расписанием доходов;
/// - Настройки резерва и даты зарплаты.
///
/// Все stream-методы ([watchDashboardDay], [watchSnapshot] и т.д.) автоматически
/// реагируют на изменения в базе данных и периодически обновляют данные.
class FinancialPlanningService {
  FinancialPlanningService(this.db);

  final AppDatabase db;

  /// Ключи настроек в таблице app_settings.
  static const _reserveKey = 'financial_reserve';
  static const _paydayKey = 'next_payday';
  static const _reserveEnabledKey = 'financial_reserve_enabled';

  /// Возвращает первую дату, с которой доступна история базы.
  Future<DateTime> getHistoryFirstAvailableDate() =>
      db.getHistoryFirstAvailableDate();

  /// Наблюдает за данными дашборда для указанной даты.
  ///
  /// При изменении любой связанной таблицы в базе автоматически
  /// пересчитывает и выдаёт новый [DashboardDay].
  /// Для текущей даты дополнительно запускает периодическое обновление
  /// каждую минуту для генерации новых occurrences.
  Stream<DashboardDay> watchDashboardDay({required DateTime date}) async* {
    final selectedDate = calendarDate(date);
    final isCurrentDate = selectedDate == calendarDate(DateTime.now());

    // Для текущей даты генерируем occurrences перед первым yield.
    if (isCurrentDate) {
      await generateOccurrences(now: selectedDate);
    }

    // Создаём stream, который реагирует на изменения во всех связанных таблицах.
    final source = db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.accounts,
            db.categories,
            db.transactions,
            db.recurringPayments,
            db.paymentOccurrences,
            db.incomeSchedules,
            db.appSettings,
            db.databaseHistoryChanges,
          },
        )
        .watch()
        .asyncMap((_) => getDashboardDay(selectedDate));

    // Для исторических дат — просто пересчёт при изменениях в базе.
    if (!isCurrentDate) {
      yield* source;
      return;
    }

    // Для текущей даты — добавляем периодическое обновление каждую минуту.
    yield* _watchWithPeriodicRefresh(
      source,
      () => generateOccurrences(now: selectedDate),
    );
  }

  /// Получает полные данные дашборда для указанной даты.
  ///
  /// Если дата — сегодня или в будущем, данные берутся из текущей базы.
  /// Если дата в прошлом — создаётся временная копия базы, восстанавливается
  /// состояние на эту дату через [_restoreStateAt], и данные рассчитываются
  /// на основе исторического состояния.
  Future<DashboardDay> getDashboardDay(DateTime date) async {
    final selectedDate = calendarDate(date);

    // Для текущей и будущих дат — используем текущую базу напрямую.
    if (!selectedDate.isBefore(calendarDate(DateTime.now()))) {
      return DashboardDay(
        finance: await getSnapshot(now: selectedDate),
        dashboard: await getDashboardData(now: selectedDate),
        accounts: await getActiveAccounts(),
        expenseCategories: await getExpenseCategories(),
      );
    }

    // Для исторических дат проверяем, доступна ли эта дата.
    final firstAvailableDate = calendarDate(
      await db.getHistoryFirstAvailableDate(),
    );
    if (selectedDate.isBefore(firstAvailableDate)) {
      throw StateError(
        'История доступна начиная с ${firstAvailableDate.toIso8601String()}.',
      );
    }

    // Создаём временную базу и восстанавливаем состояние на выбранную дату.
    final historicalDatabase = await createHistoryDatabase();
    try {
      await historicalDatabase.customSelect('SELECT 1').get();
      await _restoreStateAt(historicalDatabase, selectedDate);
      final historicalService = FinancialPlanningService(historicalDatabase);
      await historicalService.generateOccurrences(now: selectedDate);
      return DashboardDay(
        finance: await historicalService.getSnapshot(now: selectedDate),
        dashboard: await historicalService.getDashboardData(now: selectedDate),
        accounts: await historicalService.getActiveAccounts(),
        expenseCategories: await historicalService.getExpenseCategories(),
      );
    } finally {
      await historicalDatabase.close();
    }
  }

  /// Восстанавливает состояние базы на указанную дату.
  ///
  /// Алгоритм:
  /// 1. Загружает все текущие данные из каждой таблицы в память.
  /// 2. Проходит по журналу изменений (databaseHistoryChanges) в обратном порядке
  ///    от выбранной даты до настоящего времени.
  /// 3. Для каждого изменения «откатывает» данные:
  ///    - INSERT → удаляет запись (она ещё не существовала);
  ///    - SNAPSHOT → заменяет на сохранённый снимок;
  ///    - UPDATE/DELETE → восстанавливает предыдущее состояние из beforeJson.
  /// 4. Записывает восстановленные данные во временную базу.
  Future<void> _restoreStateAt(
    AppDatabase historicalDatabase,
    DateTime selectedDate,
  ) async {
    // Шаг 1: Загружаем все текущие данные в память, индексируя по ID.
    final rowsByTable = await db.transaction(() async {
      final rowsByTable = <String, Map<String, Map<String, Object?>>>{};
      for (final table in AppDatabase.historyTables.keys) {
        final rows = await db.customSelect('SELECT * FROM "$table"').get();
        rowsByTable[table] = {
          for (final row in rows)
            (row.data['id'] ?? row.data['key']).toString():
                Map<String, Object?>.from(row.data),
        };
      }

      // Шаг 2: Получаем все изменения от выбранной даты до сейчас, в обратном порядке.
      final cutoff = selectedDate
          .add(const Duration(days: 1))
          .millisecondsSinceEpoch;
      final changes =
          await (db.select(db.databaseHistoryChanges)
                ..where((row) => row.recordedAt.isBiggerOrEqualValue(cutoff))
                ..orderBy([(row) => OrderingTerm.desc(row.id)]))
              .get();

      // Шаг 3: «Откатываем» каждое изменение, восстанавливая состояние на selectedDate.
      for (final change in changes) {
        final rows = rowsByTable[change.entityTable];
        if (rows == null) {
          throw StateError(
            'Неизвестная таблица в истории базы: ${change.entityTable}.',
          );
        }
        // INSERT — запись была добавлена после selectedDate, удаляем её.
        if (change.operation == 'INSERT') {
          rows.remove(change.rowId);
          continue;
        }
        // SNAPSHOT — заменяем на сохранённый снимок состояния.
        if (change.operation == 'SNAPSHOT') {
          final snapshotJson = change.afterJson;
          if (snapshotJson == null) {
            throw StateError(
              'В истории отсутствует снимок ${change.entityTable}:${change.rowId}.',
            );
          }
          rows[change.rowId] = Map<String, Object?>.from(
            jsonDecode(snapshotJson) as Map<String, dynamic>,
          );
          continue;
        }
        // UPDATE/DELETE — восстанавливаем предыдущее состояние из beforeJson.
        final previousJson = change.beforeJson;
        if (previousJson == null ||
            (change.operation != 'UPDATE' && change.operation != 'DELETE')) {
          throw StateError(
            'Некорректное событие истории ${change.entityTable}:${change.rowId}.',
          );
        }
        rows[change.rowId] = Map<String, Object?>.from(
          jsonDecode(previousJson) as Map<String, dynamic>,
        );
      }
      return rowsByTable;
    });

    // Шаг 4: Записываем восстановленные данные во временную базу.
    // Порядок важен: сначала зависимые таблицы, потом родительские.
    await historicalDatabase.transaction(() async {
      // Очищаем все таблицы.
      for (final table in const [
        'payment_occurrences',
        'transactions',
        'recurring_payments',
        'income_schedules',
        'accounts',
        'categories',
        'app_settings',
      ]) {
        await historicalDatabase.customStatement('DELETE FROM "$table"');
      }
      // Записываем восстановленные данные в правильном порядке (родительские первыми).
      for (final table in const [
        'accounts',
        'categories',
        'recurring_payments',
        'transactions',
        'payment_occurrences',
        'income_schedules',
        'app_settings',
      ]) {
        final columns = AppDatabase.historyTables[table]!;
        for (final row in rowsByTable[table]!.values) {
          await historicalDatabase.customStatement(
            'INSERT INTO "$table" '
            '(${columns.map((column) => '"$column"').join(', ')}) '
            'VALUES (${List.filled(columns.length, '?').join(', ')})',
            columns.map((column) => row[column]).toList(),
          );
        }
      }
      await historicalDatabase
          .delete(historicalDatabase.databaseHistoryChanges)
          .go();
    });
  }

  /// Наблюдает за всеми payment occurrences с автоматической генерацией.
  Stream<List<PaymentOccurrence>> watchOccurrences() async* {
    await generateOccurrences();
    yield* _watchWithPeriodicRefresh(
      (db.select(
        db.paymentOccurrences,
      )..orderBy([(row) => OrderingTerm.asc(row.dueDate)])).watch(),
      generateOccurrences,
    );
  }

  /// Наблюдает за recurring платежами, отсортированными по имени.
  Stream<List<RecurringPayment>> watchRecurringPayments() => (db.select(
    db.recurringPayments,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).watch();

  /// Получает список recurring платежей, отсортированный по имени.
  Future<List<RecurringPayment>> getRecurringPayments() => (db.select(
    db.recurringPayments,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).get();

  /// Наблюдает за расписанием доходов, отсортированным по дате.
  Stream<List<IncomeSchedule>> watchIncomeSchedules() => (db.select(
    db.incomeSchedules,
  )..orderBy([(row) => OrderingTerm.asc(row.expectedDate)])).watch();

  /// Наблюдает за финансовым снимком с автоматическим обновлением.
  ///
  /// Реагирует на изменения в счетах, транзакциях, платежах,
  /// расписании доходов и настройках.
  Stream<FinanceSnapshot> watchSnapshot({DateTime? now}) async* {
    final today = calendarDate(now ?? DateTime.now());
    final isCurrentDate = today == calendarDate(DateTime.now());
    if (isCurrentDate) await generateOccurrences(now: today);
    final source = db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.accounts,
            db.transactions,
            db.paymentOccurrences,
            db.incomeSchedules,
            db.appSettings,
          },
        )
        .watch()
        .asyncMap((_) => getSnapshot(now: today));
    if (!isCurrentDate) {
      yield* source;
      return;
    }
    yield* _watchWithPeriodicRefresh(
      source,
      () => generateOccurrences(now: today),
    );
  }

  /// Объединяет реактивный stream с периодическим обновлением.
  ///
  /// [source] — stream, реагирующий на изменения в базе.
  /// [refresh] — функция, вызываемая каждую минуту для принудительного обновления
  /// (например, генерация новых occurrences, которые не меняют таблицы напрямую).
  Stream<T> _watchWithPeriodicRefresh<T>(
    Stream<T> source,
    Future<void> Function() refresh,
  ) {
    late final StreamController<T> controller;
    StreamSubscription<T>? subscription;
    Timer? timer;
    var refreshing = false;

    // Периодический тик: вызывает refresh() каждую минуту.
    Future<void> tick() async {
      if (refreshing) return;
      refreshing = true;
      try {
        await refresh();
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      } finally {
        refreshing = false;
      }
    }

    controller = StreamController<T>(
      onListen: () {
        // Пересылаем значения из source в controller.
        subscription = source.listen(
          controller.add,
          onError: controller.addError,
          onDone: controller.close,
        );
        // Запускаем таймер для периодического обновления.
        timer = Timer.periodic(const Duration(minutes: 1), (_) => tick());
      },
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Наблюдает за данными дашборда (статистика, операции, платежи).
  Stream<DashboardData> watchDashboardData({DateTime? now}) async* {
    yield* db
        .customSelect(
          'SELECT 1',
          readsFrom: {
            db.transactions,
            db.categories,
            db.accounts,
            db.paymentOccurrences,
            db.recurringPayments,
          },
        )
        .watch()
        .asyncMap((_) => getDashboardData(now: now));
  }

  /// Получает данные дашборда: доходы/расходы за месяц, разбивку по категориям,
  /// последние операции и ближайшие платежи.
  ///
  /// Все данные рассчитываются относительно [now] (по умолчанию — сегодня).
  Future<DashboardData> getDashboardData({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    final monthStart = DateTime(today.year, today.month);
    final nextMonth = DateTime(today.year, today.month + 1);
    final dayAfterToday = today.add(const Duration(days: 1));

    // Определяем счета, с которых нельзя снимать (no-withdrawal).
    final noWithdrawalAccountIds =
        (await (db.select(
              db.accounts,
            )..where((account) => account.isNoWithdrawal)).get())
            .map((account) => account.id)
            .toList();

    // Загружаем все транзакции текущего месяца, исключённые из статистики — пропускаем.
    // Переводы учитываются только для no-withdrawal счетов.
    final currentMonthTransactions =
        await (db.select(db.transactions)..where(
              (row) =>
                  row.transactionDate.isBiggerOrEqualValue(monthStart) &
                  row.transactionDate.isSmallerThanValue(dayAfterToday) &
                  row.transactionDate.isSmallerThanValue(nextMonth) &
                  row.isExcludedFromStatistics.equals(false) &
                  (row.type.isIn(['INCOME', 'EXPENSE']) |
                      (row.type.equals('TRANSFER') &
                          row.accountId.isIn(noWithdrawalAccountIds))),
            ))
            .get();

    // Считаем доходы, расходы и разбивку по категориям.
    var monthIncome = 0;
    var monthExpense = 0;
    final spendingByCategory = <int?, int>{};
    for (final transaction in currentMonthTransactions) {
      if (transaction.type == 'INCOME') {
        monthIncome += transaction.amount;
      } else if (transaction.type == 'EXPENSE' ||
          (transaction.type == 'TRANSFER' &&
              transaction.transferGroupId != null &&
              transaction.transferGroupId != transaction.id)) {
        monthExpense += transaction.amount;
        spendingByCategory.update(
          transaction.categoryId,
          (amount) => amount + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    // Формируем список расходов по категориям, отсортированный по убыванию.
    final categories = await db.select(db.categories).get();
    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final categorySpending = [
      for (final entry in spendingByCategory.entries)
        CategorySpending(
          name: categoryById[entry.key]?.name ?? 'Без категории',
          color: categoryById[entry.key]?.color ?? 0xFF607D8B,
          amount: entry.value,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    // Получаем последние 5 транзакций (без дубликатов переводов).
    final accounts = await db.select(db.accounts).get();
    final accountById = {for (final account in accounts) account.id: account};
    final recent =
        await (db.select(db.transactions)
              ..where(
                (row) =>
                    row.transactionDate.isSmallerThanValue(dayAfterToday) &
                    (row.type.isNotValue('TRANSFER') |
                        row.transferGroupId.equalsExp(row.id)),
              )
              ..orderBy([
                (row) => OrderingTerm.desc(row.transactionDate),
                (row) => OrderingTerm.desc(row.id),
              ])
              ..limit(5))
            .get();
    final recentTransactions = [
      for (final transaction in recent)
        DashboardTransaction(
          transaction: transaction,
          accountName: accountById[transaction.accountId]?.name ?? 'Счет',
          categoryName: categoryById[transaction.categoryId]?.name,
          categoryColor: categoryById[transaction.categoryId]?.color,
        ),
    ];
    // Считаем общее количество операций в этом месяце для показа «и ещё N».
    final operationCount = db.transactions.id.count();
    final monthOperationCount =
        await (db.selectOnly(db.transactions)
              ..addColumns([operationCount])
              ..where(
                db.transactions.transactionDate.isBiggerOrEqualValue(
                      monthStart,
                    ) &
                    db.transactions.transactionDate.isSmallerThanValue(
                      dayAfterToday,
                    ) &
                    db.transactions.transactionDate.isSmallerThanValue(
                      nextMonth,
                    ) &
                    (db.transactions.type.isNotValue('TRANSFER') |
                        db.transactions.transferGroupId.equalsExp(
                          db.transactions.id,
                        )),
              ))
            .getSingle()
            .then((row) => row.read(operationCount) ?? 0);
    final recentMonthOperationCount = recentTransactions.where((item) {
      return !item.transaction.transactionDate.isBefore(monthStart) &&
          item.transaction.transactionDate.isBefore(nextMonth);
    }).length;

    // Получаем ближайшие 5 платежей (UPCOMING, PARTIALLY_PAID, OVERDUE)
    // в диапазоне ±30 дней от сегодня.
    final payments =
        await (db.select(db.paymentOccurrences)
              ..where(
                (row) =>
                    row.status.isIn(['UPCOMING', 'PARTIALLY_PAID', 'OVERDUE']) &
                    row.dueDate.isBiggerOrEqualValue(
                      today.subtract(const Duration(days: 30)),
                    ) &
                    row.dueDate.isSmallerThanValue(
                      DateTime(today.year, today.month, today.day + 31),
                    ),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.dueDate)])
              ..limit(5))
            .get();
    final recurring = await db.select(db.recurringPayments).get();
    final paymentNames = {
      for (final payment in recurring) payment.id: payment.name,
    };
    final upcomingPayments = [
      for (final payment in payments)
        DashboardPayment(
          occurrence: payment,
          name: paymentNames[payment.recurringPaymentId] ?? 'Платеж',
        ),
    ];
    return DashboardData(
      monthIncome: monthIncome,
      monthExpense: monthExpense,
      categorySpending: categorySpending,
      recentTransactions: recentTransactions,
      remainingTransactionsThisMonth:
          monthOperationCount - recentMonthOperationCount,
      upcomingPayments: upcomingPayments,
    );
  }

  /// Рассчитывает финансовый снимок на указанную дату.
  ///
  /// Собирает данные из базы:
  /// 1. Текущий баланс активных счетов;
  /// 2. Настройки резерва и даты зарплаты;
  /// 3. Ожидаемые доходы до следующей зарплаты;
  /// 4. Неоплаченные платежи до следующей зарплаты;
  /// 5. Расходы за текущий цикл зарплаты (для расчёта accumulatedBalance).
  ///
  /// Затем вызывает [calculateFinanceSnapshot] для вычисления всех метрик.
  Future<FinanceSnapshot> getSnapshot({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    final isCurrentDate = today == calendarDate(DateTime.now());
    if (isCurrentDate) await generateOccurrences(now: today);

    // 1. Текущий баланс: сумма всех активных счетов, кроме no-withdrawal.
    final activeAccounts = await (db.select(
      db.accounts,
    )..where((account) => account.isActive)).get();
    final currentBalance = activeAccounts.fold<int>(
      0,
      (total, account) =>
          total + (account.isNoWithdrawal ? 0 : account.currentBalance),
    );

    // 2. Настройки: резерв и вручную заданная дата зарплаты.
    final settings = await db.select(db.appSettings).get();
    final settingValues = {
      for (final setting in settings) setting.key: setting.value,
    };
    final reserveEnabled = settingValues[_reserveEnabledKey] != 'false';
    final reserve = reserveEnabled
        ? int.tryParse(settingValues[_reserveKey] ?? '') ?? 0
        : 0;
    final configuredPayday = DateTime.tryParse(settingValues[_paydayKey] ?? '');

    // 3. Определяем следующую и предыдущую дату зарплаты.
    final incomes = await (db.select(
      db.incomeSchedules,
    )..where((schedule) => schedule.isActive)).get();
    final nextPayday = _resolvePayday(
      configuredPayday,
      incomes,
      today,
      settingValues,
    );
    final previousPayday = await _resolvePreviousPayday(
      incomes,
      today,
      nextPayday,
      settingValues,
    );
    // 4. Считаем ожидаемые доходы до следующей зарплаты.
    // Для каждого активного income schedule генерируем даты выплат
    // и суммируем те, что попадают в диапазон [today, nextPayday).
    var expectedIncome = 0;
    if (nextPayday != null && nextPayday.isAfter(today)) {
      for (final income in incomes) {
        var date = calendarDate(income.expectedDate);
        final frequency = parseFrequency(income.frequency);
        final paymentDay =
            int.tryParse(
              settingValues['income_schedule_${income.id}_day'] ?? '',
            ) ??
            income.expectedDate.day;
        // Пропускаем прошлые даты до сегодня.
        for (var index = 0; date.isBefore(today) && index < 600; index++) {
          final next = nextScheduledDate(
            date: date,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          date = next;
        }
        // Суммируем доходы от сегодня до следующей зарплаты.
        for (
          var index = 0;
          !date.isBefore(today) && date.isBefore(nextPayday) && index < 600;
          index++
        ) {
          expectedIncome += income.expectedAmount;
          final next = nextScheduledDate(
            date: date,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          date = next;
        }
      }
    }

    // 5. Суммируем неоплаченные платежи до следующей зарплаты.
    var reservedPayments = 0;
    if (nextPayday != null) {
      final occurrences =
          await (db.select(db.paymentOccurrences)..where(
                (occurrence) =>
                    occurrence.dueDate.isBiggerOrEqualValue(today) &
                    occurrence.dueDate.isSmallerThanValue(nextPayday),
              ))
              .get();
      for (final occurrence in occurrences) {
        // Пропускаем оплаченные и отменённые платежи.
        if (occurrence.status == 'PAID' || occurrence.status == 'CANCELLED') {
          continue;
        }
        final remaining = occurrence.expectedAmount - occurrence.paidAmount;
        if (remaining > 0) reservedPayments += remaining;
      }
    }

    // 6. Рассчитываем параметры текущего цикла зарплаты для accumulatedBalance.
    // periodDays — общее количество дней цикла, elapsedDays — прошедшие дни.
    // expensesBeforeToday — расходы за прошедшие дни (без неизбежных).
    // expensesToday — расходы за сегодня.
    int? periodDays;
    var elapsedDays = 0;
    var expensesBeforeToday = 0;  // сумма расходов (без учёта неизбежных) за прошедшие дни цикла
    var expensesToday = 0;
    var unavoidableExpensesInPeriod = 0;
    if (nextPayday != null && previousPayday != null) {
      // Начало цикла — день после предыдущей зарплаты.
      final periodStart = previousPayday.add(const Duration(days: 1));
      final totalDays = nextPayday.difference(periodStart).inDays;
      if (totalDays > 0 && !periodStart.isAfter(today)) {
        periodDays = totalDays;
        elapsedDays = today.difference(periodStart).inDays;

        // Загружаем все ручные расходы (не привязанные к автоплатежам)
        // с spendable счетов за период от начала цикла до сегодня.
        final spendableAccountIds = activeAccounts
            .where((account) => !account.isNoWithdrawal)
            .map((account) => account.id)
            .toList();
        final cycleTransactions =
            await (db.select(db.transactions)..where(
                  (transaction) =>
                      transaction.type.equals('EXPENSE') &
                      transaction.linkedPaymentOccurrenceId.isNull() &
                      transaction.accountId.isIn(spendableAccountIds) &
                      transaction.transactionDate.isBiggerOrEqualValue(
                        periodStart,
                      ) &
                      transaction.transactionDate.isSmallerThanValue(
                        today.add(const Duration(days: 1)),
                      ),
                ))
                .get();

        // Распределяем расходы по категориям:
        // - неизбежные (isUnavoidable) — идут в unavoidableExpensesInPeriod;
        // - прошедшие дни — в expensesBeforeToday;
        // - сегодня — в expensesToday.
        for (final transaction in cycleTransactions) {
          if (transaction.isUnavoidable) {
            unavoidableExpensesInPeriod += transaction.amount;
          } else if (transaction.transactionDate.isBefore(today)) {
            expensesBeforeToday += transaction.amount;
          } else {
            expensesToday += transaction.amount;
          }
        }
      }
    }

    // Передаём все собранные данные в чистую функцию расчёта.
    return calculateFinanceSnapshot(
      currentBalance: currentBalance,
      expectedIncome: expectedIncome,
      reservedPayments: reservedPayments,
      reserve: reserve,
      today: today,
      nextPayday: nextPayday,
      periodDays: periodDays,
      elapsedDays: elapsedDays,
      expensesBeforeToday: expensesBeforeToday,
      expensesToday: expensesToday,
      unavoidableExpensesInPeriod: unavoidableExpensesInPeriod,
    );
  }

  /// Определяет дату предыдущей зарплаты для расчёта периода цикла.
  ///
  /// Стратегия (по приоритету):
  /// 1. Последняя транзакция дохода с «зарплатой» в описании;
  /// 2. Предыдущая дата из income schedule с «зарплатой» в названии;
  /// 3. Фоллбэк: тот же день предыдущего месяца от nextPayday.
  Future<DateTime?> _resolvePreviousPayday(
    List<IncomeSchedule> incomes,
    DateTime today,
    DateTime? nextPayday,
    Map<String, String> settings,
  ) async {
    if (nextPayday == null) return null;

    // Стратегия 1: ищем последнюю транзакцию дохода с «зарплатой» в описании.
    final salaryTransactions =
        await (db.select(db.transactions)
              ..where(
                (transaction) =>
                    transaction.type.equals('INCOME') &
                    transaction.transactionDate.isSmallerThanValue(today),
              )
              ..orderBy([
                (transaction) => OrderingTerm.desc(transaction.transactionDate),
              ]))
            .get();
    for (final transaction in salaryTransactions) {
      if (_isSalary(transaction.description) &&
          transaction.transactionDate.isBefore(nextPayday)) {
        return calendarDate(transaction.transactionDate);
      }
    }

    // Стратегия 2: вычисляем из income schedule с «зарплатой» в названии.
    DateTime? previous;
    for (final income in incomes) {
      if (!_isSalary(income.name)) continue;
      final frequency = parseFrequency(income.frequency);
      final paymentDay =
          int.tryParse(settings['income_schedule_${income.id}_day'] ?? '') ??
          income.expectedDate.day;
      var date = calendarDate(income.expectedDate);
      if (frequency == PlanningFrequency.once) {
        if (date.isBefore(today) && date.isBefore(nextPayday)) {
          if (previous == null || date.isAfter(previous)) previous = date;
        }
        continue;
      }
      for (var index = 0; !date.isBefore(today) && index < 600; index++) {
        final preceding = previousScheduledDate(
          date: date,
          frequency: frequency,
          paymentDay: paymentDay,
        );
        if (preceding == null) break;
        date = preceding;
      }
      for (var index = 0; index < 600; index++) {
        final following = nextScheduledDate(
          date: date,
          frequency: frequency,
          paymentDay: paymentDay,
        );
        if (following == null || !following.isBefore(today)) break;
        date = following;
      }
      if (date.isBefore(today) &&
          date.isBefore(nextPayday) &&
          (previous == null || date.isAfter(previous))) {
        previous = date;
      }
    }
    if (previous != null) return previous;

    // Стратегия 3 (фоллбэк): тот же день предыдущего месяца.
    return _monthDate(nextPayday.year, nextPayday.month - 1, nextPayday.day);
  }

  /// Проверяет, содержит ли название слово «зарплата» или «salary».
  bool _isSalary(String name) {
    final normalized = name.toLowerCase();
    return normalized.contains('зарплат') || normalized.contains('salary');
  }

  /// Определяет дату следующей зарплаты.
  ///
  /// Стратегия (по приоритету):
  /// 1. Вручную заданная дата (если она в будущем);
  /// 2. Ближайшая будущая дата из income schedule с «зарплатой» в названии;
  /// 3. Вручную заданная дата, если она не в прошлом.
  DateTime? _resolvePayday(
    DateTime? configured,
    List<IncomeSchedule> incomes,
    DateTime today,
    Map<String, String> settings,
  ) {
    // Стратегия 1: вручную заданная дата зарплаты.
    if (configured != null && calendarDate(configured).isAfter(today)) {
      return calendarDate(configured);
    }

    // Стратегия 2: ближайшая будущая дата из income schedule с «зарплатой».
    DateTime? next;
    for (final income in incomes) {
      if (!income.name.toLowerCase().contains('зарплат') &&
          !income.name.toLowerCase().contains('salary')) {
        continue;
      }
      var date = calendarDate(income.expectedDate);
      final frequency = parseFrequency(income.frequency);
      final paymentDay =
          int.tryParse(settings['income_schedule_${income.id}_day'] ?? '') ??
          income.expectedDate.day;
      // Пропускаем прошлые даты до сегодня.
      for (var index = 0; date.isBefore(today) && index < 600; index++) {
        final following = nextScheduledDate(
          date: date,
          frequency: frequency,
          paymentDay: paymentDay,
        );
        if (following == null) break;
        date = following;
      }
      if (!date.isBefore(today) && (next == null || date.isBefore(next))) {
        next = date;
      }
    }

    // Стратегия 3: фоллбэк на вручную заданную дату.
    return next ??
        (configured != null && !calendarDate(configured).isBefore(today)
            ? calendarDate(configured)
            : null);
  }

  /// Устанавливает финансовый резерв.
  /// [amount] — сумма резерва в тенге, [enabled] — включён ли резерв.
  Future<void> setReserve(int amount, {required bool enabled}) async {
    if (amount < 0) throw ArgumentError.value(amount, 'amount');
    await db.transaction(() async {
      await _setSetting(_reserveKey, '$amount');
      await _setSetting(_reserveEnabledKey, '$enabled');
    });
  }

  /// Устанавливает или сбрасывает вручную заданную дату следующей зарплаты.
  Future<void> setNextPayday(DateTime? date) async {
    if (date == null) {
      await (db.delete(
        db.appSettings,
      )..where((setting) => setting.key.equals(_paydayKey))).go();
    } else {
      await _setSetting(_paydayKey, calendarDate(date).toIso8601String());
    }
  }

  /// Возвращает все настройки приложения как Map<key, value>.
  Future<Map<String, String>> getSettings() async {
    final settings = await db.select(db.appSettings).get();
    return {for (final setting in settings) setting.key: setting.value};
  }

  /// Сохраняет или обновляет одну настройку (upsert).
  Future<void> _setSetting(String key, String value) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value),
      );

  /// Создаёт новый recurring (повторяющийся) платеж.
  ///
  /// После создания автоматически генерирует payment occurrences.
  Future<void> createRecurringPayment({
    required String name,
    required int amount,
    required String frequency,
    required DateTime startDate,
    int? categoryId,
    int? accountId,
    int? paymentDay,
    bool isAutoPay = false,
    String description = '',
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await _validateRecurringCategory(categoryId);
    await _validateAutoPayAccount(accountId, isAutoPay);
    final start = calendarDate(startDate);
    await db
        .into(db.recurringPayments)
        .insert(
          RecurringPaymentsCompanion.insert(
            name: name.trim(),
            amount: amount,
            categoryId: Value(categoryId),
            accountId: Value(accountId),
            frequency: frequency,
            paymentDay: Value(paymentDay),
            startDate: start,
            isAutoPay: Value(isAutoPay),
            description: Value(description),
          ),
        );
    await generateOccurrences(now: start);
  }

  /// Обновляет существующий recurring платеж.
  ///
  /// Если платеж деактивирован ([isActive] = false), удаляет будущие UPCOMING occurrences.
  /// Если активирован заново — удаляет старые UPCOMING occurrences для регенерации.
  Future<void> updateRecurringPayment({
    required int id,
    required String name,
    required int amount,
    required String frequency,
    required DateTime startDate,
    int? categoryId,
    int? accountId,
    int? paymentDay,
    bool? isAutoPay,
    required bool isActive,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final today = calendarDate(DateTime.now());
    await db.transaction(() async {
      final existing = await (db.select(
        db.recurringPayments,
      )..where((row) => row.id.equals(id))).getSingleOrNull();
      if (existing == null) {
        throw StateError('Recurring payment $id not found.');
      }
      final autoPayEnabled = isAutoPay ?? existing.isAutoPay;
      await _validateRecurringCategory(
        categoryId,
        allowArchivedCategoryId: categoryId == existing.categoryId
            ? existing.categoryId
            : null,
      );
      await _validateAutoPayAccount(accountId, autoPayEnabled);
      await (db.update(
        db.recurringPayments,
      )..where((row) => row.id.equals(id))).write(
        RecurringPaymentsCompanion(
          name: Value(name.trim()),
          amount: Value(amount),
          categoryId: Value(categoryId),
          accountId: Value(accountId),
          frequency: Value(frequency),
          paymentDay: Value(paymentDay),
          startDate: Value(calendarDate(startDate)),
          isActive: Value(isActive),
          isAutoPay: Value(autoPayEnabled),
        ),
      );
      if (!isActive) {
        await (db.delete(db.paymentOccurrences)..where(
              (row) =>
                  row.recurringPaymentId.equals(id) &
                  row.dueDate.isBiggerOrEqualValue(today) &
                  row.status.equals('UPCOMING'),
            ))
            .go();
      } else {
        await (db.delete(db.paymentOccurrences)..where(
              (row) =>
                  row.recurringPaymentId.equals(id) &
                  row.dueDate.isBiggerOrEqualValue(today) &
                  row.status.equals('UPCOMING'),
            ))
            .go();
      }
    });
    await generateOccurrences();
  }

  /// Проверяет, что [categoryId] указывает на активную категорию расходов.
  /// Если категория архивная, разрешена только при [allowArchivedCategoryId].
  Future<void> _validateRecurringCategory(
    int? categoryId, {
    int? allowArchivedCategoryId,
  }) async {
    if (categoryId == null) return;
    final category = await (db.select(
      db.categories,
    )..where((row) => row.id.equals(categoryId))).getSingleOrNull();
    if (category == null ||
        category.type != 'EXPENSE' ||
        (category.isArchived && category.id != allowArchivedCategoryId)) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
  }

  /// Проверяет, что для автооплаты выбран активный счёт.
  Future<void> _validateAutoPayAccount(int? accountId, bool isAutoPay) async {
    if (!isAutoPay) return;
    if (accountId == null) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'Автооплата требует выбранного счета.',
      );
    }
    final account = await (db.select(
      db.accounts,
    )..where((row) => row.id.equals(accountId))).getSingleOrNull();
    if (account == null || !account.isActive) {
      throw ArgumentError.value(
        accountId,
        'accountId',
        'Для автооплаты выберите активный счет.',
      );
    }
  }

  /// Генерирует payment occurrences для всех активных recurring платежей.
  ///
  /// Алгоритм:
  /// 1. Для каждого recurring платежа вычисляет даты выплат на 12 месяцев вперёд.
  /// 2. Сравнивает с существующими occurrences и добавляет недостающие.
  /// 3. Обновляет статусы: UPCOMING → OVERDUE для просроченных.
  /// 4. Запускает автоплатежи [_processAutoPayments].
  Future<void> generateOccurrences({DateTime? now}) async {
    final today = calendarDate(now ?? DateTime.now());
    // Горизонт генерации: 12 месяцев вперёд.
    final horizon = _monthDate(today.year, today.month + 12, today.day);
    await db.transaction(() async {
      final schedules = await (db.select(
        db.recurringPayments,
      )..where((row) => row.isActive)).get();
      for (final schedule in schedules) {
        final frequency = parseFrequency(schedule.frequency);
        if (frequency == PlanningFrequency.once) continue;
        final start = calendarDate(schedule.startDate);
        final paymentDay = schedule.paymentDay ?? start.day;
        // Нижняя граница: 1 год назад — для корректной обработки просроченных.
        final lowerBound = calendarDate(
          today.subtract(const Duration(days: 365)),
        );
        var index = 0;
        var dueDate = start;
        // Быстро пропускаем даты до нижней границы.
        while (dueDate.isBefore(lowerBound) && index < 10000) {
          final next = nextScheduledDate(
            date: dueDate,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          dueDate = next;
          index++;
        }
        // Загружаем существующие occurrences, чтобы не дублировать.
        final existing =
            await (db.select(db.paymentOccurrences)..where(
                  (occurrence) =>
                      occurrence.recurringPaymentId.equals(schedule.id),
                ))
                .get();
        final knownDates = existing
            .map((item) => calendarDate(item.dueDate))
            .toSet();
        // Генерируем новые occurrences от текущей даты до горизонта.
        for (; !dueDate.isAfter(horizon) && index < 10000; index++) {
          if (schedule.endDate != null &&
              dueDate.isAfter(calendarDate(schedule.endDate!))) {
            break;
          }
          if (!dueDate.isBefore(lowerBound) && !knownDates.contains(dueDate)) {
            await db
                .into(db.paymentOccurrences)
                .insert(
                  PaymentOccurrencesCompanion.insert(
                    recurringPaymentId: schedule.id,
                    expectedAmount: schedule.amount,
                    dueDate: dueDate,
                  ),
                );
          }
          final next = nextScheduledDate(
            date: dueDate,
            frequency: frequency,
            paymentDay: paymentDay,
          );
          if (next == null) break;
          dueDate = next;
        }
      }
      // Обновляем статусы: если дата платежа прошла — ставим OVERDUE.
      final unpaidOccurrences = await (db.select(
        db.paymentOccurrences,
      )..where((row) => row.status.isIn(['UPCOMING', 'OVERDUE']))).get();
      for (final occurrence in unpaidOccurrences) {
        final status = calendarDate(occurrence.dueDate).isBefore(today)
            ? 'OVERDUE'
            : 'UPCOMING';
        if (occurrence.status != status) {
          await (db.update(db.paymentOccurrences)
                ..where((row) => row.id.equals(occurrence.id)))
              .write(PaymentOccurrencesCompanion(status: Value(status)));
        }
      }
    });
    // После генерации запускаем автоплатежи.
    await _processAutoPayments(today);
  }

  /// Автоматически оплачивает просроченные платежи с включённой автооплатой.
  ///
  /// Для каждого recurring платежа с isAutoPay = true:
  /// 1. Находит неоплаченные occurrences с датой ≤ сегодня;
  /// 2. Создаёт транзакцию расхода на оставшуюся сумму;
  /// 3. Списывает средства со счёта;
  /// 4. Обновляет статус occurrence на PAID.
  Future<void> _processAutoPayments(DateTime today) async {
    await db.transaction(() async {
      final balancesByAccountId = <int, int>{};
      final schedules = await (db.select(
        db.recurringPayments,
      )..where((row) => row.isActive & row.isAutoPay)).get();
      for (final schedule in schedules) {
        final accountId = schedule.accountId;
        if (accountId == null) {
          throw StateError(
            'Автооплата «${schedule.name}» не выполнена: не выбран счет.',
          );
        }
        final account = await (db.select(
          db.accounts,
        )..where((row) => row.id.equals(accountId))).getSingleOrNull();
        if (account == null || !account.isActive) {
          throw StateError(
            'Автооплата «${schedule.name}» не выполнена: счет не найден или неактивен.',
          );
        }
        final dueOccurrences =
            await (db.select(db.paymentOccurrences)..where(
                  (row) =>
                      row.recurringPaymentId.equals(schedule.id) &
                      row.dueDate.isSmallerOrEqualValue(today) &
                      row.status.isIn([
                        'UPCOMING',
                        'OVERDUE',
                        'PARTIALLY_PAID',
                      ]),
                ))
                .get();
        for (final occurrence in dueOccurrences) {
          final remaining = occurrence.expectedAmount - occurrence.paidAmount;
          if (remaining <= 0) continue;
          final transactionId = await db
              .into(db.transactions)
              .insert(
                TransactionsCompanion.insert(
                  accountId: account.id,
                  categoryId: Value(schedule.categoryId),
                  type: 'EXPENSE',
                  amount: remaining,
                  currency: Value(account.currency),
                  description: Value(schedule.name),
                  transactionDate: calendarDate(occurrence.dueDate),
                  linkedPaymentOccurrenceId: Value(occurrence.id),
                ),
              );
          await (db.update(
            db.accounts,
          )..where((row) => row.id.equals(account.id))).write(
            AccountsCompanion(
              currentBalance: Value(
                (balancesByAccountId[account.id] ?? account.currentBalance) -
                    remaining,
              ),
            ),
          );
          balancesByAccountId[account.id] =
              (balancesByAccountId[account.id] ?? account.currentBalance) -
              remaining;
          await (db.update(
            db.paymentOccurrences,
          )..where((row) => row.id.equals(occurrence.id))).write(
            PaymentOccurrencesCompanion(
              paidAmount: Value(occurrence.expectedAmount),
              status: const Value('PAID'),
              linkedTransactionId: Value(transactionId),
            ),
          );
        }
      }
    });
  }

  /// Обновляет ожидаемую сумму и дату одного payment occurrence.
  /// Нельзя редактировать оплаченные или отменённые платежи.
  Future<void> updateOccurrence({
    required int id,
    required int amount,
    required DateTime dueDate,
  }) async {
    final occurrence = await (db.select(
      db.paymentOccurrences,
    )..where((row) => row.id.equals(id))).getSingle();
    if (amount <= 0 || amount < occurrence.paidAmount) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Amount must be greater than or equal to the amount already paid.',
      );
    }
    if (occurrence.status == 'PAID' || occurrence.status == 'CANCELLED') {
      throw StateError('Paid or cancelled obligations cannot be edited.');
    }
    final normalizedDueDate = calendarDate(dueDate);
    final status = occurrence.paidAmount > 0
        ? 'PARTIALLY_PAID'
        : normalizedDueDate.isBefore(calendarDate(DateTime.now()))
        ? 'OVERDUE'
        : 'UPCOMING';
    await (db.update(
      db.paymentOccurrences,
    )..where((row) => row.id.equals(id))).write(
      PaymentOccurrencesCompanion(
        expectedAmount: Value(amount),
        dueDate: Value(normalizedDueDate),
        status: Value(status),
      ),
    );
  }

  /// Отменяет payment occurrence, устанавливая статус CANCELLED.
  Future<void> cancelOccurrence(int id) async {
    await (db.update(db.paymentOccurrences)..where((row) => row.id.equals(id)))
        .write(const PaymentOccurrencesCompanion(status: Value('CANCELLED')));
  }

  /// Ручная оплата payment occurrence.
  ///
  /// Создаёт транзакцию расхода, списывает средства со счёта
  /// и обновляет статус occurrence (PAID или PARTIALLY_PAID).
  Future<void> payOccurrence({
    required PaymentOccurrence occurrence,
    required int accountId,
    required int amount,
    required DateTime paidDate,
  }) async {
    await db.transaction(() async {
      final currentOccurrence = await (db.select(
        db.paymentOccurrences,
      )..where((row) => row.id.equals(occurrence.id))).getSingle();
      final remaining =
          currentOccurrence.expectedAmount - currentOccurrence.paidAmount;
      if (currentOccurrence.status == 'PAID' ||
          currentOccurrence.status == 'CANCELLED' ||
          amount <= 0 ||
          amount > remaining) {
        throw ArgumentError.value(
          amount,
          'amount',
          'Must be within the remaining amount due.',
        );
      }
      final schedule =
          await (db.select(db.recurringPayments)..where(
                (row) => row.id.equals(currentOccurrence.recurringPaymentId),
              ))
              .getSingle();
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      final totalPaid = currentOccurrence.paidAmount + amount;
      final transactionId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: Value(schedule.categoryId),
              type: 'EXPENSE',
              amount: amount,
              currency: Value(account.currency),
              description: Value(schedule.name),
              transactionDate: calendarDate(paidDate),
              linkedPaymentOccurrenceId: Value(currentOccurrence.id),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(account.currentBalance - amount),
        ),
      );
      await (db.update(
        db.paymentOccurrences,
      )..where((row) => row.id.equals(currentOccurrence.id))).write(
        PaymentOccurrencesCompanion(
          paidAmount: Value(totalPaid),
          status: Value(
            totalPaid == currentOccurrence.expectedAmount
                ? 'PAID'
                : 'PARTIALLY_PAID',
          ),
          linkedTransactionId: Value(transactionId),
        ),
      );
    });
  }

  /// Создаёт расписание ожидаемого дохода.
  ///
  /// Сохраняет день месяца в настройках для корректного расчёта
  /// следующих дат при изменении количества дней в месяце.
  Future<void> createIncomeSchedule({
    required String name,
    required int amount,
    required String frequency,
    required DateTime expectedDate,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final date = calendarDate(expectedDate);
    await db.transaction(() async {
      final id = await db
          .into(db.incomeSchedules)
          .insert(
            IncomeSchedulesCompanion.insert(
              name: name.trim(),
              expectedAmount: amount,
              frequency: frequency,
              expectedDate: date,
            ),
          );
      await _setSetting('income_schedule_${id}_day', '${date.day}');
    });
  }

  /// Обновляет расписание ожидаемого дохода.
  /// Если дата изменилась, обновляет сохранённый день месяца в настройках.
  Future<void> updateIncomeSchedule({
    required int id,
    required String name,
    required int amount,
    required String frequency,
    required DateTime expectedDate,
    required bool isActive,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    final old = await (db.select(
      db.incomeSchedules,
    )..where((row) => row.id.equals(id))).getSingle();
    final normalizedDate = calendarDate(expectedDate);
    await db.transaction(() async {
      await (db.update(
        db.incomeSchedules,
      )..where((row) => row.id.equals(id))).write(
        IncomeSchedulesCompanion(
          name: Value(name.trim()),
          expectedAmount: Value(amount),
          frequency: Value(frequency),
          expectedDate: Value(normalizedDate),
          isActive: Value(isActive),
        ),
      );
      if (old.expectedDate != normalizedDate) {
        await _setSetting('income_schedule_${id}_day', '${normalizedDate.day}');
      }
    });
  }

  /// Фиксирует получение ожидаемого дохода.
  ///
  /// 1. Создаёт транзакцию дохода;
  /// 2. Начисляет средства на счёт;
  /// 3. Сдвигает expectedDate на следующую дату по расписанию;
  /// 4. Если следующая дата отсутствует (разовый доход) — деактивирует schedule.
  Future<void> receiveIncome({
    required IncomeSchedule schedule,
    required int accountId,
    required DateTime receivedDate,
  }) async {
    await db.transaction(() async {
      final currentSchedule = await (db.select(
        db.incomeSchedules,
      )..where((row) => row.id.equals(schedule.id))).getSingle();
      if (!currentSchedule.isActive ||
          calendarDate(currentSchedule.expectedDate) !=
              calendarDate(schedule.expectedDate)) {
        throw StateError(
          'This expected income has already been received or changed.',
        );
      }
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      final transactionId = await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              type: 'INCOME',
              amount: currentSchedule.expectedAmount,
              currency: Value(account.currency),
              description: Value(currentSchedule.name),
              transactionDate: calendarDate(receivedDate),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(
            account.currentBalance + currentSchedule.expectedAmount,
          ),
        ),
      );
      final settings = await getSettings();
      final paymentDay =
          int.tryParse(
            settings['income_schedule_${currentSchedule.id}_day'] ?? '',
          ) ??
          currentSchedule.expectedDate.day;
      final nextDate = nextScheduledDate(
        date: currentSchedule.expectedDate,
        frequency: parseFrequency(currentSchedule.frequency),
        paymentDay: paymentDay,
      );
      await (db.update(
        db.incomeSchedules,
      )..where((row) => row.id.equals(currentSchedule.id))).write(
        IncomeSchedulesCompanion(
          expectedDate: Value(nextDate ?? currentSchedule.expectedDate),
          isActive: Value(nextDate != null),
          linkedTransactionId: Value(transactionId),
        ),
      );
    });
  }

  /// Возвращает список активных счетов, отсортированный по имени.
  Future<List<Account>> getActiveAccounts() =>
      (db.select(db.accounts)
            ..where((account) => account.isActive)
            ..orderBy([(account) => OrderingTerm.asc(account.name)]))
          .get();

  /// Возвращает список неархивных категорий расходов, отсортированный по имени.
  Future<List<Category>> getExpenseCategories() =>
      (db.select(db.categories)
            ..where(
              (category) =>
                  category.type.equals('EXPENSE') &
                  category.isArchived.equals(false),
            )
            ..orderBy([(category) => OrderingTerm.asc(category.name)]))
          .get();

  /// Добавляет ручной расход: создаёт транзакцию и списывает средства со счёта.
  ///
  /// [date] — дата расхода (по умолчанию — сегодня).
  Future<void> addManualExpense({
    required int accountId,
    required int amount,
    required String description,
    int? categoryId,
    DateTime? date,
  }) async {
    if (amount <= 0) throw ArgumentError.value(amount, 'amount');
    await db.transaction(() async {
      final account = await (db.select(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).getSingle();
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              accountId: accountId,
              categoryId: Value(categoryId),
              type: 'EXPENSE',
              amount: amount,
              currency: Value(account.currency),
              description: Value(description.trim()),
              transactionDate: calendarDate(date ?? DateTime.now()),
            ),
          );
      await (db.update(
        db.accounts,
      )..where((row) => row.id.equals(accountId))).write(
        AccountsCompanion(
          currentBalance: Value(account.currentBalance - amount),
        ),
      );
    });
  }
}
