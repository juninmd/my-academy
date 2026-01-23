import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_group_card.dart';

void main() {
  testWidgets('WorkoutGroupCard displays info', (tester) async {
    const group = WorkoutGroupEntity(
      id: 1,
      name: 'Leg Day',
      userId: 'u1',
      workouts: [],
      image: null,
    );

    await tester.pumpWidget(MaterialApp(
      home: WorkoutGroupCard(
        workoutGroup: group,
        onTap: () {},
      ),
    ));

    expect(find.text('Leg Day'), findsOneWidget);
  });
}
