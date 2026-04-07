import 'dart:convert';
import 'package:fitness_coach_app/core/extensions/iterable_extensions.dart';

enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
  quadriceps,
  hamstrings,
  biceps,
  triceps,
  abs,
  traps,
  lats,
  glutes,
  abductors,
  adductors,
  calves,
  neck,
  forearms,
}

enum EquipmentType {
  none,
  dumbbell,
  barbell,
  machine,
  kettlebell,
  cable,
  bodyweight,
  medicineBall,
  bands,
  foamRoll,
  exerciseBall,
  ezCurlBar,
  other,
}

enum Force {
  pull,
  push,
  static,
}

enum ExerciseLevel {
  beginner,
  intermediate,
  expert,
}

enum Mechanic {
  isolation,
  compound,
}

enum ExerciseCategory {
  powerlifting,
  strength,
  stretching,
  cardio,
  olympicWeightlifting,
  strongman,
  plyometrics,
}

enum ExerciseSource {
  ingestion,
  user,
  agent,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final EquipmentType equipment;
  final List<String> instructions;
  final String? imageUrl;
  final String? localImagePath;
  final Force? force;
  final ExerciseLevel? level;
  final Mechanic? mechanic;
  final ExerciseCategory? category;
  final ExerciseSource source;
  final String? sourceId;
  final DateTime timestamp;
  final DateTime updatedAt;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.equipment,
    required this.instructions,
    this.imageUrl,
    this.localImagePath,
    this.force,
    this.level,
    this.mechanic,
    this.category,
    this.source = ExerciseSource.user,
    this.sourceId,
    DateTime? timestamp,
    DateTime? updatedAt,
  })  : timestamp = timestamp ?? DateTime.timestamp(),
        updatedAt = updatedAt ?? DateTime.timestamp();

  Exercise copyWith({
    String? id,
    String? name,
    String? description,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    EquipmentType? equipment,
    List<String>? instructions,
    String? imageUrl,
    String? localImagePath,
    Force? force,
    ExerciseLevel? level,
    Mechanic? mechanic,
    ExerciseCategory? category,
    ExerciseSource? source,
    String? sourceId,
    DateTime? timestamp,
    DateTime? updatedAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      equipment: equipment ?? this.equipment,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      force: force ?? this.force,
      level: level ?? this.level,
      mechanic: mechanic ?? this.mechanic,
      category: category ?? this.category,
      source: source ?? this.source,
      sourceId: sourceId ?? this.sourceId,
      timestamp: timestamp ?? this.timestamp,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      primaryMuscleGroup: _parseMuscleGroup(json['primaryMuscleGroup'] as String),
      secondaryMuscleGroups: _parseMuscleMuscleGroups(json['secondaryMuscleGroups']),
      equipment: _parseEquipment(json['equipment'] as String),
      instructions: _parseInstructions(json['instructions']),
      imageUrl: json['imageUrl'] as String?,
      localImagePath: json['localImagePath'] as String?,
      force: _parseForce(json['force'] as String?),
      level: _parseLevel(json['level'] as String?),
      mechanic: _parseMechanic(json['mechanic'] as String?),
      category: _parseCategory(json['category'] as String?),
      source: _parseSource(json['source'] as String),
      sourceId: json['sourceId'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.timestamp(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.timestamp(),
    );
  }

  static MuscleGroup _parseMuscleGroup(String groupName) {
    if (groupName.isEmpty) return MuscleGroup.core;
    return MuscleGroup.values.firstWhere(
      (e) => e.name == groupName.toLowerCase(),
      orElse: () => MuscleGroup.core,
    );
  }

  static List<MuscleGroup> _parseMuscleMuscleGroups(dynamic groups) {
    if (groups == null) return [];
    List<String> groupsList;
    if (groups is String) {
      try {
        groupsList = List<String>.from(jsonDecode(groups));
      } catch (_) {
        return [];
      }
    } else if (groups is List) {
      groupsList = groups.map((e) => e.toString()).toList();
    } else {
      return [];
    }
    return groupsList
        .map((e) => _parseMuscleGroup(e))
        .toList();
  }

  static List<String> _parseInstructions(dynamic instructions) {
    if (instructions == null) return [];
    if (instructions is String) {
      try {
        return List<String>.from(jsonDecode(instructions));
      } catch (_) {
        return [];
      }
    }
    if (instructions is List) {
      return List<String>.from(instructions);
    }
    return [];
  }

  static Force? _parseForce(String? forceValue) {
    if (forceValue == null || forceValue.isEmpty) return null;
    try {
      return Force.values.firstWhereOrNull(
        (e) => e.name == forceValue.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static ExerciseLevel? _parseLevel(String? levelValue) {
    if (levelValue == null || levelValue.isEmpty) return null;
    try {
      return ExerciseLevel.values.firstWhereOrNull(
        (e) => e.name == levelValue.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static Mechanic? _parseMechanic(String? mechanicValue) {
    if (mechanicValue == null || mechanicValue.isEmpty) return null;
    try {
      return Mechanic.values.firstWhereOrNull(
        (e) => e.name == mechanicValue.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static ExerciseCategory? _parseCategory(String? categoryValue) {
    if (categoryValue == null || categoryValue.isEmpty) return null;
    try {
      return ExerciseCategory.values.firstWhereOrNull(
        (e) => e.name == categoryValue.toString().toLowerCase().replaceAll(' ', ''),
      );
    } catch (_) {
      return null;
    }
  }

  static ExerciseSource _parseSource(String sourceValue) {
    try {
      return ExerciseSource.values.firstWhere(
        (e) => e.name == sourceValue.toLowerCase(),
        orElse: () => ExerciseSource.user,
      );
    } catch (_) {
      return ExerciseSource.user;
    }
  }

  static EquipmentType _parseEquipment(String equipmentValue) {
    try {
      return EquipmentType.values.firstWhere(
        (e) => e.name == equipmentValue.toString().toLowerCase().replaceAll(' ', ''),
        orElse: () => EquipmentType.none,
      );
    } catch (_) {
      return EquipmentType.none;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'primaryMuscleGroup': primaryMuscleGroup.name,
      'secondaryMuscleGroups': jsonEncode(
          secondaryMuscleGroups.map((e) => e.name).toList()),
      'equipment': equipment.name,
      'instructions': jsonEncode(instructions),
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'force': force?.name,
      'level': level?.name,
      'mechanic': mechanic?.name,
      'category': category?.name,
      'source': source.name,
      'sourceId': sourceId,
      'timestamp': timestamp.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}