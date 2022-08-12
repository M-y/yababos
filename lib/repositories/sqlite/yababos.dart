import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class YababosSqlite {
  static String? path;

  static final int version = 1;

  static final List<String> onCreate = List.from({
    '''
CREATE TABLE "transactions" (
	"id"	INTEGER,
	"fromWallet"	INTEGER NOT NULL,
	"toWallet"	INTEGER NOT NULL,
	"amount"	REAL NOT NULL,
	"date"	INTEGER NOT NULL,
	"description"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''',
    '''
CREATE TABLE "tags" (
	"name"	TEXT,
	"color"	INTEGER NOT NULL,
	PRIMARY KEY("name")
);
''',
    '''
CREATE TABLE "transaction_tags" (
	"transactionId"	INTEGER NOT NULL,
	"tag"	TEXT NOT NULL,
	FOREIGN KEY("transactionId") REFERENCES "transactions"("id"),
	FOREIGN KEY("tag") REFERENCES "tags"("name")
);
''',
    '''
CREATE TABLE "wallets" (
	"id"	INTEGER,
	"name"	TEXT NOT NULL,
	"curreny"	TEXT NOT NULL,
	"amount"	REAL NOT NULL DEFAULT 0,
	PRIMARY KEY("id" AUTOINCREMENT)
);
''',
    '''
CREATE TABLE "settings" (
	"name"	TEXT,
	"value"	BLOB,
	PRIMARY KEY("name")
);
  '''
  });

  static final String onUpgrade = '''

  ''';

  static Future<Database> getDatabase() async {
    if (path == null) path = join(await getDatabasesPath(), 'yababos.db');

    return await openDatabase(
      path!,
      version: version,
      onCreate: (Database db, int version) async {
        for (String createSql in onCreate) {
          await db.execute(createSql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async =>
          await db.execute(onUpgrade),
      singleInstance: true,
    );
  }
}
