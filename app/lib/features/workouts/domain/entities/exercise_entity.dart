import 'package:equatable/equatable.dart';

class ExerciseEntity extends Equatable {
  const ExerciseEntity({
    required this.id,
    required this.name,
    this.image,
    this.tips = const [],
    this.mistakes = const [],
    this.description,
    this.type = ExerciseType.strength,
  });
  final int id;
  final String name;
  final String? image;
  final List<String> tips;
  final List<String> mistakes;
  final String? description;
  final ExerciseType type;

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    tips,
    mistakes,
    description,
    type,
  ];
}

enum ExerciseType { strength, cardio }
