import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';

import 'package:cliente_movil/models/Product.dart';
import 'package:cliente_movil/pages/client/clientOrderP.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:cliente_movil/pages/client/newOrder.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Product extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  Product(this.id_user);
  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.id_user),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  MainPage(this.id_user);
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ignore: non_constant_identifier_names
  late int id_order;
  late Future<List<ProductView>> _listProducts;

  bool loading = false;
  late SharedPreferences sharedPreferences;

  //Funcion para visualizar productos
  Future<List<ProductView>> _getProducts() async {
    setState(() {
      loading = true;
    });

    final response = await http.get(
      Uri.parse("http://192.168.100.7:8000/api/products"),
    );

    List<ProductView> products = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData["data"]) {
        products.add(ProductView(
            item["id"],
            item["name"],
            item["dimensions"],
            item["texture"],
            item["consumption_time"],
            item["img_url"],
            item["description"],
            item["package_amount"],
            Category(item["category"]["id"], item["category"]["name"])));
      }
      //print(response.body);
      return products;
    } else {
      throw Exception("Falló conexión");
    }
  }

  //Funcion para crear una orden
  // ignore: non_constant_identifier_names
  void _postOrders(String comment, String state, String delivery_date) async {
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");
    await http
        .post(Uri.parse("http://192.168.100.7:8000/api/orders"),
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
      var datauser = json.decode(response.body);
      id_order = datauser["id"];
      print('ID de la orden: $id_order');
    });
    Navigator.of(context).push(new MaterialPageRoute(
      builder: (BuildContext context) => NewOrder(widget.id_user, id_order),
    ));
  }

  @override
  void initState() {
    super.initState();
    _listProducts = _getProducts();
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
        title: Text("Productos", style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          ElevatedButton.icon(
              onPressed: () {
                _postOrders("Sin asignar", "en carrito", "1000-01-01");
              },
              icon: new Icon(Icons.add_business_outlined),
              label: Text("Nueva orden")),
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
      body: Container(
        child: (loading)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder(
                future: _listProducts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: _listadoProducts(snapshot.data),
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
      ),
    );
  }

  List<Widget> _listadoProducts(data) {
    List<Widget> products = [];
    //int id;
    for (var product in data) {
      products.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ImagePage(product.img_url)));
            },
            title: Text(product.name),
            subtitle: Text(product.description),
            trailing: CircleAvatar(
              radius: 40.0,
              backgroundImage: NetworkImage(product.img_url),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dimensiones: " + product.dimensions,
                  style: TextStyle(color: Colors.black.withOpacity(0.4)),
                ),
                Text(
                    "Unidades por paquete: " +
                        product.package_amount.toString(),
                    style: TextStyle(color: Colors.black.withOpacity(0.4))),
              ],
            ),
          ),
          /*Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Dirección: " + product.userO.address),
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
                  "Comentario: \n" + product.comment,
                  style: TextStyle(color: Colors.black.withOpacity(0.4)),
                ),
                Text("\nFecha de solicitud: " + product.created_at),
              ],
            ),
          ),*/
          /*Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    //print(order.id);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderD(product.id)));
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
                                product.id,
                                product.comment,
                                product.state,
                                product.delivery_date)));
                  },
                  child: Text(
                    "Editar",
                    style: TextStyle(color: Colors.cyan),
                  )),
            ],
          )*/
        ],
      )));
    }
    return products;
  }
}

class ImagePage extends StatelessWidget {
  final String id;
  ImagePage(this.id);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Image.network(id),
    );
  }
}
