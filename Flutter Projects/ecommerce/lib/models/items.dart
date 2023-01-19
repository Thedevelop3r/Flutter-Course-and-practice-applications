import 'package:ecommerce/constants.dart';

final String tableItems = 'items';

class ItemFields {
  static final List<String> values = [
    id,
    name,
    itemimage,
    itemtype,
    price,
    stock
  ];

  static final String id = '_id';
  static final String name = 'name';
  static final String itemimage = 'itemimage';
  static final String itemtype = 'itemtype';
  static final String price = 'price';
  static final String stock = 'stock';
}

class Items {
  final int? id;
  final String name;
  final String itemImage;
  late final int price;
  final String itemType;
  late final int stock;

  Items(
      {this.id,
      required this.name,
      required this.itemImage,
      required this.price,
      required this.itemType,
      required this.stock});

  Map<String, Object?> toJson() => {
        ItemFields.id: id,
        ItemFields.name: name,
        ItemFields.itemimage: itemImage,
        ItemFields.itemtype: itemType,
        ItemFields.price: price,
        ItemFields.stock: stock
      };

  static Items fromJson(Map<String, Object?> json) => Items(
      id: json[ItemFields.id] as int?,
      name: json[ItemFields.name] as String,
      itemImage: json[ItemFields.itemimage] as String,
      itemType: json[ItemFields.itemtype] as String,
      price: json[ItemFields.price] as int,
      stock: json[ItemFields.stock] as int);

  Items copy(
          {int? id,
          String? name,
          String? itemImage,
          int? price,
          String? itemType,
          int? stock}) =>
      Items(
          id: id ?? this.id,
          name: name ?? this.name,
          itemImage: itemImage ?? this.itemImage,
          itemType: itemType ?? this.itemType,
          price: price ?? this.price,
          stock: stock ?? this.stock);

  @override
  String toString() {
    return 'ItemID: $id, ItemName: $name, ItemPrice: $price, ItemStock: $stock';
  }
}

List<Items> AllItems = [
  Items(
      id: 0,
      name: 'Banana',
      itemImage: 'assets/images/banana.png',
      itemType: ItemType.Fruit,
      price: 13,
      stock: 10),
  Items(
      id: 1,
      name: 'Mango',
      price: 29,
      itemType: ItemType.Fruit,
      itemImage: 'assets/images/mango.png',
      stock: 10),
  Items(
      id: 2,
      name: 'Orange',
      price: 14,
      itemType: ItemType.Fruit,
      stock: 10,
      itemImage: 'assets/images/orange.png'),
  Items(
      id: 3,
      name: 'Apple',
      price: 14,
      stock: 10,
      itemType: ItemType.Fruit,
      itemImage: 'assets/images/apple.png'),
  Items(
      id: 4,
      name: 'Strawberry',
      itemType: ItemType.Fruit,
      price: 15,
      stock: 10,
      itemImage: 'assets/images/strawberry.png'),
  Items(
      id: 5,
      name: 'Melon',
      price: 19,
      stock: 10,
      itemType: ItemType.Fruit,
      itemImage: 'assets/images/melon.png'),
  Items(
      id: 6,
      name: 'Chili',
      price: 4,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/chili.png'),
  Items(
      id: 7,
      name: 'Cabbage',
      price: 12,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/cabbage.png'),
  Items(
      id: 8,
      name: 'Carrot',
      price: 3,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/carrot.png'),
  Items(
      id: 9,
      name: 'Cauliflower',
      price: 8,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/cauliflower.png'),
  Items(
      id: 10,
      name: 'Peas',
      price: 3,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/peas.png'),
  Items(
      id: 11,
      name: 'Tomato',
      price: 4,
      stock: 10,
      itemType: ItemType.Vegitable,
      itemImage: 'assets/images/tomato.png'),
];
