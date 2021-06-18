import 'package:flustars/flustars.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'entity/User.dart';

/// Describe: 数据库操作
/// Date: 3/23/21 10:14 AM
/// Path: tools/SqlManager.dart
class SqlManager {
  static const _VERSION = 2;

  static const _NAME = "address.db";

  static Database _database;

  static const USER = "User";
  static const RECORD = "Record";

  ///初始化
  static init() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, _NAME);
    _database = await openDatabase(
      path,
      version: _VERSION,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
        // await db.execute('set names utf8mb4;');
      },
      onCreate: (Database db, int version) async {
        var batch = db.batch();
        _createTableCompanyV1(batch);
        _updateTableCompanyV1toV2(batch);
        await batch.commit();
        print("Table is created");
        // LogUtil.v("onCreate===${await queryData(name: RECORD)}");
      },
      // 数据库升级回调
      onUpgrade: (Database database, int oldVersion, int newVersion) async {
        print("版本$oldVersion 升级到 $newVersion");
        Batch batch = database.batch();
        if (oldVersion == 1) {
          _updateTableCompanyV1toV2(batch);
        }
        await batch.commit();
        // LogUtil.v("onUpgrade===${await queryData(name: RECORD)}");
      },
      onDowngrade: onDatabaseDowngradeDelete,
    );
    // if (!await isTableExits(USER)) {
    //   // age INTEGER
    //   /// id address name privateKey assetsRecord earnings1 earnings2
    //   await _database.execute(
    //       'CREATE TABLE $USER (id INTEGER PRIMARY KEY, address TEXT, name TEXT,privateKey TEXT,isValora INTEGER,celo TEXT,celoAvailable TEXT,celoLocked TEXT,celoNonvoting TEXT,celoPending TEXT,cusd TEXT,ceur TEXT,rewards Memo,earningsName TEXT,earningsLogo TEXT,phoneNum TEXT,type INTEGER)');
    // }
    // if (!await isTableExits(RECORD)) {
    //   /// voteAll 投票所有记录
    //   await _database.execute(
    //       'CREATE TABLE $RECORD (id INTEGER PRIMARY KEY, address TEXT, assetsRecord Memo,earnings1 Memo,earnings2 Memo,earnings3 Memo,earnings4 Memo,earnings5 Memo,earnings6 Memo, allRecord Memo,rollOut Memo,receive Memo)');
    // }
    // LogUtil.v("queryData===${await queryData(name: RECORD)}");
  }

  ///创建数据库--初始版本
  static void _createTableCompanyV1(Batch batch) {
    batch.execute(
        'CREATE TABLE $USER (id INTEGER PRIMARY KEY, address TEXT, name TEXT,privateKey TEXT,isValora INTEGER,celo TEXT,celoAvailable TEXT,celoLocked TEXT,celoNonvoting TEXT,celoPending TEXT,cusd TEXT,ceur TEXT,rewards Memo,earningsName TEXT,earningsLogo TEXT,phoneNum TEXT,type INTEGER)');
    batch.execute(
        'CREATE TABLE $RECORD (id INTEGER PRIMARY KEY, address TEXT, assetsRecord Memo,earnings1 Memo,earnings2 Memo,earnings3 Memo,earnings4 Memo,earnings5 Memo,earnings6 Memo, allRecord Memo,rollOut Memo,receive Memo)');
  }

  ///更新数据库Version: 1->2.
  static void _updateTableCompanyV1toV2(Batch batch) {
    batch.execute('ALTER TABLE $RECORD ADD voteAll Memo');
    // batch.execute('ALTER TABLE $RECORD ADD COLUMN voteAll Memo');
  }

  ///判断表是否存在
  static Future<bool> isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database.rawQuery(
        "select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res != null && res.length > 0;
  }

  /// 添加数据
  static Future<int> addData(Map user) async {
    await getCurrentDatabase();
    return await _database.insert(USER, user);
  }

  /// 添加数据
  static Future<int> addRecordData(
      {String address, String key, String value}) async {
    await getCurrentDatabase();
    return await _database.rawInsert(
        "INSERT INTO $RECORD  (address,$key) VALUES (?, ?)",
        [address.toLowerCase(), value]);
  }

  /// 更新某一个字段
  static Future<int> updateFieldData(
      {String address, String key, String value, String name = USER}) async {
    await getCurrentDatabase();
    return await _database.rawUpdate(
        "UPDATE $name SET $key = ? WHERE address = ?",
        [value, address.toLowerCase()]);
  }

  /// 更新更多字段
  static Future<int> updateMoreFieldData(
      {String address,
      List<String> keys,
      List<dynamic> values,
      String name = USER}) async {
    if (keys.length > 0) {
      await getCurrentDatabase();
      values.add(address.toLowerCase());
      String field = "";
      for (int i = 0; i < keys.length; i++) {
        field += "${keys[i]} = ?,";
      }
      field = field.substring(0, field.length - 1);
      return await _database.rawUpdate(
          "UPDATE $name SET $field WHERE address = ?", values);
    } else {
      return -1;
    }
  }

  /// 查询数据
  static Future<List<Map>> queryData({String name = USER}) async {
    // db.rawQuery
    await getCurrentDatabase();
    return await _database.rawQuery('SELECT * FROM $name');
  }

  /// 查询当前地址数据
  static Future<List<Map>> queryAddressData(String address,
      {String name = USER}) async {
    // db.rawQuery
    await getCurrentDatabase();
    List<Map> list = await _database
        .query(name, where: 'address = ?', whereArgs: [address.toLowerCase()]);
    return list;
  }

  /// 删除数据
  static Future<int> deleteData(String address, {String name = USER}) async {
    await getCurrentDatabase();
    return await _database
        .delete(name, where: 'address = ?', whereArgs: [address.toLowerCase()]);
  }

  ///获取当前数据库对象
  static Future<Database> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
