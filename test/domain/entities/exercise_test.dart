import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';

void main() {
  group('Exercise Entity', () {
    const baseId = 'test_id';
    const baseName = 'Bench Press';
    const baseDescription = 'A chest exercise using barbell.';
    const basePrimaryMuscle = MuscleGroup.chest;
    const baseSecondaryMuscles = [MuscleGroup.triceps, MuscleGroup.shoulders];
    const baseEquipment = EquipmentType.barbell;
    const baseInstructions = ['Lie on bench', 'Lower bar to chest', 'Press up'];
    const baseImageUrl = 'https://example.com/bench_press.jpg';
    const baseForce = Force.push;
    const baseLevel = ExerciseLevel.beginner;
    const baseMechanic = Mechanic.compound;
    const baseCategory = ExerciseCategory.strength;
    const baseSource = ExerciseSource.ingestion;
    const baseSourceId = 'exercise_001';
    final baseTimestamp = DateTime(2026, 1, 1);
    final baseUpdatedAt = DateTime(2026, 1, 2);

    group('constructor', () {
      test('should create Exercise with all required fields', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: basePrimaryMuscle,
          secondaryMuscleGroups: baseSecondaryMuscles,
          equipment: baseEquipment,
          instructions: baseInstructions,
        );

        expect(exercise.id, baseId);
        expect(exercise.name, baseName);
        expect(exercise.description, baseDescription);
        expect(exercise.primaryMuscleGroup, basePrimaryMuscle);
        expect(exercise.secondaryMuscleGroups, baseSecondaryMuscles);
        expect(exercise.equipment, baseEquipment);
        expect(exercise.instructions, baseInstructions);
        expect(exercise.source, ExerciseSource.user);
        expect(exercise.sourceId, isNull);
      });

      test('should create Exercise with all optional fields', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: basePrimaryMuscle,
          secondaryMuscleGroups: baseSecondaryMuscles,
          equipment: baseEquipment,
          instructions: baseInstructions,
          imageUrl: baseImageUrl,
          localImagePath: '/path/to/image.jpg',
          force: baseForce,
          level: baseLevel,
          mechanic: baseMechanic,
          category: baseCategory,
          source: baseSource,
          sourceId: baseSourceId,
          timestamp: baseTimestamp,
          updatedAt: baseUpdatedAt,
        );

        expect(exercise.imageUrl, baseImageUrl);
        expect(exercise.localImagePath, '/path/to/image.jpg');
        expect(exercise.force, baseForce);
        expect(exercise.level, baseLevel);
        expect(exercise.mechanic, baseMechanic);
        expect(exercise.category, baseCategory);
        expect(exercise.source, baseSource);
        expect(exercise.sourceId, baseSourceId);
        expect(exercise.timestamp, baseTimestamp);
        expect(exercise.updatedAt, baseUpdatedAt);
      });

      test('should use default values for optional fields', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: basePrimaryMuscle,
          secondaryMuscleGroups: baseSecondaryMuscles,
          equipment: baseEquipment,
          instructions: baseInstructions,
        );

        expect(exercise.imageUrl, isNull);
        expect(exercise.localImagePath, isNull);
        expect(exercise.force, isNull);
        expect(exercise.level, isNull);
        expect(exercise.mechanic, isNull);
        expect(exercise.category, isNull);
        expect(exercise.source, ExerciseSource.user);
        expect(exercise.sourceId, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with modified fields', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: basePrimaryMuscle,
          secondaryMuscleGroups: baseSecondaryMuscles,
          equipment: baseEquipment,
          instructions: baseInstructions,
        );

        final updated = exercise.copyWith(
          name: 'Modified Bench Press',
          force: Force.pull,
        );

        expect(updated.id, baseId);
        expect(updated.name, 'Modified Bench Press');
        expect(updated.force, Force.pull);
        expect(updated.instructions, baseInstructions);
      });

      test('should create copy with all fields unchanged', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: basePrimaryMuscle,
          secondaryMuscleGroups: baseSecondaryMuscles,
          equipment: baseEquipment,
          instructions: baseInstructions,
        );

        final copy = exercise.copyWith();

        expect(copy.id, exercise.id);
        expect(copy.name, exercise.name);
        expect(copy.description, exercise.description);
      });
    });

    group('fromJson', () {
      test('should create Exercise from valid JSON', () {
        final json = {
          'id': baseId,
          'name': baseName,
          'description': baseDescription,
          'primaryMuscleGroup': 'chest',
          'secondaryMuscleGroups': jsonEncode(['triceps', 'shoulders']),
          'equipment': 'barbell',
          'instructions': jsonEncode(baseInstructions),
          'imageUrl': baseImageUrl,
          'force': 'push',
          'level': 'beginner',
          'mechanic': 'compound',
          'category': 'strength',
          'source': 'ingestion',
          'sourceId': baseSourceId,
          'timestamp': baseTimestamp.toIso8601String(),
          'updatedAt': baseUpdatedAt.toIso8601String(),
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.id, baseId);
        expect(exercise.name, baseName);
        expect(exercise.primaryMuscleGroup, MuscleGroup.chest);
        expect(exercise.secondaryMuscleGroups, [MuscleGroup.triceps, MuscleGroup.shoulders]);
        expect(exercise.equipment, EquipmentType.barbell);
        expect(exercise.force, Force.push);
        expect(exercise.level, ExerciseLevel.beginner);
        expect(exercise.mechanic, Mechanic.compound);
        expect(exercise.category, ExerciseCategory.strength);
        expect(exercise.source, ExerciseSource.ingestion);
        expect(exercise.sourceId, baseSourceId);
      });

      test('should handle null optional fields', () {
        final json = {
          'id': baseId,
          'name': baseName,
          'description': baseDescription,
          'primaryMuscleGroup': 'chest',
          'secondaryMuscleGroups': jsonEncode([]),
          'equipment': 'bodyweight',
          'instructions': jsonEncode([]),
          'imageUrl': null,
          'force': null,
          'level': null,
          'mechanic': null,
          'category': null,
          'source': 'user',
          'sourceId': null,
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.imageUrl, isNull);
        expect(exercise.force, isNull);
        expect(exercise.level, isNull);
        expect(exercise.mechanic, isNull);
        expect(exercise.category, isNull);
        expect(exercise.source, ExerciseSource.user);
      });

      test('should handle empty muscle groups', () {
        final json = {
          'id': baseId,
          'name': baseName,
          'description': baseDescription,
          'primaryMuscleGroup': '',
          'secondaryMuscleGroups': jsonEncode([]),
          'equipment': 'dumbbell',
          'instructions': jsonEncode([]),
          'source': 'user',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.primaryMuscleGroup, MuscleGroup.core);
      });

      test('should handle unknown enum values gracefully', () {
        final json = {
          'id': baseId,
          'name': baseName,
          'description': baseDescription,
          'primaryMuscleGroup': 'unknown_muscle',
          'secondaryMuscleGroups': jsonEncode([]),
          'equipment': 'unknown_equipment',
          'instructions': jsonEncode([]),
          'force': 'unknown_force',
          'source': 'user',
        };

        final exercise = Exercise.fromJson(json);

        expect(exercise.primaryMuscleGroup, MuscleGroup.core);
        expect(exercise.equipment, EquipmentType.none);
        expect(exercise.force, isNull);
      });
    });

    group('toJson', () {
      test('should convert Exercise to JSON', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: MuscleGroup.chest,
          secondaryMuscleGroups: [MuscleGroup.triceps],
          equipment: EquipmentType.barbell,
          instructions: baseInstructions,
          force: Force.push,
          level: ExerciseLevel.beginner,
          mechanic: Mechanic.compound,
          category: ExerciseCategory.strength,
          source: ExerciseSource.ingestion,
          sourceId: baseSourceId,
          timestamp: baseTimestamp,
          updatedAt: baseUpdatedAt,
        );

        final json = exercise.toJson();

        expect(json['id'], baseId);
        expect(json['name'], baseName);
        expect(json['primaryMuscleGroup'], 'chest');
        expect(json['equipment'], 'barbell');
        expect(json['force'], 'push');
        expect(json['level'], 'beginner');
        expect(json['mechanic'], 'compound');
        expect(json['category'], 'strength');
        expect(json['source'], 'ingestion');
        expect(json['sourceId'], baseSourceId);
        expect(json['timestamp'], baseTimestamp.toIso8601String());
        expect(json['updatedAt'], baseUpdatedAt.toIso8601String());
      });

      test('should handle null optional fields in JSON', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: MuscleGroup.chest,
          secondaryMuscleGroups: [],
          equipment: EquipmentType.bodyweight,
          instructions: [],
          source: ExerciseSource.user,
        );

        final json = exercise.toJson();

        expect(json['force'], isNull);
        expect(json['level'], isNull);
        expect(json['mechanic'], isNull);
        expect(json['category'], isNull);
        expect(json['imageUrl'], isNull);
      });
    });

    group('edge cases', () {
      test('should handle empty name', () {
        final exercise = Exercise(
          id: baseId,
          name: '',
          description: baseDescription,
          primaryMuscleGroup: MuscleGroup.chest,
          secondaryMuscleGroups: [],
          equipment: EquipmentType.none,
          instructions: [],
        );

        expect(exercise.name, '');
      });

      test('should handle empty instructions list', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: MuscleGroup.chest,
          secondaryMuscleGroups: [],
          equipment: EquipmentType.none,
          instructions: [],
        );

        expect(exercise.instructions, isEmpty);
      });

      test('should handle empty secondary muscle groups', () {
        final exercise = Exercise(
          id: baseId,
          name: baseName,
          description: baseDescription,
          primaryMuscleGroup: MuscleGroup.chest,
          secondaryMuscleGroups: [],
          equipment: EquipmentType.none,
          instructions: [],
        );

        expect(exercise.secondaryMuscleGroups, isEmpty);
      });
    });
  });
}