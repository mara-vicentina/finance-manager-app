
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/add_transaction.dart';

void main() {
  testWidgets('AddTransactionScreen displays all fields and save button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddTransactionScreen()));

    expect(find.text('Nova Transação'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(4));
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Salvar'), findsOneWidget);
  });
}
