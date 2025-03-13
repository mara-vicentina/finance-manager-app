import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'add_transaction.dart';

class ListTransactionsScreen extends StatefulWidget {
  @override
  _ListTransactionsScreenState createState() => _ListTransactionsScreenState();
}

class _ListTransactionsScreenState extends State<ListTransactionsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _formattedStartDate;
  String? _formattedEndDate;

  final List<Map<String, dynamic>> _transactions = [];

  // Mapa de categorias para exibição correta
  final Map<int, String> _categoryMap = {
    1: "Alimentação",
    2: "Transporte",
    3: "Lazer",
    4: "Educação",
    5: "Saúde",
  };

  void _openAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(),
      ),
    );
  }

  Future<void> getTransaction() async {
    if (_formattedStartDate == null || _formattedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione as datas antes de buscar!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api/transactions';

    String? token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Token de autenticação não encontrado!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Uri uri = Uri.parse(baseUrl).replace(queryParameters: {
      'start_date': _formattedStartDate!,
      'end_date': _formattedEndDate!,
    });

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        // Verifica se a requisição foi bem-sucedida e se há dados
        if (responseData["success"] == true && responseData["data"] is List) {
          setState(() {
            _transactions.clear();
            for (var transaction in responseData["data"]) {
              _transactions.add({
                'tipo': transaction['type'], // Atualizado para 'type'
                'valor': double.tryParse(transaction['value'].toString()) ?? 0.0, // Garante que o valor seja um double
                'categoria': transaction['category'], // Mantém como número
                'data': transaction['transaction_date'], // Atualizado para 'transaction_date'
                'descricao': transaction['description'], // Adiciona a descrição
                'metodo_pagamento': transaction['payment_method'], // Guarda o método de pagamento
                'status_pagamento': transaction['payment_status'], // Guarda o status do pagamento
              });
            }
          });
        } else {
          print('Erro na resposta da API: ${responseData["message"] ?? "Erro desconhecido"}');
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer a requisição: $e');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF2E3E84),
            colorScheme: ColorScheme.light(primary: Color(0xFF2E3E84)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
          _formattedStartDate = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
          _formattedEndDate = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'images/logo.png',
              height: 70,
            ),

            Expanded(
              child: Center(
                child: Text(
                  "Últimas Transações",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            IconButton(
              icon: Icon(Icons.settings, color: Colors.white), // Ícone de configurações (pode trocar)
              onPressed: () {
                // Adicione a ação desejada aqui
              },
            ),
          ],
        ),
        backgroundColor: Color(0xFF25316C),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _startDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context, true),
                    decoration: InputDecoration(
                      labelText: 'Data de Início',
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: _endDateController,
                    readOnly: true,
                    onTap: () => _selectDate(context, false),
                    decoration: InputDecoration(
                      labelText: 'Data de Finalização',
                      prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),

                ElevatedButton(
                  onPressed: () async {
                    await getTransaction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E3E84),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text("Buscar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: _transactions.isEmpty
                  ? Center(child: Text("Nenhuma transação registrada!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];

                        // Converte tipo de 0/1 para Entrada/Saída
                        bool isEntrada = transaction["tipo"] == 0;
                        Color cardColor = isEntrada ? Colors.green : Colors.red;

                        // Obtém a descrição da categoria
                        String categoria = _categoryMap[transaction["categoria"]] ?? "Outros";

                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cardColor,
                              child: Icon(isEntrada ? Icons.arrow_upward : Icons.arrow_downward, color: Colors.white),
                            ),
                            title: Text("${transaction["data"]} - $categoria"),
                            trailing: Text(
                              "R\$ ${transaction["valor"].toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardColor),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2E3E84),
        onPressed: _openAddTransactionScreen,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
