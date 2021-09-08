class Order {
  //final int id;
  final String comment;
  final String state;
  final UserO userO;
  // ignore: non_constant_identifier_names
  final String delivery_date;

  Order(
      //required this.id,
      this.comment,
      this.state,
      this.userO,
      this.delivery_date);
}

class UserO {
  String name;
  // ignore: non_constant_identifier_names
  String business_name;

  UserO(this.name, this.business_name);
}
