//import 'dart:convert';
//Pagina de ordendes en proceso del cliente
import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/Order.dart';
import 'package:cliente_movil/pages/client/clientOrderC.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:cliente_movil/pages/client/productsPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';

class ClientOrderP extends StatefulWidget {
  final int id;
  ClientOrderP(this.id);
  @override
  _ClientOrderPState createState() => _ClientOrderPState();
}

class _ClientOrderPState extends State<ClientOrderP> {
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
  // ignore: non_constant_identifier_names
  late int id_user = widget.id;
  late Future<List<Order>> _listOrders;
  //variable return de pagina
  bool num = false;

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
      Uri.parse("$ROUTE_API/orders/filtered/3/user/${widget.id}"),
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
            item["comment"],
            item["state"],
            UserO(item["user"]["name"], item["user"]["business_name"],
                item["user"]["phone"], item["user"]["address"]),
            item["created_at"],
            item["updated_at"],
            item["delivery_date"]));
      }
      //print(response.body);
      return orders;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
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
        title: Text("Cono Superior", style: TextStyle(color: Colors.white)),
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
                builder: (BuildContext context) => Client(widget.id),
              )),
            ),
            new ListTile(
              title: new Text("Pedidos en proceso"),
              trailing: new Icon(Icons.handyman),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => ClientOrderP(widget.id),
              )),
            ),
            new ListTile(
              title: new Text("Productos"),
              trailing: new Icon(Icons.assignment_outlined),
              onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => Product(id_user),
              )),
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estado del pedido:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(order.state)
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("\nFecha de solicitud:"),
                Text(order.created_at),
                Text("\nFecha asignada de entrega:"),
                Text(order.delivery_date)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Comentario: \n" + order.comment,
              style: TextStyle(color: Colors.black.withOpacity(0.4)),
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
                            builder: (context) =>
                                ClientOrderC(id_user, order.id, num)));
                  },
                  child: Text("Productos")),
              const SizedBox(width: 8),
            ],
          )
        ],
      )));
    }
    return orders;
  }
}
