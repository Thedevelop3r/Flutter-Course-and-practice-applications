import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:notepad_pro/modules/notepad_module.dart';

class NOTES_DATABASE {
  static final NOTES_DATABASE instance = NOTES_DATABASE._init();
  static Database? _database;
  NOTES_DATABASE._init();

  ///  Class Methods :

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('Notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbpath = await getDatabasesPath();
    final path = join(dbpath, filePath);
    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future _onCreateDB(Database db, int version) async {
    /// for items type
    final INT_PRIMARY_AUTO = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final TEXT_NOT_NULL = 'TEXT NOT NULL';
    final INT_NOT_NULL = 'INTEGER NOT NULL';
    await db.execute(''' 
      CREATE TABLE $NOTEPAD_TABLE_NAME (
      ${NOTEPAD_FIELDS.id} $INT_PRIMARY_AUTO,
      ${NOTEPAD_FIELDS.title} $TEXT_NOT_NULL,
      ${NOTEPAD_FIELDS.paragraph} $TEXT_NOT_NULL
      )
      ''');
  }

  /// for NOTEPAD methods
  Future<NOTE> create_Note(NOTE note) async {
    final db = await instance.database;
    final id = await db.insert(NOTEPAD_TABLE_NAME, note.toJson());
    return note.copy(Note_id: id);
  }

  Future<NOTE> read_Note(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      NOTEPAD_TABLE_NAME,
      columns: NOTEPAD_FIELDS.values,
      where: '${NOTEPAD_FIELDS.id} = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return NOTE.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found !');
    }
  }

  Future<List<NOTE>> read_All_Notes() async {
    final db = await instance.database;
    final result = await db.query(NOTEPAD_TABLE_NAME);
    return result.map((json) => NOTE.fromJson(json)).toList();
  }

  Future<int> update_Note(NOTE note) async {
    final db = await instance.database;

    return db.update(NOTEPAD_TABLE_NAME, note.toJson(),
        where: '${NOTEPAD_FIELDS.id} = ?', whereArgs: [note.id]);
  }

  Future<int> delete_Note(int? id) async {
    final db = await instance.database;

    return await db.delete(NOTEPAD_TABLE_NAME,
        where: '${NOTEPAD_FIELDS.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
