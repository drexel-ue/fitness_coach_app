import 'package:fitness_coach_app/domain/entities/exercise.dart';

/// Abstract interface for exercise data access.
/// Defines the contract for all exercise repository operations.
abstract class ExerciseRepository {
  /// Inserts or updates an exercise in the repository.
  Future<void> insertExercise(Exercise exercise);
  
  /// Retrieves all exercises from the repository.
  Future<List<Exercise>> getAllExercises();
  
  /// Retrieves exercises by primary muscle group.
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup group);
  
  /// Retrieves exercises by equipment type.
  Future<List<Exercise>> getExercisesByEquipment(EquipmentType equipment);
  
  /// Deletes an exercise by ID.
  Future<void> deleteExercise(String id);
  
  /// Retrieves exercises by source (ingestion, user, agent).
  Future<List<Exercise>> getExercisesBySource(ExerciseSource source);
  
  /// Retrieves exercises by force type (pull, push, static).
  Future<List<Exercise>> getExercisesByForce(Force force);
  
  /// Retrieves exercises by difficulty level.
  Future<List<Exercise>> getExercisesByLevel(ExerciseLevel level);
}
