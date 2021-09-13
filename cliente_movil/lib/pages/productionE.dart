import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/EmployeeP.dart';
import 'package:cliente_movil/pages/clients.dart';
import 'package:cliente_movil/pages/employees.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'adminPage.dart';

class ProductionE extends StatefulWidget {
  final int id;
  ProductionE(this.id);
  @override
  _ProductionEState createState() => _ProductionEState();
}

class _ProductionEState extends State<ProductionE> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(widget.id),
      theme: ThemeData(accentColor: Colors.white70),
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
  late Future<List<ProductionEm>>
      _listProductionE; //Lista de productos en la Orden

  // ignore: non_constant_identifier_names
  late int id_employee = widget.id;
  bool loading = false;
  late SharedPreferences sharedPreferences;

  Future<List<ProductionEm>> _getProductionE() async {
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
      Uri.parse(
          "http://192.168.100.7:8000/api/employee/$id_employee/production"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    List<ProductionEm> productionE = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData["data"]) {
        productionE.add(ProductionEm(
            item["total_sales"],
            item["liters"],
            item["time"],
            item["performance"],
            item["date"],
            ProductP(item["product"]["name"], item["product"]["dimensions"])));
      }
      //print(response.body);
      return productionE;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listProductionE = _getProductionE();
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
              future: _listProductionE,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _listadoProductionE(snapshot.data),
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

  List<Widget> _listadoProductionE(data) {
    List<Widget> productionsE = [];

    for (var productionC in data) {
      productionsE.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            //leading: Icon(Icons.person),
            title: Text(productionC.productP.name),
            subtitle: Text("Dimensiones: " + productionC.productP.dimensions),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("Paquetes: " + productionC.total_sales.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Litros: " + productionC.liters.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  "Horas: " + productionC.time,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Fecha: " + productionC.date,
                style: TextStyle(color: Colors.black.withOpacity(0.4))),
          )
        ],
      )));
    }

    return productionsE;
  }
}
