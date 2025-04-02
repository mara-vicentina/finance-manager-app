import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../lib/services/transaction_service.dart';

import 'transaction_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;
  late TransactionService service;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    service = TransactionService(client: mockClient, storage: mockStorage);
  });

  group('TransactionService', () {
    test('createTransaction returns 200 on success', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'fake_token');
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'message': 'success'}), 200));

      final result = await service.createTransaction(
        type: 0,
        description: 'Compra',
        value: '100.00',
        transactionDate: '2024-01-01',
        category: 1,
        paymentMethod: 2,
        paymentStatus: 1,
      );

      expect(result['statusCode'], 200);
      expect(result['data']['message'], 'success');
    });

    test('createTransaction returns 401 if no token', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

      final result = await service.createTransaction(
        type: 0,
        description: 'Teste',
        value: '10.00',
        transactionDate: '2024-01-01',
        category: 1,
        paymentMethod: 1,
        paymentStatus: 1,
      );

      expect(result['statusCode'], 401);
      expect(result['data']['message'], contains('Token'));
    });

    test('deleteTransaction returns 200 on success', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'token');
      when(mockClient.delete(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'message': 'ok'}), 200));

      final result = await service.deleteTransaction(1);

      expect(result['statusCode'], 200);
      expect(result['data']['message'], 'ok');
    });

    test('getDashboardSummary returns data', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'token');
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'success': true, 'data': []}), 200));

      final result = await service.getDashboardSummary();

      expect(result['statusCode'], 200);
      expect(result['data']['success'], true);
    });
  });
}
