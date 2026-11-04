import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_provider.dart';
import '../../core/database/app_database.dart';
import 'domain/financial_planning_service.dart';

final financialPlanningServiceProvider = Provider<FinancialPlanningService>((
  ref,
) {
  return FinancialPlanningService(ref.watch(databaseProvider));
});

final financeSnapshotProvider = StreamProvider<FinanceSnapshot>((ref) {
  return ref.watch(financialPlanningServiceProvider).watchSnapshot();
});

final dashboardDataProvider = StreamProvider<DashboardData>((ref) {
  return ref.watch(financialPlanningServiceProvider).watchDashboardData();
});

final dashboardDayAtDateProvider = StreamProvider.autoDispose
    .family<DashboardDay, DateTime>((ref, date) {
      return ref
          .watch(financialPlanningServiceProvider)
          .watchDashboardDay(date: date);
    });

final paymentOccurrencesProvider = StreamProvider<List<PaymentOccurrence>>(
  (ref) => ref.watch(financialPlanningServiceProvider).watchOccurrences(),
);

final recurringPaymentsProvider = StreamProvider<List<RecurringPayment>>(
  (ref) => ref.watch(financialPlanningServiceProvider).watchRecurringPayments(),
);

final incomeSchedulesProvider = StreamProvider<List<IncomeSchedule>>(
  (ref) => ref.watch(financialPlanningServiceProvider).watchIncomeSchedules(),
);
