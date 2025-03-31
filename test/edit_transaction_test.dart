
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/edit_transaction.dart';

void main() {
  testWidgets('EditTransactionScreen displays with prefilled data', (WidgetTester tester) async {
    final transaction = {
      'id': 1,
      'descricao': 'Teste',
      'valor': 123.45,
      'tipo': 0,
      'categoria': 1,
      'status_pagamento': 1,
      'metodo_pagamento': 1,
      'data': '01-01-2023'
    };

    await tester.pumpWidget(MaterialApp(home: EditTransactionScreen(transaction: transaction)));

    expect(find.text('Editar Transação'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.byType(DropdownButtonFormField<int>), findsNWidgets(4));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
  });
}
