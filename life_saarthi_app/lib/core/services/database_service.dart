import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  DatabaseService._();

  static final DatabaseService instance = DatabaseService._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'life_saarthi.db');

    return openDatabase(
      path,

      // CHANGED:
      // Database version increased from 1 to 2
      // because completed_at was added.
      version: 2,

      onCreate: _onCreate,

      // CHANGED:
      // Handles existing installations that already
      // have version 1 of the database.
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        priority TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        due_date TEXT,
        completed_at TEXT
      )
    ''');
  }

  // CHANGED:
  // Migration from database version 1 → 2.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE tasks ADD COLUMN completed_at TEXT');
    }
  }
}
