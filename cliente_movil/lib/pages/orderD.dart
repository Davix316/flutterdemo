import 'dart:convert';
import 'dart:developer';

//import 'package:cliente_movil/main.dart';
//import 'package:cliente_movil/models/Order.dart';
import 'package:cliente_movil/models/OrderC.dart';
import 'package:cliente_movil/pages/clients.dart';
import 'package:cliente_movil/pages/employees.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import 'adminPage.dart';

class OrderD extends StatefulWidget {
  final int id;
  OrderD(this.id);
  @override
  _OrderDState createState() => _OrderDState();
}

class _OrderDState extends State<OrderD> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.id),
      theme: ThemeData(
          accentColor: Colors.white70, primaryColor: Colors.amber[600]),
    );
  }
}

class MainPage extends StatefulWidget {
  final int id;
  MainPage(this.id);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<OrderC>> _listOrderC; //Lista de productos en la Orden

  //late Future<List<Order>> _listOrders; //informacion de la orden.

  // ignore: non_constant_identifier_names
  late int id_order = widget.id;
  bool loading = false;
  late SharedPreferences sharedPreferences;

  Future<List<OrderC>> _getOrderC() async {
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
      Uri.parse("$ROUTE_API/orders/$id_order/products"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    List<OrderC> ordersC = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData) {
        ordersC.add(OrderC(item["name"], item["package_amount"],
            PivotC(item["pivot"]["order_id"], item["pivot"]["product_units"])));
      }
      //print(response.body);
      return ordersC;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listOrderC = _getOrderC();
    this.loading = false;
    //_listOrders = _getOrders();
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
        title: Text("Detalle", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => Admin(),
                ));
              },
              color: Colors.white,
              icon: new Icon(Icons.keyboard_return_outlined)),
        ],
      ),
      body: (loading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : FutureBuilder(
              future: _listOrderC,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _listadoOrdersC(snapshot.data),
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
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/menu.jpg"), fit: BoxFit.cover)),
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

  List<Widget> _listadoOrdersC(data) {
    List<Widget> ordersC = [];

    for (var orderC in data) {
      ordersC.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            //leading: Icon(Icons.person),
            title: Text(orderC.name),
            subtitle: Text(
                "Unidades por paquete: " + orderC.package_amount.toString()),
            trailing: Text("Paquetes solicitados: " +
                orderC.pivotC.product_units.toString()),
          ),
        ],
      )));
    }

    return ordersC;
  }
}
