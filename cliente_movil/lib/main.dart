import 'dart:convert';

import 'package:cliente_movil/pages/adminPage.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Direccion de pantalla
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      //Estilo de la aplicacion
      title: "Cono Superior",
      home: MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late int id;
  bool _isLoading = false;
  late bool _passwordVisible; //Visibilidad de contraseña

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            /*gradient: LinearGradient(
              colors: [Colors.amber, Colors.yellow],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),*/
            image: DecorationImage(
                image: AssetImage("assets/sign_ing.jpeg"), fit: BoxFit.cover)),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
    );
  }

  @override
  void initState() {
    _passwordVisible = false;
    super.initState();
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map data = {'email': email, 'password': pass};
    // ignore: avoid_init_to_null
    var jsonResponse = null;

    var response = await http.post(Uri.parse("$ROUTE_API/login"), body: data);
    if (response.statusCode == 200) {
      var datauser = json.decode(response.body);
      jsonResponse = json.decode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      id = datauser['user']['id'];
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        if (datauser['user']['type'] == 'admin') {
          sharedPreferences.setString("token", jsonResponse['token']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => Admin()),
              (Route<dynamic> route) => false);
        } else if (datauser['user']['type'] == 'client') {
          sharedPreferences.setString("token", jsonResponse['token']);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => Client(id)),
              (Route<dynamic> route) => false);
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print(response.body);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Email o contraseña incorrectos.",
                    style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.amber[400],
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Text("Intentar nuevamente",
                          style: TextStyle(color: Colors.blueGrey)))
                ],
              ));
      emailController.text = "";
      passwordController.text = "";
    }
  }

  Container buttonSection() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 40.0,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      margin: EdgeInsets.only(top: 15.0),
      child: ElevatedButton(
        onPressed: emailController.text == "" || passwordController.text == ""
            ? null
            : () {
                setState(() {
                  _isLoading = true;
                });
                signIn(emailController.text, passwordController.text);
              },
        child: Text("Ingresar", style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  Container textSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              icon: Icon(Icons.email, color: Colors.black),
              hintText: "Email",
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70)),
              hintStyle: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(height: 30.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.white,
            obscureText: !_passwordVisible,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                icon: Icon(Icons.lock, color: Colors.black),
                hintText: "Contraseña",
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70)),
                hintStyle: TextStyle(color: Colors.black),
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                suffixIcon: GestureDetector(
                  onLongPress: () {
                    setState(() {
                      _passwordVisible = true;
                    });
                  },
                  onLongPressUp: () {
                    setState(() {
                      _passwordVisible = false;
                    });
                  },
                  child: Icon(_passwordVisible
                      ? Icons.visibility
                      : Icons.visibility_off),
                )),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
      margin: EdgeInsets.only(top: 70.0),
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
      child: Text("",
          style: TextStyle(
            color: Colors.white,
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
          )),
    );
  }
}
