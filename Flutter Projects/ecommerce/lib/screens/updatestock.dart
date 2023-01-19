import 'package:flutter/material.dart';
import 'package:ecommerce/models/items.dart';
import 'package:ecommerce/screens/stockupdatepage.dart';
import 'package:ecommerce/models/items_database_helper.dart';

class UpdateStock extends StatefulWidget {
  const UpdateStock({Key? key}) : super(key: key);

  @override
  State<UpdateStock> createState() => _UpdateStockState();
}

class _UpdateStockState extends State<UpdateStock> {
  final db = ItemsDatabase.instance;

  void updateList() async {
    print('Update List => start');
    List<Items> allUpdatedItems = await db.readAllItems();
    AllItems = allUpdatedItems;
    print('update List => close');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text('Admin'),
      ),
      body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemCount: AllItems.length,
          itemBuilder: (context, int index) {
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StockUpdateBox(
                              itemid: index,
                            )));
                updateList();
              },
              child: Container(
                margin: EdgeInsets.only(top: 10.0),
                width: 80.0,
                height: 100.0,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 30,
                        backgroundImage: AssetImage(AllItems[index].itemImage),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Name: ${AllItems[index].name}\nPrice: ${AllItems[index].price}\$\nStock: ${AllItems[index].stock}',
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
