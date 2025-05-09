import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String _baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api';
  final FlutterSecureStorage storage;
  final http.Client client;

  UserService({http.Client? client, FlutterSecureStorage? storage})
      : client = client ?? http.Client(),
        storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String? birthDate,
  }) async {
    final response = await client.post(
      Uri.parse('$_baseUrl/user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'birth_date': birthDate,
      }),
    );

    final responseData = jsonDecode(response.body);
    return {'statusCode': response.statusCode, 'data': responseData};
  }

  Future<Map<String, dynamic>?> getUserData() async {
    String? token = await storage.read(key: 'auth_token');
    String? userId = await storage.read(key: 'user_id');
    if (token == null || userId == null) return null;

    final response = await client.get(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>> updateUser(Map<String, dynamic> body) async {
    String? token = await storage.read(key: 'auth_token');
    String? userId = await storage.read(key: 'user_id');

    final response = await client.put(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    final responseData = jsonDecode(response.body);
    return {'statusCode': response.statusCode, 'data': responseData};
  }

  Future<Map<String, dynamic>> deleteUser() async {
    String? token = await storage.read(key: 'auth_token');
    String? userId = await storage.read(key: 'user_id');

    final response = await client.delete(
      Uri.parse('$_baseUrl/user/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final responseData = jsonDecode(response.body);
    return {'statusCode': response.statusCode, 'data': responseData};
  }
}