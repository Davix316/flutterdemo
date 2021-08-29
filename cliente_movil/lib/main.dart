import 'package:cliente_movil/pages/principal.dart';
import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  const App({key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Estilo de la aplicacion
      title: "Cono Superior",
      home: Start(),
    );
  }
}

class Start extends StatefulWidget {
  Start({key}) : super(key: key);

  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: login(context),
    );
  }
}

Widget login(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                "https://cdn.pixabay.com/photo/2018/08/01/17/39/ice-cream-3577706_960_720.jpg"),
            fit: BoxFit.cover)),
    child: Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        auth(),
        email(),
        password(),
        SizedBox(
          height: 10,
        ),
        btnlogin(context),
      ],
    )),
  );
}

Widget auth() {
  return Text(
    "Usuario",
    style: TextStyle(
        color: Colors.white, fontSize: 35.0, fontWeight: FontWeight.bold),
  );
}

Widget email() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: TextField(
      decoration: InputDecoration(
        hintText: "Correo",
        fillColor: Colors.white,
        filled: true,
      ),
    ),
  );
}

Widget password() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    child: TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: "Contraseña",
        fillColor: Colors.white,
        filled: true,
      ),
    ),
  );
}

Widget btnlogin(BuildContext context) {
  return ElevatedButton(
    //color: Colors.blueAccent,
    //padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
    onPressed: () {
      Navigator.push(context,
          new MaterialPageRoute(builder: (context) => new Principal()));
    },
    child: Text(
      "Ingresar",
      style: TextStyle(fontSize: 25, color: Colors.white),
    ),
    style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.blueAccent)),
  );
}
