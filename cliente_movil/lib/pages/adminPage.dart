import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/Order.dart';
import 'package:cliente_movil/pages/clients.dart';
import 'package:cliente_movil/pages/employees.dart';
import 'package:cliente_movil/pages/orderD.dart';
import 'package:cliente_movil/pages/orderEdit.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

class Admin extends StatefulWidget {
  @override
  _AdminState createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(
          accentColor: Colors.white70, primaryColor: Colors.amber[600]),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<Order>> _listOrders;

  //Filtrado
  late String _valueChoose;
  var listItem = ["En espera", "En proceso", "Entregado"];

  bool loading = false;
  late SharedPreferences sharedPreferences;

  Future<List<Order>> _getOrders() async {
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
    final response = await http.get(
      Uri.parse("$ROUTE_API/orders"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    List<Order> orders = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData["data"]) {
        orders.add(Order(
            item["id"],
            item["comment"] ?? "Sin asignar",
            item["state"],
            UserO(item["user"]["name"], item["user"]["business_name"],
                item["user"]["phone"], item["user"]["address"]),
            item["created_at"],
            item["updated_at"],
            item["delivery_date"] ?? "Sin asignar fecha"));
      }
      //print(response.body);
      return orders;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    _valueChoose = "En espera";
    super.initState();
    _listOrders = _getOrders();
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
        title: DropdownButton(
          icon: const Icon(Icons.arrow_circle_down_outlined),
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
      body: (loading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: _listOrders,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _listadoOrders(snapshot.data),
                  );
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text("Error");
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
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

  List<Widget> _listadoOrders(data) {
    List<Widget> orders = [];
    //int id;
    for (var order in data) {
      orders.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(order.state),
            subtitle: Text(order.delivery_date),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Cliente",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold)),
                Text(order.userO.name),
                Text(order.userO.business_name),
                //Text(order.userO.address)
                //Text(order.id.toString()),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Dirección: " + order.userO.address),
              const SizedBox(
                width: 8,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Comentario: \n" + order.comment,
                  style: TextStyle(color: Colors.black.withOpacity(0.4)),
                ),
                Text("\nFecha de solicitud: " + order.created_at),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    //print(order.id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderD(order.id)));
                  },
                  child: Text("Ver")),
              const SizedBox(width: 8),
              TextButton(
                  onPressed: () {
                    //print(order.id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderE(
                                order.id,
                                order.comment,
                                order.state,
                                order.delivery_date)));
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(color: Colors.cyan),
                  )),
            ],
          )
        ],
      )));
    }
    return orders;
  }
}
