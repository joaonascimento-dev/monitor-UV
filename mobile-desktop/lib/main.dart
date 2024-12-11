import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const UVMonitoringApp());
}

class UVMonitoringApp extends StatelessWidget {
  const UVMonitoringApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monitoramento UV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const UVHomePage(),
    );
  }
}

class UVHomePage extends StatefulWidget {
  const UVHomePage({Key? key}) : super(key: key);

  @override
  State<UVHomePage> createState() => _UVHomePageState();
}

class _UVHomePageState extends State<UVHomePage> {
  double uvLevel = 0.0;
  String uvStatus = "Carregando...";
  String lastUpdate = "";
  final String apiUrl =
      "https://[codigo].execute-api.us-east-1.amazonaws.com/default/funcaoMonitorUV";

  @override
  void initState() {
    super.initState();
    fetchUVData();
  }

  Future<void> fetchUVData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          setState(() {
            uvLevel = double.parse(data['level'].toString());
            uvStatus = data['status'];
            lastUpdate = data['lastUpdate'];
          });
        }
      } else {
        throw Exception('Erro ao carregar dados');
      }
    } catch (e) {
      setState(() {
        uvStatus = "Erro ao carregar dados";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: const Text('Monitoramento UV - Itapira'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Nível Atual de Radiação UV',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      uvLevel.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: uvLevel >= 6
                            ? Colors.red
                            : uvLevel >= 3
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      uvStatus,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Última atualização: $lastUpdate',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: fetchUVData,
                child: const Text('Atualizar Dados'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
