import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../lib/services/auth_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  group('AuthService', () {
    late MockClient mockClient;
    late MockFlutterSecureStorage mockStorage;
    late AuthService authService;

    setUp(() {
      mockClient = MockClient();
      mockStorage = MockFlutterSecureStorage();
      authService = AuthService(client: mockClient, storage: mockStorage);
    });

    test('login retorna token e user_id ao receber status 200', () async {
      final email = 'test@example.com';
      final password = 'password123';

      final fakeResponse = {
        'access_token': 'fake_token',
        'user_id': 42,
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(fakeResponse), 200));

      final result = await authService.login(email, password);

      expect(result['statusCode'], 200);
      expect(result['data']['access_token'], 'fake_token');

      verify(mockStorage.write(key: 'auth_token', value: 'fake_token')).called(1);
      verify(mockStorage.write(key: 'user_id', value: '42')).called(1);
    });

    test('login retorna erro se status != 200', () async {
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(jsonEncode({'message': 'Invalid credentials'}), 401));

      final result = await authService.login('wrong@example.com', 'wrongpass');

      expect(result['statusCode'], 401);
      expect(result['data']['message'], 'Invalid credentials');

      verifyNever(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')));
    });
  });
}
