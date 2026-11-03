// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:survive_till_payday/app/app.dart';
import 'package:survive_till_payday/core/database/app_database.dart';
import 'package:survive_till_payday/core/database/database_provider.dart';

void main() {
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
