import 'dart:convert';
import 'dart:developer';

import 'package:cliente_movil/main.dart';
import 'package:cliente_movil/models/Order.dart';
import 'package:cliente_movil/models/userModel.dart';
import 'package:cliente_movil/pages/clients.dart';
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
  //List<ModelOrder> _list = [];
  List<dynamic> dat = [];
  late String url;
  var response;
  bool loading = true;

  List<OrderM> orderList = [];

  Future<List<OrderM>> getOrders() async {
    log("Obteniendo prefs...");
    final prefs = await SharedPreferences.getInstance();
    String? posibleToken = prefs.getString("token");
    log("Posible token: $posibleToken");
    if (posibleToken == null) {
      log("No hay token");
    }
    log("Haciendo petición...");
    response = await http.get(
      Uri.parse("http://192.168.100.7:8000/api/orders"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $posibleToken',
      },
    );

    final da = jsonDecode(response.body);

    /*setState(() {
      orderList = da.map((data) => OrderM.fromjson(data)).toList();
    });*/
    for (var item in da["data"]) {
      dat.add(OrderM(item["comment"], item["state"], item.userM["user"],
          item["delivery_date"]));
    }

    /*if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final data = jsonDecode(body);
      orderList = data.map((data) => new OrderM.fromjson(data)).toList();
      loading = false;
    }*/
    return getOrders();
  }

  @override
  void initState() {
    super.initState();
    getOrders();
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
      body: loading == true
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: orderList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(orderList[index].state),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(orderList[index].delivery_date),
                            Text(orderList[index].comment),
                            //Text(orderList[index].userM.name)
                          ],
                        ),
                      ),
                    );
                  }),
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

  /*List<Widget> _listadoUsers(data) {
    List<Widget> users = [];

    for (var user in data) {
      if (user.type == "client") {
        users.add(Card(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text(user.name),
              subtitle: Text(user.business_name),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(user.phone)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(user.address)],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Text(user.email)],
            ),
          ],
        )));
      }
    }

    return users;
  }*/
}
