import "package:json_annotation/json_annotation.dart";
import 'package:flutter/cupertino.dart';

@JsonSerializable()
class WorkoutSeriesDTO {
  int? id;
  int? workoutId;
  TextEditingController? repetitionsController;
  TextEditingController? weightController;
  TextEditingController? restController;
  int repetitions;
  int weight;
  int rest;

  WorkoutSeriesDTO({
    this.id,
    this.workoutId,
    this.repetitionsController,
    this.weightController,
    this.restController,
    required this.repetitions,
    required this.weight,
    required this.rest,
  });

  factory WorkoutSeriesDTO.fromJson(Map<String, dynamic> json) {
    return WorkoutSeriesDTO(
      id: json['id'] != null ? json['id'] : null,
      workoutId: json['workoutId'],
      repetitions: json['repetitions'],
      weight: json['weight'],
      rest: json['rest'],
    );
  }
}
