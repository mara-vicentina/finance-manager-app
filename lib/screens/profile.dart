import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'login_screen.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final MaskedTextController _cpfController = MaskedTextController(mask: '000.000.000-00');
  final MaskedTextController _cepController = MaskedTextController(mask: '00000-000');
  final MaskedTextController _phoneController = MaskedTextController(mask: '(00) 00000-0000');
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final UserService _userService = UserService();

  bool _updatePassword = false;
  String? _formattedDate;
  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;

  String _cleanText(String text) {
    return text.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    final data = await _userService.getUserData();

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados do usuário!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _nameController.text = data['name'] ?? '';
      _cpfController.text = data['cpf'] ?? '';
      _cepController.text = data['cep'] ?? '';
      _phoneController.text = data['phone_number'] ?? '';
      _emailController.text = data['email'] ?? '';
      _addressController.text = data['address'] ?? '';
      if (data['birth_date'] != null) {
        _formattedDate = data['birth_date'];
        _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.parse(data['birth_date']));
      }
    });
  }

  Future<void> editUser() async {
    Map<String, dynamic> body = {
      'name': _nameController.text,
      'cpf': _cleanText(_cpfController.text),
      'cep': _cleanText(_cepController.text),
      'address': _addressController.text,
      'phone_number': _cleanText(_phoneController.text),
      'birth_date': _formattedDate,
    };

    if (_updatePassword) {
      body['password'] = _passwordController.text;
      body['password_confirmation'] = _passwordConfirmationController.text;
    }

    final result = await _userService.updateUser(body);
    final responseData = result['data'];
    final statusCode = result['statusCode'];

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário editado com sucesso!', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF2E3E84),
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
    } else {
      String errorMessage = responseData['message'] ?? 'Erro ao editar usuário';
      if (responseData['errors'] is List) {
        errorMessage += "\n" + (responseData['errors'] as List).join("\n");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> deleteUser() async {
    final result = await _userService.deleteUser();
    final statusCode = result['statusCode'];
    final responseData = result['data'];

    if (statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta excluída com sucesso!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ),
      );

      await _secureStorage.deleteAll();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      String errorMessage = responseData['message'] ?? 'Erro ao excluir a conta';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmar Exclusão"),
          content: Text("Tem certeza de que deseja excluir sua conta? Essa ação não pode ser desfeita."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteUser();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,),
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
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
        automaticallyImplyLeading: false,
        title: Text("Meus Dados", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E3E84),
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
                    TextField(
                      controller: _nameController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "Nome",
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
                      controller: _cpfController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "CPF",
                        labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                        prefixIcon: Icon(Icons.badge, color: Color(0xFF2E3E84)),
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
                      controller: _cepController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "CEP",
                        labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                        prefixIcon: Icon(Icons.location_on, color: Color(0xFF2E3E84)),
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
                      controller: _addressController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "Endereço Completo",
                        labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                        prefixIcon: Icon(Icons.home, color: Color(0xFF2E3E84)),
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
                      controller: _phoneController,
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "Telefone",
                        labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                        prefixIcon: Icon(Icons.phone, color: Color(0xFF2E3E84)),
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
                      readOnly: true,
                      cursorColor: Color(0xFF2E3E84),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[300],
                        labelText: "Email",
                        labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                        prefixIcon: Icon(Icons.email, color: Colors.grey),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        Checkbox(
                          value: _updatePassword,
                          activeColor: Color(0xFF2E3E84),
                          onChanged: (value) {
                            setState(() {
                              _updatePassword = value!;
                            });
                          },
                        ),
                        Text("Atualizar senha"),
                      ],
                    ),

                    if (_updatePassword) ...[
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        cursorColor: Color(0xFF2E3E84),
                        decoration: InputDecoration(
                          labelText: "Senha",
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
                          labelText: "Confirmar Senha",
                          labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2E3E84)),
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
                    ],
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: editUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3E84),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Editar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),

                    TextButton(
                      onPressed: _confirmDeleteAccount,
                      child: Text("Excluir minha conta"),
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
        ),
      ),
    );
  }
}
