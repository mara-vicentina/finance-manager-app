import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;

  Future<void> loginUser() async {
    final result = await _authService.login(
      _emailController.text,
      _passwordController.text,
    );

    final responseData = result['data'];
    final statusCode = result['statusCode'];

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login bem-sucedido!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF2E3E84),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha no login: ${responseData['message']}', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> checkUserLogin() async {
    String? token = await _secureStorage.read(key: 'auth_token');
    if (token != null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    }
  }

  @override
  void initState() {
    super.initState();
    checkUserLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/finance.png',
                  width: 230,
                  height: 230,
                ),
                SizedBox(height: 5),

                TextField(
                  controller: _emailController,
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.email, color: Color(0xFF2E3E84)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E3E84)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility, 
                        color: Color(0xFF2E3E84),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
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
                  onPressed: loginUser,
                  child: Text('Entrar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E3E84),
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text('Criar uma conta'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Color(0xFF2E3E84)),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
