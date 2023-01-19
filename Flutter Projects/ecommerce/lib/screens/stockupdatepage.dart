import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/items.dart';
import 'package:flutter/widgets.dart';
import 'package:ecommerce/models/items_database_helper.dart';

class StockUpdateBox extends StatefulWidget {
  final itemid;

  const StockUpdateBox({Key? key, this.itemid}) : super(key: key);

  @override
  State<StockUpdateBox> createState() => _StockUpdateBoxState();
}

class _StockUpdateBoxState extends State<StockUpdateBox> {
  int itemid = 0;
  var itemType;
  int stockCount = 0;
  int priceCount = 0;
  late Items item;
  late final db;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    itemid = widget.itemid;
    itemType = AllItems[itemid].itemType;
    getItemById(itemid);
    updateList();
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
    return item.price * stockCount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
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
                    Padding(
                        padding: const EdgeInsets.only(
                            right: 40.0, top: 10.0, bottom: 5.0),
                        child: Text(
                          "Total price ${calculatedPrice()}\$",
                          style: TextStyle(color: Colors.green, fontSize: 25.0),
                        )),
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
                              "$stockCount",
                              style: const TextStyle(
                                  color: Colors.black45, fontSize: 30.0),
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Update Stock',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: IconButton(
                            iconSize: 40.0,
                            color: Colors.red,
                            alignment: Alignment.center,
                            onPressed: () {
                              setState(() {
                                stockCount--;
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
                                stockCount++;
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
                                  (item.stock + stockCount) >= 0) {
                                int _newitemstock = item.stock + stockCount;
                                final newItem = item.copy(stock: _newitemstock);
                                final db = ItemsDatabase.instance;
                                final iditem = await db.update(newItem);
                                item = await db.readItem(itemid);
                                stockCount = 0;
                                setState(() {
                                  print('setStateTriggered');
                                });

                                if (iditem == 1) {
                                  print(
                                      "item ${item.toJson()}  Update Successfull");
                                } else {
                                  print('Update Failed');
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.storage,
                              // size: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            right: 40.0, top: 10.0, bottom: 5.0),
                        child: Text(
                          "New Price ${priceCount}\$",
                          style: TextStyle(color: Colors.green, fontSize: 25.0),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Update Price',
                          style: TextStyle(fontSize: 20.0),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: IconButton(
                            iconSize: 40.0,
                            color: Colors.red,
                            alignment: Alignment.center,
                            onPressed: () {
                              setState(() {
                                priceCount--;
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
                                priceCount++;
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
                              if (item.price >= 0 &&
                                  (item.price + priceCount) >= 0) {
                                int _newitemstock = item.price + priceCount;
                                final newItem = item.copy(price: _newitemstock);
                                final db = ItemsDatabase.instance;
                                final iditem = await db.update(newItem);
                                item = await db.readItem(itemid);
                                priceCount = 0;
                                setState(() {
                                  print('setStateTriggered');
                                });

                                if (iditem == 1) {
                                  print(
                                      "item ${item.toJson()}  Update Successfull");
                                } else {
                                  print('Update Failed');
                                }
                              }
                            },
                            icon: const Icon(
                              Icons.price_change,
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
