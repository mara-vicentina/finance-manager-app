import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/reports_screen.dart';

void main() {
  testWidgets('ReportsScreen renders report UI components', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ReportsScreen()));

    expect(find.text('Relatórios'), findsOneWidget);
    expect(find.byIcon(Icons.download), findsOneWidget);
    expect(find.byType(Card), findsWidgets);
  });
}
