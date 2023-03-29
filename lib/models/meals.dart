import 'package:flutter/material.dart';

class Meal {
  final String name;
  final String description;
  final String photoUrl;
  final TimeOfDay time;
  List<String> substitutions = [];

  Meal(
      {required this.name,
        required this.description,
        required this.photoUrl,
        required this.time,
        required this.substitutions});
}