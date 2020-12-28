import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request =
    "https://api.hgbrasil.com/finance?format=json-cors&key=738db436";
void main() async {
  runApp(MaterialApp(
      theme: ThemeData(hintColor: Colors.black, primaryColor: Colors.black),
      home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final dolarcController = TextEditingController();

  double dolar;
  double dolarc;

  void _realChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    dolarcController.text = (real / dolarc).toStringAsFixed(2);
  }

  void _dolarChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    dolarcController.text = (dolar * this.dolar / dolarc).toStringAsFixed(2);
  }

  void _dolarcChange(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolarc = double.parse(text);
    realController.text = (dolarc * this.dolarc).toStringAsFixed(2);
    dolarController.text = (dolarc * this.dolarc / dolar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    dolarcController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Conversor Moeda",
            style: TextStyle(
                fontSize: 35.0,
                fontStyle: FontStyle.italic,
                color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando Dados",
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.center),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar Dados",
                      style: TextStyle(fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  dolarc = snapshot.data["results"]["currencies"]["CAD"]["buy"];
                  return SingleChildScrollView(
                      padding: EdgeInsets.all(10.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Icon(Icons.monetization_on,
                                size: 150.0, color: Colors.amber),
                            buildTextField(
                                "Reais", "R\$", realController, _realChange),
                            Divider(),
                            buildTextField(
                                "Dolar", "\$", dolarController, _dolarChange),
                            Divider(),
                            buildTextField("Dolar Canadense", "C\$",
                                dolarcController, _dolarcChange),
                          ]));
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController c, Function f) {
  return TextField(
    controller: c,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontSize: 25.0),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.black),
    onChanged: f,
    keyboardType: TextInputType.numberWithOptions(decimal: true)
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}
