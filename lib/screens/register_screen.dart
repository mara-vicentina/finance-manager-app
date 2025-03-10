import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _dateController = TextEditingController();

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
      appBar: AppBar(title: Text('Criar Conta')),
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
                  'images/finance.png',
                  width: 230, 
                  height: 230, 
                ),
                SizedBox(height: 5),

                TextField(
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
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E3E84)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 10),

                TextField(
                  cursorColor: Color(0xFF2E3E84),
                  decoration: InputDecoration(
                    labelText: 'Confirmar Senha',
                    labelStyle: TextStyle(color: Color(0xFF2E3E84)),
                    prefixIcon: Icon(Icons.lock, color: Color(0xFF2E3E84)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {},
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
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF2E3E84),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
