import 'package:flutter/material.dart';
import 'package:ecommerce/models/items.dart';
import 'package:ecommerce/models/items_database_helper.dart';
import 'package:ecommerce/models/cart_model.dart';

class CartPage extends StatefulWidget {
  final itemid;
  const CartPage({Key? key, this.itemid}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int itemid = 0;
  //var itemType;
  int count = 1;
  bool loading = false;
  late Items item;
  late final db;

  @override
  void initState() {
    super.initState();
    itemid = widget.itemid;
    getItemById(itemid);
    updateList();
    // itemType = item.itemType;
  }

  void getItemById(int id) async {
    print('getItemBy ID => start');
    setState(() {
      loading = true;
    });
    final db = ItemsDatabase.instance;
    item = await db.readItem(id);
    print(item);

    setState(() {
      loading = false;
    });
    print('getItemBy ID => close');
  }

  void updateList() async {
    print('Update List => start');
    db = ItemsDatabase.instance;
    List<Items> allUpdatedItems = await db.readAllItems();
    AllItems = allUpdatedItems;
    print('update List => close');
  }

  int calculatedPrice() {
    return item.price * count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: loading == true
          ? Container(
              height: 300,
              child: Text(
                "loading...",
                style: TextStyle(fontSize: 30.0),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
// height: 100.0,
                      child: Text(
                        "${item.name}",
                        style: const TextStyle(
                            fontSize: 50.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black45),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${item.price}\$',
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 30.0,
                                letterSpacing: 0.9),
                          ),
                        ),
                        Image(
                          image: AssetImage(item.itemImage),
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.fill,
                        ),
                      ],
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, top: 10.0, bottom: 5.0),
                            child: Text(
                              "Stock: ${item.stock}",
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 18.0),
                            )),
                        Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, top: 10.0, bottom: 5.0),
                            child: Text(
                              "$count",
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 30.0),
                            )),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            right: 40.0, top: 10.0, bottom: 5.0),
                        child: Text(
                          "${calculatedPrice()}\$",
                          style: TextStyle(color: Colors.green, fontSize: 30.0),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: IconButton(
                            iconSize: 40.0,
                            color: Colors.red,
                            alignment: Alignment.center,
                            onPressed: () {
                              setState(() {
                                if (count > 1) {
                                  count--;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.indeterminate_check_box_outlined,
                              // size: 40.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: IconButton(
                            iconSize: 40.0,
                            color: Colors.green,
                            alignment: Alignment.center,
                            onPressed: () {
                              setState(() {
                                if (count < AllItems[itemid].stock) {
                                  count++;
                                }
                              });
                            },
                            icon: const Icon(
                              Icons.add,
                              // size: 40.0,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: IconButton(
                            iconSize: 40.0,
                            color: Colors.blue,
                            alignment: Alignment.center,
                            onPressed: () async {
                              if (item.stock >= 0 &&
                                  (item.stock - count) >= 0) {
                                int _newitemstock = item.stock - count;
                                final newItem = item.copy(stock: _newitemstock);
                                final db = ItemsDatabase.instance;
                                final iditem = await db.update(newItem);
                                item = await db.readItem(itemid);
                                // final int totalprice = ;
                                print('${calculatedPrice()}');
                                final Cart newOrder = Cart(
                                    userid: 0,
                                    productid: itemid,
                                    orderstock: count,
                                    itemprice: item.price,
                                    bulktotalprice: (item.price * count),
                                    status: 'Successfull');
                                // print('After Total Price ${newOrder}');

                                final orderID =
                                    await db.createCartOrder(newOrder);
                                final finalorder =
                                    newOrder.copy(orderid: orderID.orderid);

                                if (iditem == 1) {
                                  print(
                                      "item ${item.toJson()}  Transaction Successful");
                                  // print('order number $orderID');
                                  print('order object $finalorder');
                                } else {
                                  print('Transaction Failed');
                                }
                              }

                              setState(() {
                                count = 0;
                              });
                            },
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              color: Colors.deepPurple,
                              // size: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
