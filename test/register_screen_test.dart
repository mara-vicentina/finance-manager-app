import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/register_screen.dart';

void main() {
  testWidgets('RegisterScreen shows all input fields and register button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: RegisterScreen()));

    expect(find.byType(TextField), findsNWidgets(5));
    expect(find.widgetWithText(ElevatedButton, 'Criar Conta'), findsOneWidget);
    expect(find.text('Já tem uma conta? Entrar'), findsOneWidget);
  });
}