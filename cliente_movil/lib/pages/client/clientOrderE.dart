//Pagina editar comentario o eliminar una orden
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cliente_movil/pages/client/clientOrderP.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/pages/client/productsPage.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClientOrderE extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int user_id;
  final int id;
  final String comment;
  final String state;
  // ignore: non_constant_identifier_names
  final String delivery_date;
  ClientOrderE(
      this.user_id, this.id, this.comment, this.state, this.delivery_date);
  @override
  _ClientOrderEState createState() => _ClientOrderEState();
}

class _ClientOrderEState extends State<ClientOrderE> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.user_id, widget.id, widget.comment, widget.state,
          widget.delivery_date),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int user_id;
  final int id;
  final String comment;
  final String state;
  // ignore: non_constant_identifier_names
  final String delivery_date;
  MainPage(this.user_id, this.id, this.comment, this.state, this.delivery_date);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ignore: non_constant_identifier_names
  late int user_id = widget.user_id;
  var listItem = ["en proceso", "entregado"];
  late TextEditingController controllerComment;
  late TextEditingController controllerState;
  // ignore: non_constant_identifier_names
  late TextEditingController dateinput;

  bool loading = false;
  late SharedPreferences sharedPreferences;

  //Funcion editar producto
  void _updateOrders(
      int idOrder,
      String comment,
      String state,
      // ignore: non_constant_identifier_names
      String delivery_date) async {
    setState(() {
      loading = true;
    });
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");
    await http
        .put(Uri.parse("http://192.168.100.7:8000/api/orders/$idOrder"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $posibleToken',
            },
            body: jsonEncode({
              "comment": "$comment",
              "state": "$state",
              "delivery_date": "$delivery_date",
            }))
        .then((response) {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    });
  }

  //Funcion eliminar orden
  void _deleteOrders(
    int idOrder,
  ) async {
    setState(() {
      loading = true;
    });
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");
    await http.delete(
      Uri.parse("http://192.168.100.7:8000/api/orders/$idOrder"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    ).then((response) {
      print('Status: ${response.statusCode}');
      //print('Body: ${response.body}');
    });
  }

  @override
  void initState() {
    controllerState = new TextEditingController(text: widget.state);
    controllerComment = new TextEditingController(text: widget.comment);
    dateinput = new TextEditingController(
        text: widget.delivery_date); //set the initial value of text field

    super.initState();
    this.loading = false;
    //checkLoginStatus();
  }

  /*checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => Start()),
          (Route<dynamic> route) => false);
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pedido", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // ignore: deprecated_member_use
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (BuildContext context) => App()),
                  (Route<dynamic> route) => false);
            },
            child: Text("Log Out", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        child: ListView(
          padding: const EdgeInsets.all(10.0),
          children: [
            new Column(
              children: [
                ListTile(
                  title: new TextField(
                    controller: controllerComment,
                    maxLines: 5,
                    decoration: new InputDecoration(
                      hintText: "Comentario",
                      labelText: "Comentario",
                    ),
                  ),
                ),
                TextField(
                    controller:
                        dateinput, //editing controller of this TextField
                    decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today), //icon of text field
                        labelText: "Fecha de entrega: ",
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold) //label text of field
                        ),
                    readOnly:
                        true, //set it true, so that user will not able to edit text
                    enabled: false),
                TextField(
                  controller:
                      controllerState, //editing controller of this TextField
                  decoration: InputDecoration(
                      labelText: "Estado del pedido: ",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold) //label text of field
                      ),
                  readOnly: true,
                  enabled:
                      false, //set it true, so that user will not able to edit text
                ),
                Row(
                  children: [
                    ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(primary: Colors.blue[100]),
                        onPressed: controllerComment.text == ""
                            ? null
                            : () {
                                setState(() {
                                  loading = true;
                                });
                                _updateOrders(widget.id, controllerComment.text,
                                    controllerState.text, dateinput.text);
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Client(user_id),
                                ));
                              },
                        child: Text("Actualizar",
                            style: TextStyle(color: Colors.indigo[900]))),
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text("Eliminar orden"),
                                    content: Text(
                                        "¿Estás seguro? Se eliminará la orden y todos los productos seleccionados."),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                          child: Text("Cancelar",
                                              style: TextStyle(
                                                  color: Colors.indigo[900]))),
                                      ElevatedButton(
                                          onPressed: () {
                                            _deleteOrders(widget.id);
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Client(user_id),
                                            ));
                                          },
                                          child: Text("Eliminar",
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ));
                        },
                        child: Text("Eliminar",
                            style: TextStyle(color: Colors.red)))
                  ],
                )
              ],
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              accountName: new Text('Menú Principal'),
              accountEmail: new Text('Cliente'),
              // decoration: new BoxDecoration(
              //   image: new DecorationImage(
              //     fit: BoxFit.fill,
              //    // image: AssetImage('img/estiramiento.jpg'),
              //   )
              // ),
            ),
            new ListTile(
              title: new Text("Pedidos en espera"),
              trailing: new Icon(Icons.access_time),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Client(user_id),
              )),
            ),
            new ListTile(
              title: new Text("Pedidos en proceso"),
              trailing: new Icon(Icons.handyman),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ClientOrderP(user_id),
              )),
            ),
            new ListTile(
              title: new Text("Productos"),
              trailing: new Icon(Icons.assignment_outlined),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Product(user_id),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
