import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:fitness_coach_app/domain/repositories/exercise_repository.dart';
import 'package:fitness_coach_app/core/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseRepositoryImpl implements ExerciseRepository {
  final DatabaseService _databaseService;

  ExerciseRepositoryImpl(this._databaseService);

  @override
  Future<void> insertExercise(Exercise exercise) async {
    final db = await _databaseService.database;
    await db.insert(
      'exercises',
      exercise.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Exercise>> getAllExercises() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query('exercises');
    return List.generate(maps.length, (i) {
      return Exercise.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup group) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'muscleGroup = ?',
      whereArgs: [group.name],
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromJson(maps[i]);
    });
  }

  @override
  Future<List<Exercise>> getExercisesByEquipment(EquipmentType equipment) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'exercises',
      where: 'equipment = ?',
      whereArgs: [equipment.name],
    );
    return List.generate(maps.length, (i) {
      return Exercise.fromJson(maps[i]);
    });
  }

  @override
  Future<void> deleteExercise(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

/// Provider for the ExerciseRepository implementation.
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return ExerciseRepositoryImpl(databaseService);
});