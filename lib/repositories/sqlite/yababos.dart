import 'package:sqflite/sqflite.dart';

class YababosSqlite {
  static String path;

  static final int version = 1;

  static final String onCreate = '''
CREATE TABLE "transactions" (
	"id"	INTEGER,
	"fromWallet"	INTEGER,
	"toWallet"	INTEGER,
	"amount"	REAL,
	"date"	INTEGER,
	"description"	TEXT,
	PRIMARY KEY("id")
);
CREATE TABLE "tags" (
	"name"	TEXT,
	"color"	INTEGER NOT NULL,
	PRIMARY KEY("name")
);
CREATE TABLE "transaction_tags" (
	"transactionId"	INTEGER,
	"tag"	TEXT,
	FOREIGN KEY("transactionId") REFERENCES "transactions"("id"),
	FOREIGN KEY("tag") REFERENCES "tags"("name")
);
CREATE TABLE "wallet" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL,
	"curreny"	TEXT NOT NULL,
	"amount"	REAL NOT NULL DEFAULT 0,
	PRIMARY KEY("id")
);
CREATE TABLE "settings" (
	"name"	TEXT,
	"value"	BLOB,
	PRIMARY KEY("name")
);
  ''';

  static final String onUpgrade = '''

  ''';

  static Future<Database> getDatabase() async {
    return openDatabase(
      path,
      version: version,
      onCreate: (db, version) => db.execute(onCreate),
      onUpgrade: (db, oldVersion, newVersion) => db.execute(onUpgrade),
      singleInstance: true,
    );
  }
}
