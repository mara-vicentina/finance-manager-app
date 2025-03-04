import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/add_transaction.dart';

Map<int, Color> colorSwatch = {
  50: Color(0xFFE0E3F1),
  100: Color(0xFFB3B8DD),
  200: Color(0xFF808CC7),
  300: Color(0xFF4D60B0),
  400: Color(0xFF2E3E84),
  500: Color(0xFF25316C),
  600: Color(0xFF1D2553),
  700: Color(0xFF161A3A),
  800: Color(0xFF0E0F22),
  900: Color(0xFF07070B),
};

MaterialColor customPrimarySwatch = MaterialColor(0xFF2E3E84, colorSwatch);


void main() {
  runApp(FinanceManagerApp());
}

class FinanceManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
         primarySwatch: customPrimarySwatch,
      ),
      home: LoginScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _transactions = [];

  void _addNewTransaction(String title, double amount, String category, DateTime date) {
    setState(() {
      _transactions.add({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
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
      appBar: AppBar(title: Text('Finance Manager')),
      body: Column(
        children: [
          
          Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Saldo Total',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'R\$ ${_transactions.fold<double>(0.0, (sum, item) => sum + (item['amount'] as double)).toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
          ),

          
          Expanded(
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final tx = _transactions[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 3,
                  child: ListTile(
                    leading: Icon(Icons.money, color: Colors.blue),
                    title: Text(tx['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${tx['category']} - ${tx['date'].day}/${tx['date'].month}/${tx['date'].year}'),
                    trailing: Text(
                      'R\$ ${tx['amount'].toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransactionScreen,
        child: Icon(Icons.add),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Análises'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
        ],
      ),
    );
  }
}
