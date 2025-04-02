import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../lib/services/user_service.dart';

import 'user_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;
  late UserService userService;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    userService = UserService(client: mockClient, storage: mockStorage);
  });

  group('UserService', () {
    test('registerUser deve retornar status 201 e dados de sucesso', () async {
      final responseMock = {
        'message': 'Usuário criado com sucesso!',
        'user_id': 1,
      };

      when(mockClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(responseMock), 201));

      final result = await userService.registerUser(
        name: 'Mara Vicentina',
        email: 'mara@example.com',
        password: '123456',
        passwordConfirmation: '123456',
        birthDate: '1990-01-01',
      );

      expect(result['statusCode'], 201);
      expect(result['data']['message'], 'Usuário criado com sucesso!');
    });

    test('getUserData deve retornar dados do usuário quando token e ID forem válidos', () async {
      final fakeUser = {'name': 'Mara', 'email': 'mara@example.com'};

      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'token123');
      when(mockStorage.read(key: 'user_id')).thenAnswer((_) async => '1');
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'data': fakeUser}), 200));

      final userData = await userService.getUserData();

      expect(userData, isNotNull);
      expect(userData!['name'], 'Mara');
    });

    test('updateUser deve retornar status 200 quando atualização for bem-sucedida', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'token123');
      when(mockStorage.read(key: 'user_id')).thenAnswer((_) async => '1');

      final updatedData = {'message': 'Atualizado com sucesso!'};

      when(mockClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode(updatedData), 200));

      final result = await userService.updateUser({'name': 'João'});

      expect(result['statusCode'], 200);
      expect(result['data']['message'], 'Atualizado com sucesso!');
    });

    test('deleteUser deve retornar status 200 ao deletar usuário', () async {
      when(mockStorage.read(key: 'auth_token')).thenAnswer((_) async => 'token123');
      when(mockStorage.read(key: 'user_id')).thenAnswer((_) async => '1');

      final deleteResponse = {'message': 'Conta removida com sucesso'};

      when(mockClient.delete(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(deleteResponse), 200));

      final result = await userService.deleteUser();

      expect(result['statusCode'], 200);
      expect(result['data']['message'], contains('removida'));
    });
  });
}
