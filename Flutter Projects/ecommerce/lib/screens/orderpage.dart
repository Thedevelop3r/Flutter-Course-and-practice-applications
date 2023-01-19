import 'package:flutter/material.dart';
import 'package:ecommerce/models/items_database_helper.dart';
import 'package:ecommerce/models/cart_model.dart';

class OrderPage extends StatefulWidget {
  OrderPage({Key? key, required this.userid, required this.isadmin})
      : super(key: key);
  bool isadmin;
  final int userid;
  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final db = ItemsDatabase.instance;
  List OrdersList = [];
  late final userid;
  late bool isadmin = false;

  @override
  void initState() {
    super.initState();
    userid = widget.userid;
    isadmin = widget.isadmin;

    UpdateList();
  }

  void UpdateList() async {
    if (isadmin) {
      UpdateOrderListAdmin();
    } else {
      UpdateOrderList();
    }
  }

  void UpdateOrderListAdmin() async {
    OrdersList = await db.readAllCartOrders();

    setState(() {});
  }

  void UpdateOrderList() async {
    print('update order list');

    OrdersList = await db.readAllCartOrdersByUser(0);
    for (var order in OrdersList) {
      print(order);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${isadmin ? 'Admin Panel - Orders' : 'Orders'}'),
        ),
        body: OrdersList.isEmpty
            ? Text('Loading')
            : ListView.builder(
                itemCount: OrdersList.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: isadmin
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    'Order Id: ${OrdersList[index].orderid}\nProduct ID: ${OrdersList[index].productid}\nUser ID: ${OrdersList[index].userid}\nOrdered Stock: ${OrdersList[index].orderstock}\nItem Price: ${OrdersList[index].itemprice}\$\nTotal Amount: ${OrdersList[index].bulktotalprice}\$'),
                                IconButton(
                                    onPressed: () async {
                                      int? id = OrdersList[index].orderid;
                                      final deletid =
                                          await db.deleteCartOrder(id!);

                                      OrdersList.removeAt(index);

                                      setState(() {});
                                    },
                                    icon: const Icon(
                                      Icons.delete_forever,
                                      size: 40.0,
                                      color: Colors.red,
                                    ))
                              ],
                            )
                          : Text(
                              'Order Id: ${OrdersList[index].orderid}\nProduct ID: ${OrdersList[index].productid}\nUser ID: ${OrdersList[index].userid}\nOrdered Stock: ${OrdersList[index].orderstock}\nItem Price: ${OrdersList[index].itemprice}\$\nTotal Amount: ${OrdersList[index].bulktotalprice}\$'),
                    ),
                  );
                }));
  }
}
