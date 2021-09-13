class OrderC {
  //final int id;
  final String name;
  final String texture;
  final PivotC pivotC;

  OrderC(this.name, this.texture, this.pivotC);
}

class PivotC {
  // ignore: non_constant_identifier_names
  int order_id;
  // ignore: non_constant_identifier_names
  int product_units;

  PivotC(this.order_id, this.product_units);
}
