//pagina productos en carrito de la orden del usuario
import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/models/OrderC.dart';
//import 'package:cliente_movil/pages/client/clientOrderP.dart';
//import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:cliente_movil/pages/client/newOrder.dart';
import 'package:cliente_movil/pages/client/orderAccept.dart';
import 'package:cliente_movil/pages/client/productsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class CartProduct extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  // ignore: non_constant_identifier_names
  final int id_order;
  CartProduct(this.id_user, this.id_order);
  @override
  _CartProductState createState() => _CartProductState();
}

class _CartProductState extends State<CartProduct> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.id_user, widget.id_order),
      theme: ThemeData(
          accentColor: Colors.white70, primaryColor: Colors.amber[600]),
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
  //late int id_order = widget.id_order;
  // ignore: non_constant_identifier_names
  //late int id_user = widget.id_user;
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
      Uri.parse("$ROUTE_API/cart/products/${widget.id_user}"),
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
        clientordersC.add(OrderC(item["name"], item["package_amount"],
            PivotC(item["pivot"]["order_id"], item["pivot"]["product_units"])));
      }
      //print(response.body);
      return clientordersC;
    } else {
      throw Exception("Falló conexión");
    }
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
        actions: <Widget>[
          ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      OrderAccept(widget.id_user, widget.id_order),
                ));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber)),
              icon: new Icon(Icons.check_circle_outline_rounded),
              label: Text("Solicitar")),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      NewOrder(widget.id_user, widget.id_order),
                ));
              },
              color: Colors.white,
              icon: new Icon(Icons.add_shopping_cart_outlined)),
          ElevatedButton.icon(
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
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                },
                                child: Text("No",
                                    style:
                                        TextStyle(color: Colors.indigo[900]))),
                            ElevatedButton(
                                onPressed: () {
                                  _deleteOrders(widget.id_order);
                                  Navigator.of(context, rootNavigator: true)
                                      .push(new MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              Product(
                                                widget.id_user,
                                              )));
                                },
                                child: Text("Sí",
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber)),
              icon: new Icon(Icons.cancel),
              label: Text("Cancelar")),
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
      /*drawer: Drawer(
        child: new ListView(
          children: <Widget>[
            new UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/menu.jpg"), fit: BoxFit.cover)),
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
                builder: (BuildContext context) => Client(widget.id_user),
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
      ),*/
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
            subtitle: Text("Unidades por paquete: " +
                clientOrderC.package_amount.toString()),
            trailing: Text("Paquetes solicitados: " +
                clientOrderC.pivotC.product_units.toString()),
          ),
        ],
      )));
    }

    return clientOrdersC;
  }
}
