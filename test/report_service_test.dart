import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../lib/services/report_service.dart';

import 'report_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;
  late ReportService reportService;
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    reportService = ReportService(client: mockClient, storage: mockStorage);
  });

  group('getMonthlyReport', () {
    test('retorna dados corretamente quando status 200', () async {
      final fakeResponse = {
        'success': true,
        'data': [
          {'month': '01-2024', 'incomes': '1000', 'expenses': '500', 'total': '500'}
        ]
      };

      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'fake_token');
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(jsonEncode(fakeResponse), 200));

      final result = await reportService.getMonthlyReport();

      expect(result['statusCode'], 200);
      expect(result['data']['success'], true);
      expect(result['data']['data'], isA<List>());
    });

    test('retorna erro 401 se token não encontrado', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => null);

      final result = await reportService.getMonthlyReport();

      expect(result['statusCode'], 401);
      expect(result['data']['message'], contains('Token'));
    });
  });
}
