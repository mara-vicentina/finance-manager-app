import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final _storage = FlutterSecureStorage();
  final String _baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _storage.write(key: 'auth_token', value: responseData['access_token']);
      await _storage.write(key: 'user_id', value: responseData['user_id'].toString());
    }

    return {
      'statusCode': response.statusCode,
      'data': responseData,
    };
  }
}