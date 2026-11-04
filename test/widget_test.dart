// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:survive_till_payday/app/app.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';

void main() {
  testWidgets('dashboard date button opens a calendar and updates the day', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const PaydayApp(),
      ),
    );
    await tester.pumpAndSettle();

    final previousDate = DateTime.now().subtract(const Duration(days: 1));
    await database
        .update(database.databaseHistoryMetadata)
        .write(
          DatabaseHistoryMetadataCompanion(
            firstAvailableDate: Value(
              DateTime(
                previousDate.year,
                previousDate.month,
                previousDate.day,
              ).millisecondsSinceEpoch,
            ),
          ),
        );
    await tester.tap(find.byTooltip('Выбрать дату'));
    await tester.pumpAndSettle();
    expect(find.byType(CalendarDatePicker), findsOneWidget);

    if (previousDate.month != DateTime.now().month) {
      await tester.tap(find.byTooltip('Предыдущий месяц'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('${previousDate.day}').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ОК'));
    await tester.pumpAndSettle();

    expect(
      find.text(DateFormat('EEEE, d MMMM', 'ru').format(previousDate)),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('Payday dashboard opens with financial planning sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) {
            final database = AppDatabase(NativeDatabase.memory());
            ref.onDispose(database.close);
            return database;
          }),
        ],
        child: const PaydayApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Укажите дату зарплаты'), findsOneWidget);
    expect(find.text('Обзор'), findsWidgets);
    final dashboardScroll = find.descendant(
      of: find.byType(ListView).first,
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(
      find.text('Ближайшие платежи'),
      400,
      scrollable: dashboardScroll,
    );
    expect(find.text('Ближайшие платежи'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Последние операции'),
      400,
      scrollable: dashboardScroll,
    );
    expect(find.text('Последние операции'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
  });
}
