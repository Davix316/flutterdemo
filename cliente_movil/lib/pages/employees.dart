import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/EmployeeD.dart';
import 'package:cliente_movil/pages/clients.dart';
import 'package:cliente_movil/pages/productionE.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'adminPage.dart';

class Employees extends StatefulWidget {
  @override
  _EmployeesState createState() => _EmployeesState();
}

class _EmployeesState extends State<Employees> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Cono Superior",
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<List<EmployeeD>> _listEmployees;

  bool loading = true;
  late SharedPreferences sharedPreferences;

  Future<List<EmployeeD>> _getEmployees() async {
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
      Uri.parse("http://192.168.100.7:8000/api/employees"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    List<EmployeeD> employees = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);

      final jsonData = jsonDecode(body);
      print(jsonData);

      for (var item in jsonData["data"]) {
        employees.add(EmployeeD(item["id"], item["name"], item["email"],
            item["phone"], item["dni"]));
      }
      //print(response.body);
      return employees;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listEmployees = _getEmployees();
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
        title: Text("Clientes", style: TextStyle(color: Colors.white)),
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
              future: _listEmployees,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: _listadoEmployees(snapshot.data),
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

  List<Widget> _listadoEmployees(data) {
    List<Widget> employees = [];

    for (var employee in data) {
      employees.add(Card(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.work),
            title: Text(employee.name),
            subtitle: Text(employee.dni),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text(employee.phone)],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [Text(employee.email)],
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
                            builder: (context) => ProductionE(employee.id)));
                  },
                  child: Text("Producción")),
              const SizedBox(width: 8),
            ],
          )
        ],
      )));
    }

    return employees;
  }
}
