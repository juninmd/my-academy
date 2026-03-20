import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/exercise_entity.dart';

class CustomExerciseRepository {
  static const String _storageKey = 'custom_exercises';

  Future<List<ExerciseEntity>> getCustomExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    return jsonList.map((jsonStr) {
      final Map<String, dynamic> json = jsonDecode(jsonStr);
      return ExerciseEntity(
        id: json['id'],
        name: json['name'],
        image: json['image'], // Can be null
        description: json['description'],
        tips: (json['tips'] as List<dynamic>?)?.cast<String>() ?? [],
        mistakes: (json['mistakes'] as List<dynamic>?)?.cast<String>() ?? [],
      );
    }).toList();
  }

  Future<void> saveCustomExercise(ExerciseEntity exercise) async {
    final prefs = await SharedPreferences.getInstance();
    final exercises = await getCustomExercises();

    // Check for duplicates (by ID) just in case
    final index = exercises.indexWhere((e) => e.id == exercise.id);
    if (index >= 0) {
      exercises[index] = exercise;
    } else {
      exercises.add(exercise);
    }

    final jsonList = exercises.map((e) {
      final json = {
        'id': e.id,
        'name': e.name,
        'image': e.image,
        'description': e.description,
        'tips': e.tips,
        'mistakes': e.mistakes,
      };
      return jsonEncode(json);
    }).toList();

    await prefs.setStringList(_storageKey, jsonList);
  }
}
