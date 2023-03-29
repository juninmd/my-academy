import 'package:flutter/material.dart';

import '../models/meals.dart';

final List<Meal> meals = [
  Meal(
    name: 'Café da manhã',
    description: 'Pão, queijo, presunto, café e suco',
    photoUrl: 'https://picsum.photos/200',
    time: const TimeOfDay(hour: 8, minute: 0),
    substitutions: [],
  ),
  Meal(
    name: 'Almoço',
    description: 'Arroz, feijão, bife e salada',
    photoUrl: 'https://picsum.photos/200',
    time: const TimeOfDay(hour: 12, minute: 0),
    substitutions: [],
  ),
  Meal(
    name: 'Jantar',
    description: 'Sopa, pão e suco',
    photoUrl: 'https://picsum.photos/200',
    time: const TimeOfDay(hour: 18, minute: 0),
    substitutions: [],
  ),
];
