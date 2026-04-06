import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationSupportDirectory();
    final path = join(directory.path, 'fitness_coach.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        muscleGroup TEXT NOT NULL,
        equipment TEXT NOT NULL,
        instructions TEXT NOT NULL
      )
    ''');
  }
}

/// Provider for the DatabaseService instance.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for the actual Database instance, initialized and ready to use.
/// This is useful for Repositories that need to execute queries.
final databaseInstanceProvider = FutureProvider<Database>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return service.database;
});