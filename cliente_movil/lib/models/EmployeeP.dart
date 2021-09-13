class ProductionEm {
  //final int id;
  // ignore: non_constant_identifier_names
  final int total_sales;
  final int liters;
  final String time;
  final String performance;
  final String date;
  final ProductP productP;

  ProductionEm(this.total_sales, this.liters, this.time, this.performance,
      this.date, this.productP);
}

class ProductP {
  String name;
  String dimensions;

  ProductP(this.name, this.dimensions);
}
