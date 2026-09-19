import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/workout_entity.dart';

class WorkoutCard extends StatelessWidget {
  const WorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });
  final WorkoutEntity workout;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isFinished = workout.isFinished;
    final exercise = workout.exercise;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            if (exercise?.image != null)
              AppImage(
                source: exercise!.image!,
                color:
                    isFinished
                        ? Colors.black.withValues(alpha: 0.7)
                        : Colors.black.withValues(alpha: 0.2),
                colorBlendMode: BlendMode.darken,
                fallback: Container(color: Colors.grey[800]),
              )
            else
              Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.white24,
                ),
              ),

            // Content Overlay
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      exercise?.name ?? 'Exercício',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isFinished ? Colors.greenAccent : Colors.white,
                        decoration:
                            isFinished ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (workout.description != null &&
                        workout.description!.isNotEmpty)
                      Text(
                        workout.description!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
            ),

            if (isFinished)
              const Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.check, size: 16, color: Colors.white),
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
    properties.add(DiagnosticsProperty<WorkoutEntity>('workout', workout));
    properties.add(ObjectFlagProperty<VoidCallback>.has('onTap', onTap));
    properties.add(
      ObjectFlagProperty<VoidCallback>.has('onLongPress', onLongPress),
    );
  }
}
