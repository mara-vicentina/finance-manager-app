import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/list_transactions.dart';
import 'screens/profile.dart';
import 'dart:io';
import 'package:flutter/services.dart';

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
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ListTransactionsScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

 void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sair do App"),
        content: Text("Tem certeza que deseja sair?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop(); // Fecha o app no Android
              } else {
                exit(0); // Fecha o app no iOS e Android
              }
            },
            child: Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 4) {
            _confirmExit(context);
          } else {
            _onItemTapped(index);
          }
        },
        selectedItemColor: Color(0xFF2E3E84),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transações'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Relórios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app,), label: 'Sair'),
        ],
      ),
    );
  }
}
