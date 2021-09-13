import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:cliente_movil/pages/employees.dart';
import 'package:intl/intl.dart';

import 'package:cliente_movil/main.dart';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'adminPage.dart';
import 'clients.dart';

class OrderE extends StatefulWidget {
  final int id;
  final String comment;
  final String state;
  // ignore: non_constant_identifier_names
  final String delivery_date;
  OrderE(this.id, this.comment, this.state, this.delivery_date);
  @override
  _OrderEState createState() => _OrderEState();
}

class _OrderEState extends State<OrderE> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(
          widget.id, widget.comment, widget.state, widget.delivery_date),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  final int id;
  final String comment;
  final String state;
  // ignore: non_constant_identifier_names
  final String delivery_date;
  MainPage(this.id, this.comment, this.state, this.delivery_date);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String _valueChoose;
  var listItem = ["en proceso", "entregado"];
  late TextEditingController controllerComment;
  // ignore: non_constant_identifier_names
  late TextEditingController dateinput;

  bool loading = false;
  late SharedPreferences sharedPreferences;

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

  @override
  void initState() {
    _valueChoose = widget.state;

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
                    enabled: false,
                    decoration: new InputDecoration(
                      hintText: "Comentario",
                      labelText: "Comentario",
                    ),
                  ),
                ),
                TextField(
                  controller: dateinput, //editing controller of this TextField
                  decoration: InputDecoration(
                      icon: Icon(Icons.calendar_today), //icon of text field
                      labelText: "Fecha de entrega: ",
                      labelStyle: TextStyle(
                          fontWeight: FontWeight.bold) //label text of field
                      ),
                  readOnly:
                      true, //set it true, so that user will not able to edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(
                            2000), //DateTime.now() - not to allow to choose before today.
                        lastDate: DateTime(2030));

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      //you can implement different kind of Date Format here according to your requirement

                      setState(() {
                        dateinput.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {
                      print("Date is not selected");
                    }
                  },
                ),
                Text(
                  "\nEstado del pedido: ",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                DropdownButton(
                  items: listItem.map((String a) {
                    return DropdownMenuItem(value: a, child: Text(a));
                  }).toList(),
                  onChanged: (_value) {
                    setState(() {
                      _valueChoose = _value.toString();
                    });
                  },
                  hint: Text(_valueChoose),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.blue[100]),
                    onPressed: dateinput.text == ""
                        ? null
                        : () {
                            setState(() {
                              loading = true;
                            });
                            _updateOrders(widget.id, controllerComment.text,
                                _valueChoose, dateinput.text);
                            Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) => Admin(),
                            ));
                          },
                    child: Text("Actualizar",
                        style: TextStyle(color: Colors.indigo[900])))
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
              accountEmail: new Text('Administrador'),
              // decoration: new BoxDecoration(
              //   image: new DecorationImage(
              //     fit: BoxFit.fill,
              //    // image: AssetImage('img/estiramiento.jpg'),
              //   )
              // ),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Pedidos"),
              trailing: new Icon(Icons.shopping_cart),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Admin(),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Clientes"),
              trailing: new Icon(Icons.group),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Clients(),
              )),
            ),
            new Divider(),
            new ListTile(
              title: new Text("Empleados"),
              trailing: new Icon(Icons.hail),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Employees(),
              )),
            )
            // new Divider(),
            // new ListTile(
            //   title: new Text("Mostrar listado"),
            //   trailing: new Icon(Icons.help),
            //   onTap: () => Navigator.of(context).push(new MaterialPageRoute(
            //     builder: (BuildContext context) => ShowData(),
            //   )),
            // ),
          ],
        ),
      ),
    );
  }
}
