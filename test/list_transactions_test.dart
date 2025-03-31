import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/list_transactions.dart';

void main() {
  testWidgets('ListTransactionsScreen displays filter section and floating button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ListTransactionsScreen()));

    expect(find.text('Últimas Transações'), findsOneWidget);
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}