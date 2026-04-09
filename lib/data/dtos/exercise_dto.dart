import 'dart:convert';

import 'package:fitness_coach_app/core/extensions/iterable_extensions.dart';
import 'package:fitness_coach_app/domain/entities/exercise.dart';
import 'package:flutter/foundation.dart';

/// Extension for string first character uppercase operations.
extension StringFirstCharUpperCase on String {
  /// Returns the string with the first character uppercased.
  String replaceFirstCharUpperCase() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

/// DTO (Data Transfer Object) for free-exercise-db format.
/// This class represents the raw data structure from the free-exercise-db repository.
/// It is used to convert external data into the domain Exercise entity.
class ExerciseDTO {
  final String id;
  final String name;
  final String? force;
  final String? level;
  final String? mechanic;
  final String? equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;
  final String? category;
  final List<String> images;

  ExerciseDTO({
    required this.id,
    required this.name,
    this.force,
    this.level,
    this.mechanic,
    this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    this.category,
    required this.images,
  });

  /// Creates an ExerciseDTO from a JSON map.
  factory ExerciseDTO.fromJson(Map<String, dynamic> json) {
    return ExerciseDTO(
      id: json['id'] as String,
      name: json['name'] as String,
      force: json['force'] as String?,
      level: json['level'] as String?,
      mechanic: json['mechanic'] as String?,
      equipment: json['equipment'] as String?,
      primaryMuscles: parseStringList(json['primaryMuscles']),
      secondaryMuscles: parseStringList(json['secondaryMuscles']),
      instructions: parseStringList(json['instructions']),
      category: json['category'] as String?,
      images: parseStringList(json['images']),
    );
  }

  /// Converts this DTO to a domain Exercise entity.
  Exercise toEntity({
    ExerciseSource source = ExerciseSource.ingestion,
    String? sourceId,
    DateTime? timestamp,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id,
      name: name,
      description: generateDescription(),
      primaryMuscleGroup: parseMuscleGroup(primaryMuscles.firstOrNull),
      secondaryMuscleGroups: primaryMuscles
          .skip(1)
          .map(parseMuscleGroup)
          .followedBy(secondaryMuscles.map(parseMuscleGroup))
          .toList(),
      equipment: parseEquipment(equipment),
      instructions: instructions,
      imageUrl: images.isNotEmpty ? getImageUrl(0) : null,
      force: parseForce(force),
      level: parseLevel(level),
      mechanic: parseMechanic(mechanic),
      category: parseCategory(category),
      source: source,
      sourceId: sourceId ?? id,
      timestamp: timestamp,
      updatedAt: updatedAt,
    );
  }

  /// Generates a description from the exercise data.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  String generateDescription() {
    final equipmentStr = equipment != null
        ? equipment!.replaceAll('_', ' ').replaceFirstCharUpperCase()
        : 'no equipment';
    final muscleStr = primaryMuscles.isNotEmpty
        ? primaryMuscles.map((m) => m.replaceAll('_', ' ')).join(', ')
        : 'full body';
    return 'A $muscleStr exercise using $equipmentStr.';
  }

  /// Returns the image URL for the given index.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  String? getImageUrl(int index) {
    if (images.isEmpty || index >= images.length) return null;
    final imagePath = images[index];
    return 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/$imagePath';
  }

  /// Parses a list of strings from JSON.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static List<String> parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    if (value is String) {
      try {
        return List<String>.from(jsonDecode(value));
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Parses a muscle group name to MuscleGroup enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static MuscleGroup parseMuscleGroup(String? muscleName) {
    if (muscleName == null || muscleName.isEmpty) {
      throw ArgumentError('Muscle name cannot be null or empty');
    }

    final normalizedName = muscleName.toLowerCase();

    final muscleGroup = MuscleGroup.values.firstWhereOrNull((MuscleGroup group) {
      if (group.name.contains(normalizedName)) {
        return true;
      }
      if (normalizedName.contains(group.name)) {
        return true;
      }
      return false;
    });

    if (muscleGroup == null) {
      throw ArgumentError('Unknown muscle group: $muscleName');
    }

    return muscleGroup;
  }

  /// Parses equipment name to EquipmentType enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static EquipmentType parseEquipment(String? equipmentValue) {
    if (equipmentValue == null || equipmentValue.isEmpty) {
      return EquipmentType.none;
    }
    final normalizedName = equipmentValue.toLowerCase().replaceAll(' ', '');
    try {
      return EquipmentType.values.firstWhere(
        (e) => e.name == normalizedName,
        orElse: () => EquipmentType.none,
      );
    } catch (_) {
      return EquipmentType.none;
    }
  }

  /// Parses force type to Force enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static Force? parseForce(String? forceValue) {
    if (forceValue == null || forceValue.isEmpty) return null;
    try {
      return Force.values.firstWhereOrNull((e) => e.name == forceValue.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Parses exercise level to ExerciseLevel enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static ExerciseLevel? parseLevel(String? levelValue) {
    if (levelValue == null || levelValue.isEmpty) return null;
    try {
      return ExerciseLevel.values.firstWhereOrNull((e) => e.name == levelValue.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Parses mechanic type to Mechanic enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static Mechanic? parseMechanic(String? mechanicValue) {
    if (mechanicValue == null || mechanicValue.isEmpty) return null;
    try {
      return Mechanic.values.firstWhereOrNull((e) => e.name == mechanicValue.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Parses category to ExerciseCategory enum.
  /// This method is exposed for testing purposes.
  @visibleForTesting
  static ExerciseCategory? parseCategory(String? categoryValue) {
    if (categoryValue == null || categoryValue.isEmpty) return null;
    final normalizedName = categoryValue.toLowerCase().replaceAll(' ', '');
    try {
      return ExerciseCategory.values.firstWhereOrNull((e) => e.name == normalizedName);
    } catch (_) {
      return null;
    }
  }
}
