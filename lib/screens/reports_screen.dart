import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  String? _formattedStartDate;
  String? _formattedEndDate;
  List<Map<String, dynamic>> monthlyData = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    String baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api/report/monthly-transactions';

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
            monthlyData = List<Map<String, dynamic>>.from(responseData["data"]);
          });
        }
      } else {
        print('Erro na requisição: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao fazer a requisição: $e');
    }
  }

  /// Converte os valores String em double
  double _parseValue(String value) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }

  Future<void> downloadExcel() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (_formattedStartDate == null || _formattedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, selecione as datas antes de buscar!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String baseUrl = 'https://goldenrod-badger-186312.hostingersite.com/api/export/transactions';

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

    Map<String, String> queryParams = {
      'start_date': _formattedStartDate!,
      'end_date': _formattedEndDate!,
    };

    Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        // Obtém o diretório para salvar o arquivo
        final directory = await getApplicationDocumentsDirectory();
        final filePath = "${directory.path}/relatorio.xlsx";

        // Salva o arquivo localmente
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Abre o arquivo
        OpenFilex.open(filePath);
      } else {
        print("Erro ao baixar o relatório: ${response.statusCode}");
      }
    } catch (e) {
      print("Erro: $e");
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
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
        if (isStart) {
          _startDateController.text = DateFormat('dd-MM-yyyy').format(picked);
          _formattedStartDate = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _endDateController.text = DateFormat('dd-MM-yyyy').format(picked);
          _formattedEndDate = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Relatórios", style: TextStyle(color: Colors.white)),
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
                      Text(
                        "Relatório por Período",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      TextField(
                        controller: _startDateController,
                        onTap: () => _selectDate(context, true),
                        decoration: InputDecoration(
                          labelText: 'Data de Início',
                          prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _endDateController,
                        onTap: () => _selectDate(context, false),
                        decoration: InputDecoration(
                          labelText: 'Data de Finalização',
                          prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF2E3E84)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3E84), width: 2.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF2E3E84), width: 1.5),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await downloadExcel();
                          },
                          icon: Icon(Icons.download, color: Colors.white),
                          label: Text("Download", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E3E84),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),


              /// **Gráfico de Barras**
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Transações Mensais",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                           padding: EdgeInsets.all(5),
                          width: 600, // Define uma largura fixa para o gráfico
                          height: 300, // Mantém a altura do gráfico fixa
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 2000,
                              barGroups: monthlyData.asMap().entries.map((entry) {
                                int index = entry.key;
                                var data = entry.value;
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    /// Receita (Incomes)
                                    BarChartRodData(
                                      toY: _parseValue(data["incomes"]),
                                      color: Colors.green,
                                      width: 12,
                                    ),
                                    /// Despesas (Expenses)
                                    BarChartRodData(
                                      toY: _parseValue(data["expenses"]),
                                      color: Colors.red,
                                      width: 12,
                                    ),
                                    /// Total
                                    BarChartRodData(
                                      toY: _parseValue(data["total"]),
                                      color: Colors.blue,
                                      width: 12,
                                    ),
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false,),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 && value.toInt() < monthlyData.length) {
                                        return Padding(
                                          padding: EdgeInsets.only(top: 5),
                                          child: Text(
                                            monthlyData[value.toInt()]["month"],
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        );
                                      }
                                      return Container();
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              gridData: FlGridData(show: true),
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      "R\$ ${rod.toY.toStringAsFixed(2)}",
                                      TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10), // Espaço entre gráfico e legenda

                      /// **Legenda do Gráfico**
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildLegend(Colors.green, "Receitas"),
                          _buildLegend(Colors.red, "Despesas"),
                          _buildLegend(Colors.blue, "Total"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20), // Adiciona espaço final para evitar corte ao rolar
            ],
          ),
        ),
      ),
    );
  }

}
