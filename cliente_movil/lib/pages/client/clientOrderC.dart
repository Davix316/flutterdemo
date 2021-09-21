//pagina productos de la orden del usuario
import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/OrderC.dart';
import 'package:cliente_movil/pages/client/clientOrderP.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:cliente_movil/pages/client/productsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ClientOrderC extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  // ignore: non_constant_identifier_names
  final int id_order;
  ClientOrderC(this.id_user, this.id_order);
  @override
  _ClientOrderCState createState() => _ClientOrderCState();
}

class _ClientOrderCState extends State<ClientOrderC> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.id_user, widget.id_order),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  // ignore: non_constant_identifier_names
  final int id_order;
  MainPage(this.id_user, this.id_order);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<OrderC>> _clientOrderC; //Lista de productos en la Orden

  //late Future<List<Order>> _listOrders; //informacion de la orden.

  // ignore: non_constant_identifier_names
  late int id_order = widget.id_order;
  // ignore: non_constant_identifier_names
  late int id_user = widget.id_user;
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
      Uri.parse("http://192.168.100.7:8000/api/orders/$id_order/products"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    List<OrderC> clientordersC = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData) {
        clientordersC.add(OrderC(item["name"], item["texture"],
            PivotC(item["pivot"]["order_id"], item["pivot"]["product_units"])));
      }
      //print(response.body);
      return clientordersC;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _clientOrderC = _getOrderC();
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
        title: Text("Productos", style: TextStyle(color: Colors.white)),
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
              future: _clientOrderC,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _clienteOrdersC(snapshot.data),
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
                builder: (BuildContext context) => Client(id_user),
              )),
            ),
            new ListTile(
              title: new Text("Pedidos en proceso"),
              trailing: new Icon(Icons.handyman),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ClientOrderP(widget.id_user),
              )),
            ),
            new ListTile(
              title: new Text("Productos"),
              trailing: new Icon(Icons.assignment_outlined),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Product(widget.id_user),
              )),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _clienteOrdersC(data) {
    List<Widget> clientOrdersC = [];

    for (var clientOrderC in data) {
      clientOrdersC.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            //leading: Icon(Icons.person),
            title: Text(clientOrderC.name),
            subtitle: Text("Textura: " + clientOrderC.texture),
            trailing: Text(
                "Cantidad: " + clientOrderC.pivotC.product_units.toString()),
          ),
        ],
      )));
    }

    return clientOrdersC;
  }
}
