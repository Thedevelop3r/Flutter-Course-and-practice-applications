import 'package:ecommerce/screens/cart.dart';
import 'package:ecommerce/models/items.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/constants.dart';

class FruitNavBar extends StatelessWidget {
  FruitNavBar(
      {Key? key,
      required this.Title,
      required this.ItemsList,
      required this.onPress,
      required this.itemType})
      : super(key: key);

  final String Title;
  final itemType;
  final List<Items> ItemsList;
  final Function onPress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                Title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 90.0,
                      crossAxisSpacing: 10.0,
                      mainAxisExtent: 190.0,
                      mainAxisSpacing: 5.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: ItemsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CartPage(
                                    itemid: itemType == ItemType.Vegitable
                                        ? index + 6
                                        : index)));

                        onPress();
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Container(
                                    height: 40.0,
                                    width: 40.0,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2.0, color: Colors.grey),
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: Text(
                                        '${ItemsList[index].price}\$',
                                        style: const TextStyle(
                                            fontSize: 16.0,
                                            color: Colors.purple,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.9),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 30,
                                    backgroundImage:
                                        AssetImage(ItemsList[index].itemImage),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              ItemsList[index].name,
                              style: const TextStyle(
                                color: Colors.black45,
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

/// used
class OtherItems extends StatelessWidget {
  const OtherItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: TapContainer(
              title: 'Survival', assetloc: 'assets/images/survival.png'),
        ),
        Expanded(
          child: TapContainer(
              title: 'Tool Box', assetloc: 'assets/images/toolbox.png'),
        ),
      ],
    );
  }
}

/// none used
class ItemsContainer extends StatelessWidget {
  final String title;
  final String assetlocation;
  const ItemsContainer({required this.title, required this.assetlocation});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 9.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 30,
            backgroundImage: AssetImage(
              assetlocation,
            ),
          ),
          // const SizedBox(
          //   height: 6.0,
          // ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class TapContainer extends StatelessWidget {
  //Function onTap;
  final String title;
  final String assetloc;
  TapContainer({required this.title, required this.assetloc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('tap');
      },
      child: Container(
        //height: 100.0,
        decoration: BoxDecoration(
            color: Color(0xffFFCCBC),
            border: Border.all(
                color: Color(0xffBDBDBD),
                width: 0.2,
                style: BorderStyle.solid)),
        //margin: const EdgeInsets.only(top: 25.0),
        child: ItemsContainer(title: title, assetlocation: assetloc),
      ),
    );
  }
}
