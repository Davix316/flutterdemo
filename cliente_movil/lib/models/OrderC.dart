class OrderC {
  //final int id;
  final String name; //Informacion del producto
  // ignore: non_constant_identifier_names
  final int package_amount;
  final PivotC pivotC;

  OrderC(this.name, this.package_amount, this.pivotC);
}

//Informacion de la tabla cart
class PivotC {
  // ignore: non_constant_identifier_names
  int order_id;
  // ignore: non_constant_identifier_names
  int product_units;

  PivotC(this.order_id, this.product_units);
}
