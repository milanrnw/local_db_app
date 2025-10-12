import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DbHelper {
  //singleton (only one instance will be created throughout the app)
  DbHelper._();

  //memory allocated in runtime, use same object everywhere.
  static final DbHelper getInstance = DbHelper._();

  // table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SRNO = "sr_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  //open db (from path if exist else create db)
  Future<Database> getDB() async {
    myDB = myDB ?? await openDB();
    return myDB!;

    // if (myDB != null) {
    //   return myDB!;
    // } else {
    //   myDB = await openDB();
    //   return myDB!;
    // }
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "noteDB.db");
    return await openDatabase(
      dbPath,
      onCreate: (db, version) {
        //create all tables here
        db.execute(
          "create table $TABLE_NOTE ($COLUMN_NOTE_SRNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)",
        );
      },
      version: 1,
    );
  }

  // all queries
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowsAffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });

    return rowsAffected > 0;
  }

  //Reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();
    //select * from note
    List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
    return mData;
  }

  //update data
  Future<bool> updateNote({
    required String mTitle,
    required String mDesc,
    required int srno,
  }) async {
    var db = await getDB();
    int rowsAffected = await db.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    }, where: "$COLUMN_NOTE_SRNO = $srno");
    return rowsAffected > 0;
  }

  //delete note
  Future<bool> deleteNote({required int srno}) async {
    var db = await getDB();
    int rowsAffected = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SRNO = $srno",
    );
    return rowsAffected>0;
  }
}
