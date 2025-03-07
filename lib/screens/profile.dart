import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
                  "Meus Dados",
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
                    /// Nome
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "Nome",
                        prefixIcon: Icon(Icons.person, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// CPF
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "CPF",
                        prefixIcon: Icon(Icons.badge, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// CEP
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "CEP",
                        prefixIcon: Icon(Icons.location_on, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Endereço
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      decoration: InputDecoration(
                        labelText: "Endereço Completo",
                        prefixIcon: Icon(Icons.home, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Data de Nascimento
                    TextField(
                      controller: _dateController,
                      cursorColor: Color(0xFF2E3E84),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        labelText: 'Data de Nascimento',
                        prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Email
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Senha
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Senha",
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// Confirmar Senha
                    TextField(
                      cursorColor: Color(0xFF2E3E84),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Confirmar Senha",
                        prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2E3E84)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    SizedBox(height: 20),

                    /// Botão Editar
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2E3E84),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text("Editar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
