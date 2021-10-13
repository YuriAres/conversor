import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() async {
  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        textSelectionTheme:
            TextSelectionThemeData(cursorColor: Colors.purpleAccent),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.purple)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.purpleAccent)),
          hintStyle: TextStyle(color: Colors.purpleAccent),
        )),
  ));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late double dolar;
  late double euro;

  final TextEditingController RealController = new TextEditingController();
  final TextEditingController DolarController = new TextEditingController();
  final TextEditingController EuroController = new TextEditingController();

  apagarCampos() {
    RealController.text = "";
    DolarController.text = "";
    EuroController.text = "";
  }

  converterReal(String text) {
    if (text.isEmpty) {
      DolarController.text = "";
      EuroController.text = "";
    } else {
      double real = double.parse(text);
      DolarController.text = (real / this.dolar).toStringAsFixed(2);
      EuroController.text = (real / this.euro).toStringAsFixed(2);
    }
  }

  converterDolar(String text) {
    if (text.isEmpty) {
      RealController.text = "";
      EuroController.text = "";
    } else {
      double dolar = double.parse(text);
      RealController.text = (dolar * this.dolar).toStringAsFixed(2);
      EuroController.text =
          ((dolar * this.dolar) / this.euro).toStringAsFixed(2);
    }
  }

  converterEuro(String text) {
    if (text.isEmpty) {
      RealController.text = "";
      DolarController.text = "";
    } else {
      double euro = double.parse(text);
      DolarController.text =
          ((euro * this.euro) / this.dolar).toStringAsFixed(2);
      RealController.text = (euro * this.euro).toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(actions: [
          IconButton(onPressed: apagarCampos, icon: Icon(Icons.refresh))
        ], title: Text("Conversor monetário"), backgroundColor: Colors.purple),
        body: FutureBuilder<Map?>(
            future: getData(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text("Carregando dados...",
                          style: TextStyle(color: Colors.black, fontSize: 26)));

                default:
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Erro ao receber dados...",
                            style: TextStyle(color: Colors.red, fontSize: 26)));
                  } else {
                    dolar =
                        snapshot.data!["results"]["currencies"]["USD"]["buy"];
                    euro =
                        snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                    return SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Icon(
                            Icons.monetization_on_outlined,
                            color: Colors.purple,
                            size: 150,
                          ),
                          Divider(
                            height: 50,
                            thickness: 2,
                          ),
                          CampoTexto(
                              "Real", "R\$ ", RealController, converterReal),
                          Divider(
                            height: 20,
                          ),
                          CampoTexto("Dolar", "US\$ ", DolarController,
                              converterDolar),
                          Divider(
                            height: 20,
                          ),
                          CampoTexto(
                              "Euro", "€ ", EuroController, converterEuro)
                        ],
                      ),
                    );
                  }
              }
            }));
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(
      Uri.parse("https://api.hgbrasil.com/finance?format=json&key=dd4425d8"));
  return json.decode(response.body);
}

Widget CampoTexto(String labelText, String prefix,
    TextEditingController controlador, Function(String) change) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.purple, fontSize: 20),
        prefixText: prefix),
    style: TextStyle(fontSize: 19, color: Colors.purpleAccent),
    controller: controlador,
    onChanged: change,
  );
}
