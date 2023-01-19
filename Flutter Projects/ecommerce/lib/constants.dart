class ItemType {
  static String Fruit = 'fruit';
  static String Vegitable = 'vegetable';
  static String Survival = 'survival';
  static String ToolBox = 'toolbox';
}

class CartData {
  final itemid;
  final count;
  CartData(this.itemid, this.count);
}
