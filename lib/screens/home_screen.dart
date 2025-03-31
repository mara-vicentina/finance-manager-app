import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<bool> refreshNotifier;

  HomeScreen({Key? key, required this.refreshNotifier}) : super(key: key);
  
  @override
  _HomeScreenState createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  double saldoAtual = 0.0;
  String? mesAtual;
  List<Map<String, dynamic>> resumoCategorias = [];

  final Map<int, String> _categoryMap = {
    1: "Receitas",
    2: "Despesas",
    3: "Investimentos",
    4: "Adicionais",
    5: "Outros",
  };

  final Map<int, Color> _categoryColors = {
    1: Colors.blue,
    2: Colors.green,
    3: Colors.purple,
    4: Colors.orange,
    5: Colors.pink,
  };

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    mesAtual = DateFormat('MM-yyyy').format(now);
    getData();

    widget.refreshNotifier.addListener(() {
      getData();
    });
  }

  Future<void> getData() async {
    String baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api/dashboard';

    String? token = await _secureStorage.read(key: 'auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: Token de autenticação não encontrado!', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);

        if (responseData["success"] == true) {
          setState(() {
            saldoAtual = double.tryParse(responseData["data"]["generalSum"].toString()) ?? 0.0;
            resumoCategorias = List<Map<String, dynamic>>.from(responseData["data"]["sumCategories"]);
          });
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer a requisição: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Início", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Color(0xFF2E3E84),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text("Saldo Atual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(
                        "R\$ ${saldoAtual.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: saldoAtual < 0 ? Colors.red : Colors.green, // Altera a cor com base no saldo
                        ),
                      ),
                      Divider(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Distribuição de Gastos por Categoria",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(5),
                        height: 350,
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 0,
                                  sections: resumoCategorias.map((categoriaData) {
                                    int categoriaId = int.tryParse(categoriaData["category"].toString()) ?? 5;
                                    double valor = double.tryParse(categoriaData["sum"].toString()) ?? 0.0;
                                    double total = resumoCategorias.fold(0, (sum, item) => sum + (double.tryParse(item["sum"].toString())?.abs() ?? 0.0));
                                    double percentual = (valor.abs() / total) * 100;

                                    return PieChartSectionData(
                                      color: _categoryColors[categoriaId] ?? Colors.grey,
                                      value: valor.abs(),
                                      title: "${percentual.toStringAsFixed(1)}%", 
                                      radius: 80,
                                      titleStyle: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            SizedBox(height: 10),

                            Wrap(
                              direction: Axis.vertical,
                              spacing: 8,
                              children: resumoCategorias.map((categoriaData) {
                                int categoriaId = int.tryParse(categoriaData["category"].toString()) ?? 5;
                                double valor = double.tryParse(categoriaData["sum"].toString()) ?? 0.0;
                                double total = resumoCategorias.fold(0, (sum, item) => sum + (double.tryParse(item["sum"].toString())?.abs() ?? 0.0));
                                double percentual = (valor.abs() / total) * 100;

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _categoryColors[categoriaId] ?? Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      "${_categoryMap[categoriaId] ?? "Outros"} (${percentual.toStringAsFixed(1)}%)",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: Text("Gastos por Categoria no Mês Atual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              SizedBox(height: 10),

              Column(
                children: resumoCategorias.map((categoriaData) {
                  int categoriaId = categoriaData["category"];
                  double valor = double.tryParse(categoriaData["sum"].toString()) ?? 0.0;

                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.category, color: _categoryColors[categoriaId] ?? Colors.grey,),
                      ),
                      title: Text(
                        _categoryMap[categoriaId] ?? "Outros",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(mesAtual ?? "--"),
                      trailing: Text(
                        "R\$ ${valor.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _categoryColors[categoriaId] ?? Colors.grey,),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),

              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "“Poupar hoje é investir no seu futuro. Pequenas economias constroem grandes conquistas!”",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

}
