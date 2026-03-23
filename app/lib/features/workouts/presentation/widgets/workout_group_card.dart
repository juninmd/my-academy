import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_group_entity.dart';
import '../../domain/utils/muscle_group_mapper.dart';

class WorkoutGroupCard extends StatelessWidget {
  const WorkoutGroupCard({
    required this.workoutGroup,
    required this.onTap,
    super.key,
  });
  final WorkoutGroupEntity workoutGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Calculate targeted muscle groups
    final targetedMuscles = <String>{};
    for (var workout in workoutGroup.workouts) {
      if (workout.exercise != null) {
        final muscleGroup = MuscleGroupMapper.getMuscleGroup(
          workout.exercise!.name,
        );
        targetedMuscles.add(muscleGroup);
      }
    }

    // Sort logic to prioritize primary groups over "Outros"
    final sortedMuscles =
        targetedMuscles.toList()..sort((a, b) {
          if (a == 'Outros') return 1;
          if (b == 'Outros') return -1;
          return a.compareTo(b);
        });

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image Background
            if (workoutGroup.image != null && workoutGroup.image!.isNotEmpty)
              workoutGroup.image!.startsWith('http')
                  ? CachedNetworkImage(
                    imageUrl: workoutGroup.image!,
                    fit: BoxFit.cover,
                    errorWidget:
                        (context, error, stackTrace) =>
                            Container(color: Colors.grey[800]),
                  )
                  : Image.asset(
                    workoutGroup.image!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Container(color: Colors.grey[800]),
                  )
            else
              Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),

            // Content
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutGroup.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (sortedMuscles.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children:
                            sortedMuscles
                                .take(3)
                                .map(
                                  (m) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      m,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    const SizedBox(height: 8),
                    if (workoutGroup.workouts.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${workoutGroup.workouts.length} exercícios',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<WorkoutGroupEntity>('workoutGroup', workoutGroup),
    );
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}
