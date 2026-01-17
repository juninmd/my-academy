import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/workout_group_entity.dart';

class WorkoutGroupCard extends StatelessWidget {
  const WorkoutGroupCard({
    required this.workoutGroup,
    required this.onTap,
    super.key,
  });
  final WorkoutGroupEntity workoutGroup;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
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
                  if (workoutGroup.workouts.isNotEmpty)
                    Text(
                      '${workoutGroup.workouts.length} exercícios',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<WorkoutGroupEntity>('workoutGroup', workoutGroup),
    );
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
  }
}
