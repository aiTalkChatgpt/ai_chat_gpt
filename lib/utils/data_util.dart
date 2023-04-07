import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseUtil {
  static late Database _database;
  final _databaseChangeController = StreamController<bool>.broadcast();
  Stream<bool> get databaseChangeStream => _databaseChangeController.stream;
  static final DatabaseUtil db = DatabaseUtil._();

  DatabaseUtil._();

  Future<Database> get database async {
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mydatabase.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Chat ("
              "id INTEGER PRIMARY KEY,"
              "content TEXT,"
              "type INTEGER"
              ")");
        });
  }

  // Insert Operation: Insert a record in table
  Future<int> insert(dynamic table, Map<String, dynamic> values) async {
    final db = await database;
    var result = db.insert(table, values);
    _databaseChangeController.add(true);
    return result;
  }

  // Update Operation: Update a record in table
  Future<int> update(dynamic table, Map<String, dynamic> values,
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    var result = db.update(table, values, where: where, whereArgs: whereArgs);
    return result;
  }

  // Delete Operation: Delete a record from table
  Future<int> delete(dynamic table, int id) async {
    final db = await database;
    var result = db.delete(table, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Get all records from table
  Future<List<Map<String, dynamic>>> queryAllRows(dynamic table) async {
    final db = await database;
    var result = await db.query(table);
    return result;
  }
}
