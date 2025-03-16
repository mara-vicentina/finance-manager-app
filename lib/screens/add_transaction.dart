import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.isEmpty) {
      return TextEditingValue(
        text: "0.00",
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    double value = double.parse(newText) / 100;

    String formattedValue = value.toStringAsFixed(2);

    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}

class AddTransactionScreen extends StatefulWidget {

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int _selectedType = 0;
  int _selectedCategory = 1;
  int _selectedStatusPayment = 1;
  int _selectedPaymentMethod = 1;
  DateTime _selectedDate = DateTime.now();

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _formattedDate;

  Future<void> createTransaction() async {
    final String url = 'https://goldenrod-badger-186312.hostingersite.com/api/transaction';

    String? token = await _secureStorage.read(key: 'auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro: Token de autenticação não encontrado!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'type': _selectedType,
        'description': _titleController.text,
        'value': _parseDouble(_amountController.text),
        'transaction_date': _formattedDate,
        'category': _selectedCategory,
        'payment_method': _selectedPaymentMethod,
        'payment_status': _selectedStatusPayment,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transação registrada com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF2E3E84),
        ),
      );

      Navigator.pop(context, true);
    } else {
      String errorMessage = responseData['message'] ?? 'Erro ao criar transação';

      if (responseData.containsKey('errors') && responseData['errors'] is List) {
        errorMessage += "\n" + responseData['errors'].join("\n");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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
        _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
        _formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  String _parseDouble(String value) {
    try {
      double parsedValue = double.parse(value.replaceAll(',', '.'));
      return parsedValue.toStringAsFixed(2);
    } catch (e) {
      return "0.00";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nova Transação", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E3E84),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    SizedBox(height: 10),

                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()], 
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$)',
                        prefixIcon: Icon(Icons.attach_money, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    DropdownButtonFormField<int>(
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
                    SizedBox(height: 10),

                    TextField(
                      controller: _dateController,
                      cursorColor: Color(0xFF2E3E84),
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'Data da Transação',
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: _titleController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      value: _selectedPaymentMethod,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 1, child: Text("Dinheiro")),
                        DropdownMenuItem(value: 2, child: Text("Cartão de Crédito")),
                        DropdownMenuItem(value: 3, child: Text("Cartão de Débito")),
                        DropdownMenuItem(value: 4, child: Text("Pix")),
                        DropdownMenuItem(value: 5, child: Text("Outros")),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Forma de Pagamento',
                        prefixIcon: Icon(Icons.payment, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    DropdownButtonFormField<int>(
                      value: _selectedStatusPayment,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatusPayment = newValue!;
                        });
                      },
                      items: [
                        DropdownMenuItem(value: 1, child: Text("Pago")),
                        DropdownMenuItem(value: 2, child: Text("Pendente")),
                        DropdownMenuItem(value: 3, child: Text("Parcelado")),
                        DropdownMenuItem(value: 4, child: Text("Outros")),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Status do Pagamento',
                        prefixIcon: Icon(Icons.check_circle, color: Color(0xFF2E3E84)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: createTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3E84),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Salvar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
