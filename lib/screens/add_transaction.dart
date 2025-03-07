import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  final Function(String, double, String, DateTime) onAddTransaction;

  AddTransactionScreen({required this.onAddTransaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String _selectedCategory = 'Alimentação';
  String _selectedStatusPayment = 'Pago';
  String _selectedPaymentMethod = 'Dinheiro';
  DateTime _selectedDate = DateTime.now();

  void _submitData() {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text) ?? 0;

    if (enteredTitle.isEmpty || enteredAmount <= 0) {
      return;
    }

    widget.onAddTransaction(enteredTitle, enteredAmount, _selectedCategory, _selectedDate);
    Navigator.of(context).pop();
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
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
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
                    /// Tipo da Transação
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: 'Tipo da Transação',
                        prefixIcon: Icon(Icons.swap_horiz, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Valor da Transação
                    TextField(
                      controller: _amountController,
                      cursorColor: Color(0xFF2E3E84),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Valor (R\$)',
                        prefixIcon: Icon(Icons.attach_money, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Categoria
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                        });
                      },
                      items: ['Alimentação', 'Transporte', 'Lazer', 'Saúde', 'Outros']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(Icons.category, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Data da Transação
                    TextField(
                      controller: _dateController,
                      cursorColor: Color(0xFF2E3E84),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'Data da Transação',
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Descrição
                    TextField(
                      controller: _titleController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Forma de Pagamento
                    DropdownButtonFormField<String>(
                      value: _selectedPaymentMethod,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaymentMethod = newValue!;
                        });
                      },
                      items: ['Dinheiro', 'Cartão de Crédito', 'Cartão de Débito', 'PIX', 'Outros']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Forma de Pagamento',
                        prefixIcon: Icon(Icons.payment, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Status do Pagamento
                    DropdownButtonFormField<String>(
                      value: _selectedStatusPayment,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStatusPayment = newValue!;
                        });
                      },
                      items: ['Pago', 'Pendente', 'Parcelado', 'Outros']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      decoration: InputDecoration(
                        labelText: 'Status do Pagamento',
                        prefixIcon: Icon(Icons.check_circle, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 20),

                    /// Botão Salvar
                    ElevatedButton(
                      onPressed: _submitData,
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
