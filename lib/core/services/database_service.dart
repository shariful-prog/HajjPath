import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'location_tracking.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE location_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        latitude REAL,
        longitude REAL,
        timestamp INTEGER,
        local_time TEXT,
        country TEXT,
        address TEXT,
        speed REAL,
        accuracy REAL,
        battery_level INTEGER,
        is_charging INTEGER,
        is_synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertLocation(Map<String, dynamic> locationData) async {
    Database db = await database;
    return await db.insert('location_logs', locationData);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedLocations() async {
    Database db = await database;
    return await db.query(
      'location_logs',
      where: 'is_synced = ?',
      whereArgs: [0],
      orderBy: 'timestamp ASC',
    );
  }

  Future<void> deleteLocations(List<int> ids) async {
    if (ids.isEmpty) return;
    Database db = await database;
    await db.delete(
      'location_logs',
      where: 'id IN (${ids.join(',')})',
    );
  }
}
