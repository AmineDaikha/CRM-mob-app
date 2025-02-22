import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


class DatabaseHelper {
  static final _databaseName = "my_database.db";
  static final _databaseVersion = 1;

  static final table = 'itinerary';
  static final columnId = '_id';
  static final columnSalCode = 'salCode';
  static final columnEtbCode = 'etbCode';
  static final columnDate = 'date_op';
  static final columnLat = 'col_lat';
  static final columnLon = 'col_lon';


  static final tableUser = 'user';
  static final columnUserId = '_id';
  static final columnUserPassword = 'password';
  static final columnUserSociete = 'societe';



  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;
  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $columnSalCode TEXT NOT NULL,
            $columnEtbCode TEXT NOT NULL,   
            $columnDate TEXT NOT NULL,
            $columnLat TEXT NOT NULL,
            $columnLon TEXT NOT NULL
          )
          ''');
    await db.execute('''
          CREATE TABLE $tableUser (
            $columnUserId TEXT PRIMARY KEY,
            $columnUserPassword TEXT NOT NULL,
            $columnUserSociete TEXT NOT NULL
          )
          ''');
  }

  // Helper methods

  // Insert a row in the database
  Future<int> insert(Map<String, dynamic> row) async {
    Database? db = await instance.database!;
    return await db!.insert(table, row);
  }

  // Insert a row in the database
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database? db = await instance.database!;
    return await db!.insert(tableUser, row);
  }

  // Query all rows in the database
  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database? db = await instance.database!;
    return await db!.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllUserRows() async {
    Database? db = await instance.database!;
    return await db!.query(tableUser);
  }

  // Update a row in the database
  Future<int> update(Map<String, dynamic> row) async {
    Database? db = await instance.database!;
    int id = row[columnId];
    return await db!.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  // Delete a row in the database
  Future<int> delete(int id) async {
    Database? db = await instance.database!;
    return await db!.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
  // Delete all rows in the database
  Future<int> deleteAll() async {
    Database? db = await instance.database!;
    return await db!.delete(table);
  }
}
