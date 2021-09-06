/*import 'dart:convert';

ModelOrder orderFromJson(String str) => ModelOrder.fromJson(json.decode(str));

String orderToJson(ModelOrder data) => json.encode(data.toJson());

class ModelOrder {
  ModelOrder({
    //required this.id,
    required this.comment,
    required this.state,
    required this.user,
    required this.deliveryDate,
  });

  //final int id;
  String comment;
  String state;
  ModelUser user;
  String deliveryDate;

  factory ModelOrder.fromJson(Map<String, dynamic> json) => ModelOrder(
        //id: json["id"],
        comment: json["comment"],
        state: json["state"],
        user: ModelUser.fromJson(json["user"]),
        deliveryDate: json["delivery_date"],
      );

  Map<String, dynamic> toJson() => {
        //"id": id,
        "comment": comment,
        "state": state,
        "user": user.toJson(),
        "delivery_date": deliveryDate
      };
}
*/
/*class ModelUser {
  ModelUser({
    required this.id,
    required this.name,
    required this.businessName,
    required this.ruc,
    required this.phone,
    required this.address,
    required this.type,
    required this.email,
  });

  int id;
  String name;
  String businessName;
  String ruc;
  String phone;
  String address;
  String type;
  String email;

  factory ModelUser.fromJson(Map<String, dynamic> json) => ModelUser(
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

class OrderM {
  final String comment;
  final String state;
  final UserM userM;
  final String delivery_date;

  OrderM(this.comment, this.state, this.userM, this.delivery_date);

  /*OrderM.fromjson(Map<String, dynamic> json)
      : comment = json['comment'],
        state = json['state'],
        userM = UserM.fromjson(json['user']),
        delivery_date = json['delivery_date'];*/
}

class UserM {
  String name;
  String business_name;

  UserM(this.name, this.business_name);

  /*UserM.fromjson(Map<String, dynamic> json)
      : name = json['name'],
        business_name = json['business_name'];*/
}

// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);

/*import 'dart:convert';

Order orderFromJson(String str) => Order.fromJson(json.decode(str));

String orderToJson(Order data) => json.encode(data.toJson());

class Order {
    Order({
        this.data,
    });

    List<Datum> data;

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Datum {
    Datum({
        this.id,
        this.comment,
        this.state,
        this.user,
        this.createdAt,
        this.updatedAt,
        this.deliveryDate,
    });

    int id;
    String comment;
    String state;
    User user;
    DateTime createdAt;
    DateTime updatedAt;
    DateTime deliveryDate;

    factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        comment: json["comment"],
        state: json["state"],
        user: User.fromJson(json["user"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        deliveryDate: DateTime.parse(json["delivery_date"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "state": state,
        "user": user.toJson(),
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "delivery_date": "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
    };
}

class User {
    User({
        this.id,
        this.name,
        this.businessName,
        this.ruc,
        this.phone,
        this.address,
        this.type,
        this.email,
        this.emailVerifiedAt,
        this.createdAt,
        this.updatedAt,
    });

    int id;
    String name;
    String businessName;
    String ruc;
    String phone;
    String address;
    String type;
    String email;
    dynamic emailVerifiedAt;
    DateTime createdAt;
    DateTime updatedAt;

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        businessName: json["business_name"],
        ruc: json["ruc"],
        phone: json["phone"],
        address: json["address"],
        type: json["type"],
        email: json["email"],
        emailVerifiedAt: json["email_verified_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
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
        "email_verified_at": emailVerifiedAt,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
    };
}

*/

// To parse this JSON data, do
//
//     final order = orderFromJson(jsonString);
/*
import 'dart:convert';

List<OrderC> orderFromJson(String str) =>
    List<OrderC>.from(json.decode(str).map((x) => OrderC.fromJson(x)));

String orderToJson(List<OrderC> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class OrderC {
  OrderC({
    required this.id,
    required this.comment,
    required this.state,
    required this.user,
    required this.deliveryDate,
  });

  int id;
  String comment;
  String state;
  UserC user;
  DateTime deliveryDate;

  factory OrderC.fromJson(Map<String, dynamic> json) => OrderC(
        id: json["id"],
        comment: json["comment"],
        state: json["state"],
        user: UserC.fromJson(json["user"]),
        deliveryDate: DateTime.parse(json["delivery_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment": comment,
        "state": state,
        "user": user.toJson(),
        "delivery_date":
            "${deliveryDate.year.toString().padLeft(4, '0')}-${deliveryDate.month.toString().padLeft(2, '0')}-${deliveryDate.day.toString().padLeft(2, '0')}",
      };
}

class UserC {
  UserC({
    required this.id,
    required this.name,
    required this.businessName,
    required this.phone,
    required this.address,
  });

  int id;
  String name;
  String businessName;
  String phone;
  String address;

  factory UserC.fromJson(Map<String, dynamic> json) => UserC(
        id: json["id"],
        name: json["name"],
        businessName: json["business_name"],
        phone: json["phone"],
        address: json["address"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "business_name": businessName,
        "phone": phone,
        "address": address,
      };
}
*/