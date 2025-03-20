import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  String? _formattedDate;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  Future<void> createUser() async {
    final String url = 'https://goldenrod-badger-186312.hostingersite.com/api/user';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _passwordConfirmationController.text,
        'birth_date': _formattedDate,
      }),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Usuário registrado com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF2E3E84),
        ),
      );

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
    } else {
      String errorMessage = responseData['message'] ?? 'Erro ao criar conta';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Criar Conta", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E3E84),
        iconTheme: IconThemeData(color: Colors.white),
      ),
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
                  controller: _nameController,
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.person, color: Color(0xFF2E3E84)),
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
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    labelText: 'Data de Nascimento',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
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
                SizedBox(height: 10),

                TextField(
                  controller: _passwordConfirmationController,
                  obscureText: _obscurePasswordConfirmation,
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E3E84)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePasswordConfirmation ? Icons.visibility_off : Icons.visibility, 
                        color: Color(0xFF2E3E84),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
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
                  onPressed: createUser,
                  child: Text('Criar Conta'),
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
                    Navigator.pop(context);
                  },
                  child: Text('Já tem uma conta? Entrar'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Color(0xFF2E3E84)),
                    textStyle: MaterialStateProperty.all(
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    overlayColor: MaterialStateProperty.all(Colors.transparent), // Remove o efeito de hover
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
