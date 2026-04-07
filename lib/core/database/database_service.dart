import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the DatabaseService instance.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// Provider for the actual Database instance, initialized and pre-configured.
final databaseInstanceProvider = FutureProvider<Database>((ref) async {
  final service = ref.watch(databaseServiceProvider);
  return service.database;
});

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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE exercises (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        primaryMuscleGroup TEXT NOT NULL,
        secondaryMuscleGroups TEXT NOT NULL,
        equipment TEXT NOT NULL,
        instructions TEXT NOT NULL,
        imageUrl TEXT,
        localImagePath TEXT,
        force TEXT,
        level TEXT,
        mechanic TEXT,
        category TEXT,
        source TEXT NOT NULL DEFAULT 'user',
        sourceId TEXT,
        timestamp INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
    
    // Create indexes for common query patterns
    await db.execute('CREATE INDEX idx_primaryMuscleGroup ON exercises(primaryMuscleGroup)');
    await db.execute('CREATE INDEX idx_equipment ON exercises(equipment)');
    await db.execute('CREATE INDEX idx_source ON exercises(source)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration from version 1 to 2
      await db.execute('ALTER TABLE exercises RENAME TO exercises_old');
      await db.execute('''
        CREATE TABLE exercises (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT NOT NULL,
          primaryMuscleGroup TEXT NOT NULL,
          secondaryMuscleGroups TEXT NOT NULL,
          equipment TEXT NOT NULL,
          instructions TEXT NOT NULL,
          imageUrl TEXT,
          localImagePath TEXT
        )
      ''');
      
      await db.execute('''
        INSERT INTO exercises (id, name, description, primaryMuscleGroup, equipment, instructions)
        SELECT id, name, description, muscleGroup, equipment, instructions FROM exercises_old
      ''');
      
      await db.execute('DROP TABLE exercises_old');
    }

    if (oldVersion < 3) {
      // Migration from version 2 to 3: Add new fields for ingestion support
      await db.execute('ALTER TABLE exercises ADD COLUMN force TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN level TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN mechanic TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN category TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN source TEXT DEFAULT \'user\'');
      await db.execute('ALTER TABLE exercises ADD COLUMN sourceId TEXT');
      await db.execute('ALTER TABLE exercises ADD COLUMN timestamp INTEGER DEFAULT (strftime(\'%s\', \'now\') * 1000)');
      await db.execute('ALTER TABLE exercises ADD COLUMN updatedAt INTEGER DEFAULT (strftime(\'%s\', \'now\') * 1000)');
      
      // Create indexes for common query patterns
      await db.execute('CREATE INDEX idx_primaryMuscleGroup ON exercises(primaryMuscleGroup)');
      await db.execute('CREATE INDEX idx_equipment ON exercises(equipment)');
      await db.execute('CREATE INDEX idx_source ON exercises(source)');
    }
  }
}
