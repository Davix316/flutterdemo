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

import '../../constant.dart';

class OrderAccept extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int user_id;
  // ignore: non_constant_identifier_names
  final int order_id;

  OrderAccept(this.user_id, this.order_id);
  @override
  _OrderAcceptState createState() => _OrderAcceptState();
}

class _OrderAcceptState extends State<OrderAccept> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.user_id, widget.order_id),
      theme: ThemeData(
          accentColor: Colors.white70, primaryColor: Colors.amber[600]),
    );
  }
}

class MainPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int user_id;
  // ignore: non_constant_identifier_names
  final int order_id;

  MainPage(this.user_id, this.order_id);
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
        .put(Uri.parse("$ROUTE_API/orders/$idOrder"),
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

  //Funcion eliminar producto
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
      Uri.parse("$ROUTE_API/orders/$idOrder"),
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
    controllerState = new TextEditingController(text: "en carrito");
    controllerComment = new TextEditingController(text: "Sin asignar");
    dateinput = new TextEditingController(
        text:
            "La fecha será asignada por el administrador"); //set the initial value of text field

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
                      hintText: "Ingrese comentario",
                      labelText: "Ingrese un comentario si lo desea.",
                    ),
                  ),
                ),
                TextField(
                    controller:
                        dateinput, //editing controller of this TextField
                    decoration: InputDecoration(
                        labelText: "Fecha de entrega: ",
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold) //label text of field
                        ),
                    readOnly: true,
                    enabled:
                        true //set it true, so that user will not able to edit text
                    ),
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
                        style: ElevatedButton.styleFrom(primary: Colors.amber),
                        onPressed: controllerComment.text == ""
                            ? null
                            : () {
                                setState(() {
                                  loading = true;
                                });

                                _updateOrders(widget.order_id,
                                    controllerComment.text, "en espera", "");
                                Navigator.of(context)
                                    .push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      Client(user_id),
                                ));
                              },
                        child: Text("Solicitar",
                            style: TextStyle(color: Colors.white))),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.amber[100]),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: Text("Cancelar orden"),
                                    content: Text(
                                        "¿Estás seguro? Se eliminará la orden y todos los productos seleccionados."),
                                    actions: [
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          },
                                          child: Text("No",
                                              style: TextStyle(
                                                  color: Colors.indigo[900]))),
                                      ElevatedButton(
                                          onPressed: () {
                                            _deleteOrders(widget.order_id);
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .push(new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  Product(widget.user_id),
                                            ));
                                          },
                                          child: Text("Sí",
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  ));
                        },
                        child: Text("Cancelar",
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
