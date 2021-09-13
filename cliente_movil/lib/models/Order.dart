class Order {
  final int id;
  final String comment;
  final String state;
  final UserO userO;
  // ignore: non_constant_identifier_names
  final String delivery_date;

  Order(this.id, this.comment, this.state, this.userO, this.delivery_date);
}

class UserO {
  String name;
  // ignore: non_constant_identifier_names
  String business_name;
  String phone;
  String address;

  UserO(this.name, this.business_name, this.phone, this.address);
}
