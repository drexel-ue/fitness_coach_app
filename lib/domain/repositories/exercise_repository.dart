import 'package:fitness_coach_app/domain/entities/exercise.dart';

abstract class ExerciseRepository {
  Future<void> insertExercise(Exercise exercise);
  Future<List<Exercise>> getAllExercises();
  Future<List<Exercise>> getExercisesByMuscleGroup(MuscleGroup group);
  Future<List<Exercise>> getExercisesByEquipment(EquipmentType equipment);
  Future<void> deleteExercise(String id);
}