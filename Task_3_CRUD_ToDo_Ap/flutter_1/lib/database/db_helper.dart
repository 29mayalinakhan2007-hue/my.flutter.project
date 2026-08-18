import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/sample_data.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('studycards.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE flashcards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        category TEXT NOT NULL,
        hint TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE study_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_cards INTEGER NOT NULL,
        correct_cards INTEGER NOT NULL,
        study_time_minutes INTEGER NOT NULL,
        completed_at TEXT NOT NULL
      )
    ''');

    // Populate Sample Data
    for (final card in SampleData.initialCards) {
      await db.insert('flashcards', card.toMap());
    }
  }

  Future<int> insertFlashcard(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('flashcards', row);
  }

  Future<List<Map<String, dynamic>>> queryAllFlashcards() async {
    final db = await instance.database;
    return await db.query('flashcards', orderBy: 'id DESC');
  }

  Future<int> updateFlashcard(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update('flashcards', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteFlashcard(int id) async {
    final db = await instance.database;
    return await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllFlashcards() async {
    final db = await instance.database;
    return await db.delete('flashcards');
  }
}