import 'dart:convert';

enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
  core,
}

enum EquipmentType {
  none,
  dumbbell,
  barbell,
  machine,
  kettlebell,
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final MuscleGroup muscleGroup;
  final EquipmentType equipment;
  final List<String> instructions;

  Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.equipment,
    required this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      muscleGroup: MuscleGroup.values.firstWhere(
        (e) => e.name == json['muscleGroup'],
        orElse: () => MuscleGroup.core,
      ),
      equipment: EquipmentType.values.firstWhere(
        (e) => e.name == json['equipment'],
        orElse: () => EquipmentType.none,
      ),
      instructions: _parseInstructions(json['instructions']),
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'muscleGroup': muscleGroup.name,
      'equipment': equipment.name,
      'instructions': jsonEncode(instructions),
    };
  }
}