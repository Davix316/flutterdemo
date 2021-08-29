import 'dart:convert';

import 'package:cliente_movil/models/Product.dart';
//import 'package:cliente_movil/models/product.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

class Principal extends StatefulWidget {
  const Principal({key}) : super(key: key);

  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  late Future<List<Product>> _listProducts;

  Future<List<Product>> _getProducts() async {
    final response =
        await http.get(Uri.parse("http://192.168.100.7:8000/api/products"));

    List<Product> products = [];

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      final jsonData = jsonDecode(body);

      for (var item in jsonData["data"]) {
        products.add(Product(item["name"], item["dimensions"]));
      }

      return products;
    } else {
      throw Exception("Falló conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listProducts = _getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menú Principal',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista productos'),
        ),
        body: FutureBuilder(
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
    );
  }

  List<Widget> _listadoProducts(data) {
    List<Widget> products = [];

    for (var product in data) {
      products.add(Card(
          child: Column(
        children: [
          Text(product.dimensions),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product.name),
          ),
        ],
      )));
    }
    return products;
  }
}
