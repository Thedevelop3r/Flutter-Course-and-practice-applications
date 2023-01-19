final String carttable = 'carttable';

class CartField {
  static final List<String> values = [
    orderid,
    userid,
    productid,
    orderstock,
    itemprice,
    bulktotalprice,
    status
  ];
  static final String userid = 'userid';
  static final String orderid = '_orderid';
  static final String productid = 'productid';
  static final String orderstock = 'orderstock';
  static final String itemprice = 'itemprice';
  static final String bulktotalprice = 'bulktotalprice';
  static final String status = 'transactionstatus';
}

class Cart {
  int? orderid;
  final int userid;
  final int productid;
  final int orderstock;
  final int itemprice;
  final int bulktotalprice;
  final String status;

  Cart(
      {this.orderid,
      required this.userid,
      required this.productid,
      required this.orderstock,
      required this.itemprice,
      required this.bulktotalprice,
      required this.status});

  Map<String, Object?> toJson() => {
        CartField.orderid: orderid,
        CartField.userid: userid,
        CartField.productid: productid,
        CartField.orderstock: orderstock,
        CartField.itemprice: itemprice,
        CartField.bulktotalprice: bulktotalprice,
        CartField.status: status
      };

  static Cart fromJson(Map<String, Object?> json) => Cart(
      orderid: json[CartField.orderid] as int,
      userid: json[CartField.userid] as int,
      productid: json[CartField.productid] as int,
      orderstock: json[CartField.orderstock] as int,
      itemprice: json[CartField.itemprice] as int,
      bulktotalprice: json[CartField.bulktotalprice] as int,
      status: json[CartField.status] as String);

  Cart copy(
          {int? orderid,
          int? userid,
          int? productid,
          int? orderstock,
          int? itemprice,
          int? bulktotalprice,
          String? status}) =>
      Cart(
          orderid: orderid ?? this.orderid,
          userid: userid ?? this.userid,
          productid: productid ?? this.productid,
          orderstock: orderstock ?? this.orderstock,
          itemprice: itemprice ?? this.itemprice,
          bulktotalprice: bulktotalprice ?? this.bulktotalprice,
          status: status ?? this.status);

  @override
  String toString() {
    return 'UserID: $userid, OrderID: $orderid, ProductId: $productid, ItemPrice: $itemprice, OrderedStock: $orderstock, TotalPrice: $bulktotalprice, Transaction: $status';
  }
}
