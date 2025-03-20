import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
        primaryColor: Color(0xFF2E3E84),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF2E3E84),
          secondary: Color(0xFF2E3E84),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Color(0xFF2E3E84),
          selectionColor: Color(0xFF2E3E84).withOpacity(0.5),
          selectionHandleColor: Color(0xFF2E3E84),
        ),
      ),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
   late Key _homeScreenKey;
  late List<Widget> _screens;


  @override
  void initState() {
    super.initState();
    _homeScreenKey = UniqueKey(); // Inicializa a Key corretamente
    _screens = [
      HomeScreen(key: _homeScreenKey),
      ListTransactionsScreen(),
      ReportsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
       if (index == 0) {
        _homeScreenKey = UniqueKey(); // Gera uma nova Key para recriar a HomeScreen
        _screens[0] = HomeScreen(key: _homeScreenKey);
      }
      _selectedIndex = index;
    });
  }

  Future<void> logoutUser(BuildContext context) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Sair da Conta"),
        content: Text("Tem certeza que deseja sair da sua conta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _secureStorage.delete(key: 'auth_token');

              Navigator.of(ctx).pop();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,),
            child: Text("Sair"),
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
            logoutUser(context);
          } else {
            _onItemTapped(index);
          }
        },
        selectedItemColor: Color(0xFF2E3E84),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transações'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'Relatórios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'Sair'),
        ],
      ),
    );
  }
}
