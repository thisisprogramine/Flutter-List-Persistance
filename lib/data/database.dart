import 'package:list_persistence/model/Feed.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FeedDatabase {
  static final FeedDatabase instance = FeedDatabase._init();

  static Database? _database;

  FeedDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('feeds.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT';
    // final boolType = 'BOOLEAN NOT NULL';
    // final integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE $tableFeed ( 
  ${FeedFields.id} $idType, 
  ${FeedFields.name} $textType,
  ${FeedFields.picture} $textType,
  ${FeedFields.age} $textType,
  ${FeedFields.country} $textType
  )
''');
  }

  Future<Feed> create(Feed feed) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableFeed, feed.toJson());
    return feed.copy(id: id);
  }

  Future<Feed> readNote(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableFeed,
      columns: FeedFields.values,
      where: '${FeedFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Feed.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Feed>> readAllNotes() async {
    final db = await instance.database;

    const orderBy = '${FeedFields.id} ASC';
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy');

    final result = await db.query(tableFeed, orderBy: orderBy);

    return result.map((json) => Feed.fromJson(json)).toList();
  }

  Future<int> update(Feed feed) async {
    final db = await instance.database;

    return db.update(
      tableFeed,
      feed.toJson(),
      where: '${FeedFields.id} = ?',
      whereArgs: [feed.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableFeed,
      where: '${FeedFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
