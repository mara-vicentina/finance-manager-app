
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/screens/profile.dart';

void main() {
  testWidgets('ProfileScreen renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: ProfileScreen()));

    expect(find.text('Meus Dados'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Editar'), findsOneWidget);
  });
}
