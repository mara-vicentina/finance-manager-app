import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'add_transaction.dart';
import 'edit_transaction.dart';

class ListTransactionsScreen extends StatefulWidget {
  @override
  _ListTransactionsScreenState createState() => _ListTransactionsScreenState();
}

class _ListTransactionsScreenState extends State<ListTransactionsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  int _selectedType = 0;
  int _selectedCategory = 1;

  String? _formattedStartDate;
  String? _formattedEndDate;
  bool _moreFilters = false;

  final List<Map<String, dynamic>> _transactions = [];

  final Map<int, String> _categoryMap = {
    1: "Alimentação",
    2: "Transporte",
    3: "Lazer",
    4: "Saúde",
    5: "Outros",
  };

  @override
  void initState() {
    super.initState();
    
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    _startDateController.text = DateFormat('dd-MM-yyyy').format(oneMonthAgo);
    _endDateController.text = DateFormat('dd-MM-yyyy').format(now);

    _formattedStartDate = DateFormat('yyyy-MM-dd').format(oneMonthAgo);
    _formattedEndDate = DateFormat('yyyy-MM-dd').format(now);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getTransaction();
    });
  }

  void _openAddTransactionScreen() async {
    final bool? transactionAdded = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(),
      ),
    );

    if (transactionAdded == true) {
      getTransaction();
    }
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

    Map<String, String> queryParams = {
      'start_date': _formattedStartDate!,
      'end_date': _formattedEndDate!,
    };

    if (_moreFilters) {
      queryParams['type'] = _selectedType.toString();
      queryParams['category'] = _selectedCategory.toString();
    }

    Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData["success"] == true && responseData["data"] is List) {
          setState(() {
            _transactions.clear();
            for (var transaction in responseData["data"]) {
              String originalDate = transaction['transaction_date'];
              String formattedDate = "";
            
              if (originalDate.isNotEmpty) {
                try {
                  DateTime parsedDate = DateTime.parse(originalDate);
                  formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
                } catch (e) {
                  print("Erro ao formatar a data: $e");
                  formattedDate = originalDate;
                }
              }

              _transactions.add({
                'id': transaction['id'], 
                'tipo': transaction['type'], 
                'valor': double.tryParse(transaction['value'].toString()) ?? 0.0, 
                'categoria': transaction['category'], 
                'data': formattedDate, 
                'descricao': transaction['description'], 
                'metodo_pagamento': transaction['payment_method'], 
                'status_pagamento': transaction['payment_status'], 
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

  Future<void> _deleteTransaction(int transactionId) async {
    String url = 'https://goldenrod-badger-186312.hostingersite.com/api/transaction/$transactionId';

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

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transação removida com sucesso!', style: TextStyle(color: Colors.white)),
            backgroundColor: Color(0xFF2E3E84),
          ),
        );

        await getTransaction();
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover a transação: ${responseData['message']}', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao conectar ao servidor: $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
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
              icon: Icon(Icons.settings, color: Colors.white),
              onPressed: () {
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

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await getTransaction();
                    },
                    icon: Icon(Icons.search, color: Colors.white),
                    label: Text("Buscar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E3E84),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _moreFilters,
                  activeColor: Color(0xFF2E3E84),
                  onChanged: (value) {
                    setState(() {
                      _moreFilters = value!;
                    });
                  },
                ),
                Text("Exibir mais filtros"),
              ],
            ),
            SizedBox(height: 10),

            if (_moreFilters) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _selectedType,
                      onChanged: (int? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 0, child: Text("Entrada")),
                        DropdownMenuItem(value: 1, child: Text("Saída")),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Tipo da Transação',
                        prefixIcon: Icon(Icons.category, color: Color(0xFF2E3E84)),
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
                    child: DropdownButtonFormField<int>(
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 1, child: Text("Alimentação")),
                        DropdownMenuItem(value: 2, child: Text("Transporte")),
                        DropdownMenuItem(value: 3, child: Text("Lazer")),
                        DropdownMenuItem(value: 4, child: Text("Saúde")),
                        DropdownMenuItem(value: 5, child: Text("Outros")),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 118,
                  ),
                ],
              ),
            ],
            SizedBox(height: 10),

            Expanded(
              child: _transactions.isEmpty
                ? Center(
                    child: Text(
                      "Nenhuma transação registrada!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];

                    bool isEntrada = transaction["tipo"] == 0;
                    Color cardColor = isEntrada ? Colors.green : Colors.red;

                    String categoria = _categoryMap[transaction["categoria"]] ?? "Outros";

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: cardColor,
                          child: Icon(
                            isEntrada ? Icons.arrow_upward : Icons.arrow_downward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text("$categoria", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),),
                        subtitle: Text("${transaction["data"]}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "R\$ ${transaction["valor"].toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cardColor),
                            ),
                            SizedBox(width: 10), 
                            PopupMenuButton<String>(
                              offset: Offset(0, 40),
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  final updatedTransaction = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditTransactionScreen(transaction: {
                                        'id': transaction['id'],
                                        'tipo': transaction['tipo'],
                                        'valor': transaction['valor'].toStringAsFixed(2),
                                        'categoria': transaction['categoria'],
                                        'data': transaction['data'],
                                        'descricao': transaction['descricao'],
                                        'metodo_pagamento': transaction['metodo_pagamento'],
                                        'status_pagamento': transaction['status_pagamento'],
                                      }),
                                    ),
                                  );

                                  if (updatedTransaction != null) {
                                    await getTransaction();
                                    setState(() {});
                                  }
                                } else if (value == 'delete') {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Remover Transação"),
                                      content: Text("Tem certeza que deseja remover esta transação?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: Text("Cancelar"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: Text("Remover", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete) {
                                     await _deleteTransaction(transaction['id']);
                                  }
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Color(0xFF2E3E84)),
                                      SizedBox(width: 8),
                                      Text("Editar"),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text("Remover"),
                                    ],
                                  ),
                                ),
                              ],
                              icon: Icon(Icons.more_vert),
                            ),
                          ]
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
