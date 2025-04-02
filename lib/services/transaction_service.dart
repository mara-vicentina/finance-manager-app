import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TransactionService {
  final http.Client client;
  final FlutterSecureStorage storage;
  final String _baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api';

  TransactionService({http.Client? client, FlutterSecureStorage? storage})
      : client = client ?? http.Client(),
        storage = storage ?? const FlutterSecureStorage();

  Future<Map<String, dynamic>> createTransaction({
    required int type,
    required String description,
    required String value,
    required String? transactionDate,
    required int category,
    required int paymentMethod,
    required int paymentStatus,
  }) async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final response = await client.post(
      Uri.parse('$_baseUrl/transaction'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': type,
        'description': description,
        'value': value,
        'transaction_date': transactionDate,
        'category': category,
        'payment_method': paymentMethod,
        'payment_status': paymentStatus,
      }),
    );

    final responseData = jsonDecode(response.body);
    return {
      'statusCode': response.statusCode,
      'data': responseData,
    };
  }

  Future<Map<String, dynamic>> updateTransaction({
    required int transactionId,
    required int type,
    required String description,
    required String value,
    required String transactionDate,
    required int category,
    required int paymentMethod,
    required int paymentStatus,
  }) async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final response = await client.put(
      Uri.parse('$_baseUrl/transaction/$transactionId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "type": type,
        "transaction_date": transactionDate,
        "value": value,
        "category": category,
        "description": description,
        "payment_method": paymentMethod,
        "payment_status": paymentStatus,
      }),
    );

    final responseData = jsonDecode(response.body);
    return {
      'statusCode': response.statusCode,
      'data': responseData,
    };
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final response = await client.get(
      Uri.parse('$_baseUrl/dashboard'),
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

  Future<Map<String, dynamic>> getTransactions({
    required String startDate,
    required String endDate,
    int? type,
    int? category,
  }) async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final Map<String, String> queryParams = {
      'start_date': startDate,
      'end_date': endDate,
    };

    if (type != null) queryParams['type'] = type.toString();
    if (category != null) queryParams['category'] = category.toString();

    final uri = Uri.parse('$_baseUrl/transactions').replace(queryParameters: queryParams);

    final response = await client.get(
      uri,
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

  Future<Map<String, dynamic>> deleteTransaction(int transactionId) async {
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return {
        'statusCode': 401,
        'data': {'message': 'Token de autenticação não encontrado!'}
      };
    }

    final response = await client.delete(
      Uri.parse('$_baseUrl/transaction/$transactionId'),
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
}
