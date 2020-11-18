import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;
  String cep;
  String pais;
  String cidade;
  var temperatura;
  var tempoDescricao;
  var tempoAgora;
  var umidadeAr;
  var vento;

  Future getWeather() async {
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$cidade&$pais&appid=e8962427977895dc7b82576019a60ef1");
    var results = jsonDecode(response.body);

    setState(() {
      this.temperatura = results['main']['temp'];
      this.tempoDescricao = results['weather'][0]['description'];
      this.tempoAgora = results['weather'][0]['main'];
      this.umidadeAr = results['main']['humidity'];
      this.vento = results['wind']['speed'];
    });
  }

  Future getLocate() async {
    http.Response response =
        await http.get("http://viacep.com.br/ws/$cep/json/");
    var results = jsonDecode(response.body);

    setState(() {
      this.cidade = results['localidade'];
      this.pais = 'Brazil';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Previsão do tempo'),
        ),
        body: new SingleChildScrollView(
          child: new Container(
            margin: new EdgeInsets.all(15.0),
            child: new Form(
              key: _key,
              autovalidate: _validate,
              child: _formUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    return new Column(
      children: <Widget>[
        new TextFormField(
          decoration: new InputDecoration(hintText: 'CEP'),
          style: TextStyle(fontWeight: FontWeight.bold),
          keyboardType: TextInputType.phone,
          maxLength: 8,
          validator: _validarCEP,
          onSaved: (String val) {
            cep = val;
          },
        ),
        new TextFormField(
          decoration:
              new InputDecoration(hintText: pais.toString(), labelText: 'País'),
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLength: 15,
          validator: _validarPais,
          onSaved: (String val) {
            pais = val;
            return pais;
          },
        ),
        new TextFormField(
          decoration: new InputDecoration(
              hintText: cidade.toString(), labelText: 'Cidade'),
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLength: 40,
          validator: _validarCidade,
          onSaved: (String val) {
            cidade = val;
          },
        ),
        new SizedBox(height: 15.0),
        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Buscar previsão do tempo'),
        ),
        new SizedBox(height: 15.0),
        Container(
          color: Colors.white,
          child: Text(
              tempoDescricao.toString() != null
                  ? 'Clima: ' + tempoDescricao.toString()
                  : "",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
        Container(
          color: Colors.white,
          child: Text(
              temperatura.toString().isNotEmpty != null
                  ? 'Temperatura: ' + temperatura.toString()
                  : "",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
        Container(
          color: Colors.white,
          child: Text(
              umidadeAr.toString() != null
                  ? 'Umidade Ar: ' + umidadeAr.toString()
                  : "",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
        Container(
          color: Colors.white,
          child: Text(
              cidade.toString().isNotEmpty != null
                  ? 'Cidade CEP: ' + cidade.toString()
                  : "",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  String _validarCEP(String cepParametro) {
    String patttern = r'(^[0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (cepParametro.isEmpty) {
      return "Informe o CEP";
    } else if (!regExp.hasMatch(cepParametro)) {
      return "O CEP deve conter apenas caracteres de 0-9";
    }
    return null;
  }

  String _validarPais(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (!regExp.hasMatch(value)) {
      return "O Pais deve ter apenas caracteres de a-z ou A-Z";
    }
    return null;
  }

  String _validarCidade(String value) {
    String patttern = r'(^[a-zA-Z ]*$)';
    RegExp regExp = new RegExp(patttern);
    if (!regExp.hasMatch(value)) {
      return "A cidade deve apenas caracteres de a-z ou A-Z";
    }
    return null;
  }

  _sendForm() async {
    if (_key.currentState.validate()) {
      _key.currentState.save();
      if (this.cep.toString().isNotEmpty) {
        await this.getLocate();
      }
      this.getWeather();
    } else {
      setState(() {
        _validate = true;
      });
    }
  }
}
