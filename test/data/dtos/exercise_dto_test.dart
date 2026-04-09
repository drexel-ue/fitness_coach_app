import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_coach_app/data/dtos/exercise_dto.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';

void main() {
  group('ExerciseDTO', () {
    group('constructor', () {
      test('should create ExerciseDTO with all fields', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Bench Press',
          force: 'push',
          level: 'beginner',
          mechanic: 'compound',
          equipment: 'barbell',
          primaryMuscles: ['chest'],
          secondaryMuscles: ['triceps', 'shoulders'],
          instructions: ['Lie on bench', 'Press up'],
          category: 'strength',
          images: ['bench_press.jpg'],
        );

        expect(dto.id, 'test_001');
        expect(dto.name, 'Bench Press');
        expect(dto.force, 'push');
        expect(dto.primaryMuscles, ['chest']);
        expect(dto.secondaryMuscles, ['triceps', 'shoulders']);
        expect(dto.instructions, ['Lie on bench', 'Press up']);
        expect(dto.images, ['bench_press.jpg']);
      });

      test('should create ExerciseDTO with optional fields as null', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Bodyweight Exercise',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        expect(dto.force, isNull);
        expect(dto.level, isNull);
        expect(dto.mechanic, isNull);
        expect(dto.equipment, isNull);
        expect(dto.category, isNull);
      });
    });

    group('fromJson', () {
      test('should create ExerciseDTO from valid JSON', () {
        final json = {
          'id': 'test_001',
          'name': 'Bench Press',
          'force': 'push',
          'level': 'beginner',
          'mechanic': 'compound',
          'equipment': 'barbell',
          'primaryMuscles': ['chest'],
          'secondaryMuscles': ['triceps', 'shoulders'],
          'instructions': ['Lie on bench', 'Press up'],
          'category': 'strength',
          'images': ['bench_press.jpg'],
        };

        final dto = ExerciseDTO.fromJson(json);

        expect(dto.id, 'test_001');
        expect(dto.name, 'Bench Press');
        expect(dto.force, 'push');
        expect(dto.primaryMuscles, ['chest']);
        expect(dto.secondaryMuscles, ['triceps', 'shoulders']);
        expect(dto.instructions, ['Lie on bench', 'Press up']);
        expect(dto.category, 'strength');
        expect(dto.images, ['bench_press.jpg']);
      });

      test('should handle null values', () {
        final json = {
          'id': 'test_001',
          'name': 'Test',
          'force': null,
          'level': null,
          'mechanic': null,
          'equipment': null,
          'primaryMuscles': null,
          'secondaryMuscles': null,
          'instructions': null,
          'category': null,
          'images': null,
        };

        final dto = ExerciseDTO.fromJson(json);

        expect(dto.force, isNull);
        expect(dto.primaryMuscles, isEmpty);
        expect(dto.secondaryMuscles, isEmpty);
        expect(dto.instructions, isEmpty);
        expect(dto.images, isEmpty);
      });

      test('should handle empty string lists', () {
        final json = {
          'id': 'test_001',
          'name': 'Test',
          'primaryMuscles': [],
          'secondaryMuscles': [],
          'instructions': [],
          'images': [],
        };

        final dto = ExerciseDTO.fromJson(json);

        expect(dto.primaryMuscles, isEmpty);
        expect(dto.secondaryMuscles, isEmpty);
        expect(dto.instructions, isEmpty);
        expect(dto.images, isEmpty);
      });
    });

    group('toEntity', () {
      test('should convert DTO to Exercise entity', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Bench Press',
          force: 'push',
          level: 'beginner',
          mechanic: 'compound',
          equipment: 'barbell',
          primaryMuscles: ['chest'],
          secondaryMuscles: ['triceps', 'shoulders'],
          instructions: ['Lie on bench', 'Press up'],
          category: 'strength',
          images: ['bench_press.jpg'],
        );

        final exercise = dto.toEntity(source: ExerciseSource.ingestion);

        expect(exercise.id, 'test_001');
        expect(exercise.name, 'Bench Press');
        expect(exercise.description, 'A chest exercise using Barbell.');
        expect(exercise.primaryMuscleGroup, MuscleGroup.chest);
        expect(exercise.secondaryMuscleGroups, [MuscleGroup.triceps, MuscleGroup.shoulders]);
        expect(exercise.equipment, EquipmentType.barbell);
        expect(exercise.force, Force.push);
        expect(exercise.level, ExerciseLevel.beginner);
        expect(exercise.mechanic, Mechanic.compound);
        expect(exercise.category, ExerciseCategory.strength);
        expect(exercise.source, ExerciseSource.ingestion);
        expect(exercise.sourceId, 'test_001');
        expect(exercise.imageUrl, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/bench_press.jpg');
      });

      test('should handle empty primary muscles', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: [],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final exercise = dto.toEntity();

        expect(exercise.primaryMuscleGroup, MuscleGroup.core);
        expect(exercise.secondaryMuscleGroups, isEmpty);
      });

      test('should use default source when not specified', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final exercise = dto.toEntity();

        expect(exercise.source, ExerciseSource.ingestion);
      });

      test('should handle custom source and sourceId', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final exercise = dto.toEntity(
          source: ExerciseSource.user,
          sourceId: 'custom_id',
        );

        expect(exercise.source, ExerciseSource.user);
        expect(exercise.sourceId, 'custom_id');
      });

      test('should handle null force/level/mechanic/category', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final exercise = dto.toEntity();

        expect(exercise.force, isNull);
        expect(exercise.level, isNull);
        expect(exercise.mechanic, isNull);
        expect(exercise.category, isNull);
      });
    });

    group('generateDescription', () {
      test('should generate description with equipment and muscles', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Bench Press',
          equipment: 'barbell',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final description = dto.generateDescription();
        expect(description, 'A chest exercise using Barbell.');
      });

      test('should handle empty primary muscles', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          equipment: 'dumbbell',
          primaryMuscles: [],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final description = dto.generateDescription();
        expect(description, 'A full body exercise using Dumbbell.');
      });

      test('should handle null equipment', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final description = dto.generateDescription();
        expect(description, 'A chest exercise using no equipment.');
      });

      test('should handle underscore in equipment name', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          equipment: 'ez_curl_bar',
          primaryMuscles: ['biceps'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final description = dto.generateDescription();
        expect(description, 'A biceps exercise using Ez curl bar.');
      });
    });

    group('getImageUrl', () {
      test('should return image URL for valid index', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: ['bench_press.jpg'],
        );

        final url = dto.getImageUrl(0);
        expect(url, 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/bench_press.jpg');
      });

      test('should return null for empty images', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: [],
        );

        final url = dto.getImageUrl(0);
        expect(url, isNull);
      });

      test('should return null for out of bounds index', () {
        final dto = ExerciseDTO(
          id: 'test_001',
          name: 'Test',
          primaryMuscles: ['chest'],
          secondaryMuscles: [],
          instructions: [],
          images: ['bench_press.jpg'],
        );

        final url = dto.getImageUrl(5);
        expect(url, isNull);
      });
    });

    group('parseStringList', () {
      test('should handle List<String>', () {
        final result = ExerciseDTO.parseStringList(['a', 'b', 'c']);
        expect(result, ['a', 'b', 'c']);
      });

      test('should handle null', () {
        final result = ExerciseDTO.parseStringList(null);
        expect(result, isEmpty);
      });

      test('should handle empty list', () {
        final result = ExerciseDTO.parseStringList([]);
        expect(result, isEmpty);
      });

      test('should handle JSON string', () {
        final result = ExerciseDTO.parseStringList('["a", "b"]');
        expect(result, ['a', 'b']);
      });
    });

    group('parseMuscleGroup', () {
      test('should parse valid muscle name', () {
        final result = ExerciseDTO.parseMuscleGroup('chest');
        expect(result, MuscleGroup.chest);
      });

      test('should return core for null', () {
        final result = ExerciseDTO.parseMuscleGroup(null);
        expect(result, MuscleGroup.core);
      });

      test('should return core for empty string', () {
        final result = ExerciseDTO.parseMuscleGroup('');
        expect(result, MuscleGroup.core);
      });

      test('should return core for unknown muscle', () {
        final result = ExerciseDTO.parseMuscleGroup('unknown_muscle');
        expect(result, MuscleGroup.core);
      });

      test('should handle spaces in muscle name', () {
        final result = ExerciseDTO.parseMuscleGroup('upper chest');
        expect(result, MuscleGroup.chest);
      });
    });

    group('parseEquipment', () {
      test('should parse valid equipment name', () {
        final result = ExerciseDTO.parseEquipment('barbell');
        expect(result, EquipmentType.barbell);
      });

      test('should return none for null', () {
        final result = ExerciseDTO.parseEquipment(null);
        expect(result, EquipmentType.none);
      });

      test('should return none for empty string', () {
        final result = ExerciseDTO.parseEquipment('');
        expect(result, EquipmentType.none);
      });

      test('should return none for unknown equipment', () {
        final result = ExerciseDTO.parseEquipment('unknown_equipment');
        expect(result, EquipmentType.none);
      });

      test('should handle spaces in equipment name', () {
        final result = ExerciseDTO.parseEquipment('ez curl bar');
        expect(result, EquipmentType.ezCurlBar);
      });
    });

    group('parseForce', () {
      test('should parse valid force name', () {
        final result = ExerciseDTO.parseForce('push');
        expect(result, Force.push);
      });

      test('should return null for null', () {
        final result = ExerciseDTO.parseForce(null);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = ExerciseDTO.parseForce('');
        expect(result, isNull);
      });

      test('should return null for unknown force', () {
        final result = ExerciseDTO.parseForce('unknown_force');
        expect(result, isNull);
      });
    });

    group('parseLevel', () {
      test('should parse valid level name', () {
        final result = ExerciseDTO.parseLevel('beginner');
        expect(result, ExerciseLevel.beginner);
      });

      test('should return null for null', () {
        final result = ExerciseDTO.parseLevel(null);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = ExerciseDTO.parseLevel('');
        expect(result, isNull);
      });

      test('should return null for unknown level', () {
        final result = ExerciseDTO.parseLevel('unknown_level');
        expect(result, isNull);
      });
    });

    group('parseMechanic', () {
      test('should parse valid mechanic name', () {
        final result = ExerciseDTO.parseMechanic('compound');
        expect(result, Mechanic.compound);
      });

      test('should return null for null', () {
        final result = ExerciseDTO.parseMechanic(null);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = ExerciseDTO.parseMechanic('');
        expect(result, isNull);
      });

      test('should return null for unknown mechanic', () {
        final result = ExerciseDTO.parseMechanic('unknown_mechanic');
        expect(result, isNull);
      });
    });

    group('parseCategory', () {
      test('should parse valid category name', () {
        final result = ExerciseDTO.parseCategory('strength');
        expect(result, ExerciseCategory.strength);
      });

      test('should return null for null', () {
        final result = ExerciseDTO.parseCategory(null);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = ExerciseDTO.parseCategory('');
        expect(result, isNull);
      });

      test('should handle spaces in category name', () {
        final result = ExerciseDTO.parseCategory('power lifting');
        expect(result, ExerciseCategory.powerlifting);
      });
    });
  });
}