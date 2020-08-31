import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

//const apiURL = "https://api.hgbrasil.com/finance";
const apiURL = "https://api.hgbrasil.com/finance?format=json&key=b0a8d1be";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.teal,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          hintStyle: TextStyle(color: Colors.teal),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // controllers
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  // variables
  double _dolar = 0.0;
  double _euro = 0.0;

  // events
  void _resetForm() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void _realChanged(String text) {
    if(text.isEmpty) {
      _resetForm();
      return;
    }

    double real = double.parse(text);
    dolarController.text = (real/_dolar).toStringAsFixed(2);
    euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    if(text.isEmpty) {
      _resetForm();
      return;
    }

    double dolar = double.parse(text);
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    euroController.text = (dolar * this._dolar / _euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    if(text.isEmpty) {
      _resetForm();
      return;
    }

    double euro = double.parse(text);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = (euro * this._euro / _dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Conversor de Moedas",
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
        ),
        body: Stack(children: <Widget>[
          Image.asset(
            "images/bg_money.jpeg",
            fit: BoxFit.cover,
            width: 1000.0,
            height: 1000.0,
          ),
          FutureBuilder<Map>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text(
                    "Buscando dados...",
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ));
                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(
                      "Erro ao buscar dados",
                      style: TextStyle(color: Colors.red, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ));
                  }

                  _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.teal),
                        buildTextField("Reais", "R\$", realController, _realChanged),
                        Divider(),
                        buildTextField("Dólar", "US\$", dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euro", "€", euroController, _euroChanged)
                      ],
                    ),
                  );
              }
            },
          ),
        ]),
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response responseAPI = await http.get(apiURL);
  return json.decode(responseAPI.body);
}

Widget buildTextField(String label, String currency, TextEditingController controller, Function function) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.teal),
        border: OutlineInputBorder(),
        prefixText: currency),
    style: TextStyle(color: Colors.teal, fontSize: 25.0),
    onChanged: function,
  );
}
