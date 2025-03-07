import 'package:flutter/material.dart';
import 'add_transaction.dart';

class ListTransactionsScreen extends StatefulWidget {
  @override
  _ListTransactionsScreenState createState() => _ListTransactionsScreenState();
}

class _ListTransactionsScreenState extends State<ListTransactionsScreen> {
  final List<Map<String, dynamic>> _transactions = [
    {"tipo": "Entrada", "valor": 500.00, "categoria": "Freelancer", "data": "10/03"},
    {"tipo": "Saída", "valor": 200.00, "categoria": "Alimentação", "data": "09/03"},
    {"tipo": "Saída", "valor": 150.00, "categoria": "Transporte", "data": "08/03"},
    {"tipo": "Entrada", "valor": 1200.00, "categoria": "Salário", "data": "05/03"},
    {"tipo": "Saída", "valor": 300.00, "categoria": "Compras", "data": "04/03"},
  ];

  void _addNewTransaction(String title, double amount, String category, DateTime date) {
    setState(() {
      _transactions.add({
        'tipo': title,
        'valor': amount,
        'categoria': category,
        'data': "${date.day}/${date.month}/${date.year}",
      });
    });
  }

  void _openAddTransactionScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          onAddTransaction: _addNewTransaction,
        ),
      ),
    );
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
            if (_transactions.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    "Nenhuma transação registrada!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    bool isEntrada = transaction["tipo"] == "Entrada";
                    Color cardColor = isEntrada ? Colors.green : Colors.red;
                    Color iconColor = isEntrada ? Colors.green : Colors.red;

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
                          "${transaction["data"]} - ${transaction["categoria"]}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          "R\$ ${transaction["valor"].toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: iconColor,
                          ),
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
