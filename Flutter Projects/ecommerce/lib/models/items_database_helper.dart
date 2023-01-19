import 'package:ecommerce/models/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ecommerce/models/items.dart';
import 'package:ecommerce/models/cart_model.dart';

class ItemsDatabase {
  static final ItemsDatabase instance = ItemsDatabase._init();
  static Database? _database;
  ItemsDatabase._init();

  ///  Class Methods :

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('userdata.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    /// for items type
    final idtype = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final TextType = 'TEXT NOT NULL';
    final IntType = 'INTEGER NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    await db.execute(''' 
      CREATE TABLE $tableItems (
      ${ItemFields.id} $idtype,
      ${ItemFields.name} $TextType,
      ${ItemFields.itemimage} $TextType,
      ${ItemFields.itemtype} $TextType,
      ${ItemFields.price} $IntType,
      ${ItemFields.stock} $IntType
      )
      ''');

    /// for user type
    await db.execute('''
      CREATE TABLE $tableUsers(
      ${UserFields.id} $idtype,
      ${UserFields.username} $TextType,
      ${UserFields.password} $TextType,
      ${UserFields.is_admin} $boolType
      )
      ''');

    /// for cart
    await db.execute('''
      CREATE TABLE $carttable(
      ${CartField.orderid} $idtype,
      ${CartField.userid} $IntType,
      ${CartField.productid} $IntType,
      ${CartField.orderstock} $IntType,
      ${CartField.itemprice} $IntType,
      ${CartField.bulktotalprice} $IntType,
      ${CartField.status} $TextType
      )
      ''');
  }

  /// for cart methods
  Future<Cart> createCartOrder(Cart order) async {
    final db = await instance.database;
    final orderId = await db.insert(carttable, order.toJson());
    return order.copy(orderid: orderId);
  }

  Future<Cart> readCartOrder(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      carttable,
      columns: CartField.values,
      where: '${CartField.orderid} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Cart.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found !');
    }
  }

  Future<List<Cart>> readAllCartOrdersByUser(int userid) async {
    final db = await instance.database;

    final maps = await db.query(
      carttable,
      columns: CartField.values,
      where: '${CartField.userid} = ?',
      whereArgs: [userid],
    );
    if (maps.isNotEmpty) {
      return maps.map((json) => Cart.fromJson(json)).toList();
    } else {
      throw Exception('ID $userid not found !');
    }
  }

  Future<List<Cart>> readAllCartOrders() async {
    final db = await instance.database;
    final result = await db.query(carttable);
    return result.map((json) => Cart.fromJson(json)).toList();
  }

  Future<int> updateCartOrder(Cart order) async {
    final db = await instance.database;

    return db.update(carttable, order.toJson(),
        where: '${CartField.orderid} = ?', whereArgs: [order.orderid]);
  }

  Future<int> deleteCartOrder(int orderid) async {
    final db = await instance.database;

    return await db.delete(carttable,
        where: '${CartField.orderid} = ?', whereArgs: [orderid]);
  }

  /// for items methods
  Future<Items> create(Items item) async {
    final db = await instance.database;
    final id = await db.insert(tableItems, item.toJson());
    return item.copy(id: id);
  }

  Future<Items> readItem(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableItems,
      columns: ItemFields.values,
      where: '${ItemFields.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Items.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found !');
    }
  }

  Future<List<Items>> readAllItems() async {
    final db = await instance.database;
    final result = await db.query(tableItems);
    return result.map((json) => Items.fromJson(json)).toList();
  }

  Future<int> update(Items item) async {
    final db = await instance.database;

    return db.update(tableItems, item.toJson(),
        where: '${ItemFields.id} = ?', whereArgs: [item.id]);
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db
        .delete(tableItems, where: '${ItemFields.id} = ?', whereArgs: [id]);
  }

  /// for user methods

  Future<User> createUser(User user) async {
    final db = await instance.database;
    final id = await db.insert(tableUsers, user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.fail);
    return user.copy(UserId: id);
  }

  Future<User> readUser(String user) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
      where: '${UserFields.username} = ?',
      whereArgs: [user],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('User-ID $user not found !');
    }
  }

  Future<List<User>> readAllUsers() async {
    final db = await instance.database;
    final result = await db.query(tableUsers);
    return result.map((json) => User.fromJson(json)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;

    return db.update(tableUsers, user.toJson(),
        where: '${UserFields.id} = ?', whereArgs: [user.UserId]);
  }

  Future<int> deleteUser(String username) async {
    final db = await instance.database;

    return await db.delete(tableUsers,
        where: '${UserFields.username} = ?', whereArgs: [username]);
  }

  Future<User> userAuth(String username, String password) async {
    final db = await instance.database;

    final maps = await db.query(
      tableUsers,
      columns: UserFields.values,
      where: '${UserFields.username} = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      throw Exception('User-ID $username not found !');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
