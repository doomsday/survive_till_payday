import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';
import 'package:survive_till_payday/features/planning/presentation/payments_page.dart';

void main() {
  testWidgets('a recurring payment can be assigned an expense category', (
    tester,
  ) async {
    late AppDatabase database;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            database = AppDatabase(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const MaterialApp(home: PaymentsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Добавить платеж'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Покупки');
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(find.byType(TextField).last, '15000');

    final categoryDropdown = find.byType(DropdownButtonFormField<int?>);
    await tester.ensureVisible(categoryDropdown);
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Автомобиль'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();

    expect(find.text('Покупки'), findsOneWidget);
    final payment =
        (await database.select(database.recurringPayments).get()).single;
    final category = await (database.select(
      database.categories,
    )..where((row) => row.id.equals(payment.categoryId!))).getSingle();
    expect(category.name, 'Автомобиль');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
