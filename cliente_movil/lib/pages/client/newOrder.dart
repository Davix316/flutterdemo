import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/Product.dart';
import 'package:cliente_movil/pages/client/cartProduct.dart';
import 'package:cliente_movil/pages/client/clientOrderP.dart';
import 'package:cliente_movil/pages/client/clientPage.dart';
import 'package:cliente_movil/pages/client/productsPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant.dart';

class NewOrder extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final int id_user;
  // ignore: non_constant_identifier_names
  final int id_order;
  NewOrder(this.id_user, this.id_order);
  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
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
  late TextEditingController controllerUnits;
  late Future<List<ProductView>> _listProducts;

  bool loading = false;
  late SharedPreferences sharedPreferences;

  //Visualizar productos
  Future<List<ProductView>> _getProducts() async {
    setState(() {
      loading = true;
    });
    /*log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");*/
    final response = await http.get(
      Uri.parse("$ROUTE_API/products"),
      /*headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },*/
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

  // ignore: non_constant_identifier_names
  void _postCart(int product_units, int order_id, int product_id) async {
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");
    await http
        .post(Uri.parse("$ROUTE_API/carts"),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $posibleToken',
            },
            body: jsonEncode({
              "product_units": "$product_units",
              "order_id": "$order_id",
              "product_id": "$product_id",
            }))
        .then((response) {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
    });
  }

  @override
  void initState() {
    super.initState();
    _listProducts = _getProducts();
    this.loading = false;
    controllerUnits = new TextEditingController();
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
                Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) =>
                      CartProduct(widget.id_user, widget.id_order),
                ));
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.amber)),
              icon: new Icon(Icons.shopping_cart_outlined),
              label: Text("Carrito")),
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
                Container(
                  width: 100,
                  child: TextField(
                    controller: controllerUnits,
                    decoration: new InputDecoration(
                        labelText: "Número de paquetes.",
                        hintText: "Ingrese una cantidad"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(
                      fontSize: 10.0,
                      height: 2.0,
                    ),
                  ),
                )
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    _postCart(int.parse(controllerUnits.text), widget.id_order,
                        product.id);

                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text("Producto agregado"),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop();
                                    },
                                    child: Text("OK",
                                        style: TextStyle(
                                            color: Colors.indigo[900])))
                              ],
                            ));
                  },
                  child: Text("Agregar a carrito")),
              const SizedBox(width: 8),
            ],
          )
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
