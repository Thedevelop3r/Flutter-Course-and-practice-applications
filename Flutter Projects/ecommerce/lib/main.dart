import 'package:ecommerce/screens/orderpage.dart';
import 'package:ecommerce/screens/updatestock.dart';
import 'package:ecommerce/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/items.dart';
import 'package:ecommerce/components/navbars.dart';
import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/constants.dart';
import 'package:ecommerce/models/items_database_helper.dart';
import 'package:ecommerce/models/user_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // updateList();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Store',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        accentColor: const Color(0xffFF9800),
        primaryColorLight: Colors.orange[100],
      ),
      home: const MyHomePage(),
    );
  }
}
/*const MyHomePage(title: 'E commerce Store')*/

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// here is cart array
  bool searchbarvisible = false;
  String textinput = '';
  late TextEditingController _controller;
  dynamic isAdmin;
  bool loading = false;

  User userdata =
      User(Username: 'Guesst', Password: '123456', is_admin: true, UserId: 200);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    isAdmin = true;
    updateList();
  }

  void updateList() async {
    print('Update List Start ${AllItems}');
    // for (Items item in AllItems) {
    //   print('${item}');
    // }
    setState(() {
      loading = true;
      print('Loading $loading');
    });
    final db = await ItemsDatabase.instance;
    List<Items> allUpdatedItems = await db.readAllItems();
    if (allUpdatedItems.isEmpty) {
      for (int a = 0; a < AllItems.length; a++) {
        print("Item ${await db.create(AllItems[a])} Added successfully \n");
      }
    } else {
      AllItems = allUpdatedItems;
    }

    setState(() {
      loading = false;
      print('Loading $loading');
    });
    print('Update List End ${AllItems}');
    // for (Items item in AllItems) {
    //   print('${item}');
    // }
  }

  List<Items> filterList(List<Items> list, String type) {
    List<Items> newFilteredList = [];
    for (Items item in list) {
      if (item.itemType == type) {
        newFilteredList.add(item);
      }
    }
    return newFilteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: isAdmin == true
          ? Drawer(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50)),
              ),
              elevation: 0.2,
              backgroundColor: Theme.of(context).primaryColorLight,
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                    child: const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  ListTile(
                    title: const Text('Update Stock & Price'),
                    onTap: () async {
                      // Update the state of the app.
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UpdateStock()));

                      Navigator.pop(context);

                      updateList();
                    },
                  ),
                  ListTile(
                    title: const Text('Create Item'),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                    },
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: SizedBox(
          height: 50.0,
          child: Center(
              child:
                  Text('${userdata.Username != null ? 'Store' : 'no store'}')),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                searchbarvisible == false
                    ? searchbarvisible = true
                    : searchbarvisible = false;
              });
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                /// this should open your user processed ordered
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderPage(userid: 0, isadmin: isAdmin)));
              },
              icon: Icon(Icons.shopping_cart)),
          IconButton(
            onPressed: () async {
              User pushbackdata = await Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));

              isAdmin = pushbackdata.is_admin;

              setState(() {});
              print('ISADMIN $isAdmin');
            },
            icon: const Icon(Icons.login),
            iconSize: 40.0,
            color: Colors.green,
          ),
        ],
      ),
      body: loading == true
          ? const SizedBox(
              height: 300,
              child: Text(
                "loading...",
                style: TextStyle(fontSize: 30.0),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Visibility(
                        visible: searchbarvisible,
                        child: TextField(
                          controller: _controller,
                          onChanged: (String value) async {
                            textinput = value;

                            for (var item in AllItems) {
                              if (textinput == item.name) {
                                print("Item Found\n");
                                textinput = '';
                                _controller.text = '';
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CartPage(
                                              itemid: item.id,
                                            )));

                                setState(() {
                                  searchbarvisible = false;
                                });
                              }
                            }
                          },
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Search Item',
                          ),
                        ),
                      ),
                      FruitNavBar(
                          ItemsList: filterList(AllItems, ItemType.Fruit),
                          Title: 'Fruits',
                          itemType: ItemType.Fruit,
                          onPress: () {
                            updateList();
                          }),
                      FruitNavBar(
                          ItemsList: filterList(AllItems, ItemType.Vegitable),
                          Title: 'Vegetable',
                          itemType: ItemType.Vegitable,
                          onPress: () {
                            updateList();
                          }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                const OtherItems()
              ],
            ),
    );
  }
}
