/*import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
  Order({
    //required this.id,
    required this.comment,
    required this.state,
    required this.user,
    required this.deliveryDate,
  });

  //final int id;
  final String comment;
  final String state;
  final User user;
  final DateTime deliveryDate;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        //id: json["id"],
        comment: json["comment"],
        state: json["state"],
        user: User.fromJson(json["user"]),
        deliveryDate: DateTime.parse(json["delivery_date"]),
      );

  Map<String, dynamic> toJson() => {
        //"id": id,
        "comment": comment,
        "state": state,
        "user": user.toJson(),
        "delivery_date":
            "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
      };
}

class User {
  User({
    required this.id,
    required this.name,
    required this.businessName,
    required this.ruc,
    required this.phone,
    required this.address,
    required this.type,
    required this.email,
  });

  final int id;
  final String name;
  final String businessName;
  final String ruc;
  final String phone;
  final String address;
  final String type;
  final String email;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        businessName: json["business_name"],
        ruc: json["ruc"],
        phone: json["phone"],
        address: json["address"],
        type: json["type"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "business_name": businessName,
        "ruc": ruc,
        "phone": phone,
        "address": address,
        "type": type,
        "email": email,
      };
}*/

class Order {
  //final int id;
  final String comment;
  final String state;
  //final User user;
  final String delivery_date;

  Order(
      //required this.id,
      this.comment,
      this.state,
      //required this.user,
      this.delivery_date);
}
