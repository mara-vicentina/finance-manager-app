import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

class ReportService {
  final String _baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api';
  final FlutterSecureStorage _storage;
  final http.Client client;

  ReportService({FlutterSecureStorage? storage, http.Client? client})
      : _storage = storage ?? const FlutterSecureStorage(),
        client = client ?? http.Client();

  Future<Map<String, dynamic>> getMonthlyReport() async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final response = await client.get(
      Uri.parse('$_baseUrl/report/monthly-transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    final responseData = jsonDecode(response.body);
    return {
      'statusCode': response.statusCode,
      'data': responseData,
    };
  }

  Future<Map<String, dynamic>> downloadExcelReport({
    required String startDate,
    required String endDate,
  }) async {
    String? token = await _storage.read(key: 'auth_token');
    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final uri = Uri.parse('$_baseUrl/export/transactions').replace(queryParameters: {
      'start_date': startDate,
      'end_date': endDate,
    });

    final response = await client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/relatorio.xlsx";
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return {'statusCode': 200, 'filePath': filePath};
    } else {
      final errorData = jsonDecode(response.body);
      return {'statusCode': response.statusCode, 'data': errorData};
    }
  }
}
