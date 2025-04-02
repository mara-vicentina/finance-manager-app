import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'add_transaction.dart';
import 'edit_transaction.dart';
import '../services/transaction_service.dart';

class ListTransactionsScreen extends StatefulWidget {
  final VoidCallback? onTransactionChanged;

  ListTransactionsScreen({this.onTransactionChanged});
  
  @override
  _ListTransactionsScreenState createState() => _ListTransactionsScreenState();
}

class _ListTransactionsScreenState extends State<ListTransactionsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final TransactionService _transactionService = TransactionService();
  int _selectedType = 0;
  int _selectedCategory = 1;

  String? _formattedStartDate;
  String? _formattedEndDate;
  bool _moreFilters = false;

  final List<Map<String, dynamic>> _transactions = [];

  final Map<int, String> _categoryMap = {
    1: "Receitas",
    2: "Despesas",
    3: "Investimentos",
    4: "Adicionais",
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
      widget.onTransactionChanged?.call(); 
      getTransaction();
    }
  }

  Future<void> getTransaction() async {
    if (_formattedStartDate == null || _formattedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecione as datas antes de buscar!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await _transactionService.getTransactions(
      startDate: _formattedStartDate!,
      endDate: _formattedEndDate!,
      type: _moreFilters ? _selectedType : null,
      category: _moreFilters ? _selectedCategory : null,
    );

    final statusCode = result['statusCode'];
    final responseData = result['data'];

    if (statusCode == 200 && responseData['success'] == true && responseData['data'] is List) {
      setState(() {
        _transactions.clear();
        for (var transaction in responseData["data"]) {
          String originalDate = transaction['transaction_date'];
          String formattedDate = "";
          try {
            DateTime parsedDate = DateTime.parse(originalDate);
            formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
          } catch (_) {
            formattedDate = originalDate;
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
      print('Erro ao carregar transações: ${responseData["message"] ?? "Erro desconhecido"}');
    }
  }

  Future<void> _deleteTransaction(int transactionId) async {
    final result = await _transactionService.deleteTransaction(transactionId);
    final statusCode = result['statusCode'];
    final responseData = result['data'];

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transação removida com sucesso!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF2E3E84),
        ),
      );
      widget.onTransactionChanged?.call();
      await getTransaction();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover a transação: ${responseData['message'] ?? "Erro desconhecido"}', style: TextStyle(color: Colors.white)),
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
        automaticallyImplyLeading: false,
        title: Text("Últimas Transações", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E3E84),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Filtros",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      TextField(
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
                      SizedBox(height: 16),
                      TextField(
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
                      SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
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
                      if (_moreFilters) ...[
                        SizedBox(height: 10),
                        DropdownButtonFormField<int>(
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
                        SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedCategory,
                          onChanged: (newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                          items: _categoryMap.entries
                              .map((entry) => DropdownMenuItem(
                                    value: entry.key,
                                    child: Text(entry.value),
                                  ))
                              .toList(),
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
                      ],
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (_transactions.isEmpty)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "Nenhuma transação registrada!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                )
              else
                Column(
                  children: _transactions.map((transaction) {
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
                        title: Text(
                          categoria,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(transaction["data"]),
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
                                      builder: (context) => EditTransactionScreen(transaction: transaction),
                                    ),
                                  );

                                  if (updatedTransaction != null) {
                                    widget.onTransactionChanged?.call();
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
                                PopupMenuItem(value: 'edit', child: Text("Editar")),
                                PopupMenuItem(value: 'delete', child: Text("Remover")),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 36),

            ],
          ),
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
