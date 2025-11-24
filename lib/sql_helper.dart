import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SQLHelper {
  static Future<void> createTables(Database database) async {
    await database.execute("""CREATE TABLE items(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )""");
  }

  static Future<Database> db() async {
    var databasePath = await getDatabasesPath();
    String path = join(databasePath, "demo.db");
    return openDatabase(
      path,
      version: 1,
      onCreate: (Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> createItem(String title, String description) async {
    final db = await SQLHelper.db();
    final data = {'title': title, 'description': description};
    final id = await db.insert(
      "items",
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query("items", orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query("items", where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
    int id,
    String title,
    String description,
  ) async {
    final db = await SQLHelper.db();

    final data = {
      'title': title,
      'description': description,
      'createdAt': DateTime.now().toString(),
    };

    final result = await db.update(
      "items",
      data,
      where: "id = ?",
      whereArgs: [id],
    );

    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<List<Map<String, dynamic>>> runDbTestSequence() async {
    debugPrint("======== Starting Database Test Sequence here ========");

    // 1. CREATE: Insert a new item (ID will likely be 1, if empty)
    final int createdId = await SQLHelper.createItem("Initial Test Title", "Description for initial item.");

    // 3. UPDATE: Modify the second item
    await SQLHelper.updateItem(2, "UPDATED Title", "nouvelle description");

    // 4. DELETE: Remove the second item
    await SQLHelper.deleteItem(2);

    // 5. READ: Get all remaining items
    final List<Map<String, dynamic>> journals = await SQLHelper.getItems();

    debugPrint("\n==================================");
    debugPrint("== Final Remaining Items (READ ALL) ==");
    for (int i = 0; i < journals.length; i++) {
      debugPrint('${journals[i]['id'].toString()}: ${journals[i]['title']}');
    }
    debugPrint("===================================\n");

    debugPrint("======== Database Test Sequence Complete ========");

    return journals;
  }
}
