import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/models/workout_group.dart';
import '../constants.dart';
import '../pages/workout_group_create_page.dart';
import '../pages/workouts_page.dart';
import '../stores/workout_group_store.dart';

class WorkoutGroupCard extends HookConsumerWidget {
  final WorkoutGroup workoutGroup;
  final bool alreadyWorkout;
  final Function callback;

  const WorkoutGroupCard({
    Key? key,
    required this.workoutGroup,
    required this.alreadyWorkout,
    required this.callback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(workoutGroupStoreProvider);
    final ValueNotifier<Offset?> _tapPosition = useState<Offset?>(null);

    void _getTapPosition(TapDownDetails tapDetails) {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final Offset localPosition =
          renderBox.globalToLocal(tapDetails.globalPosition);

      final Size screenSize = MediaQuery.of(context).size;
      final double screenWidth = screenSize.width;
      final double screenHeight = screenSize.height;

      // Calculate the tap position relative to the entire screen
      final double tapPositionX = localPosition.dx;
      final double tapPositionY = localPosition.dy;
      final Offset tapPositionOnScreen = Offset(
        tapPositionX + (screenWidth - renderBox.size.width) / 2,
        tapPositionY + (screenHeight - renderBox.size.height) / 2,
      );

      _tapPosition.value = tapPositionOnScreen;
    }

    void _showContextMenu(BuildContext context, WorkoutGroup workoutGroup) {
      final ThemeData theme = Theme.of(context);
      final Color? iconColor = theme.iconTheme.color;
      final TextStyle? optionTextStyle =
          theme.textTheme.subtitle1?.copyWith(color: iconColor);

      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          _tapPosition.value!.dx,
          _tapPosition.value!.dy,
          MediaQuery.of(context).size.width - _tapPosition.value!.dx,
          MediaQuery.of(context).size.height - _tapPosition.value!.dy,
        ),
        items: [
          PopupMenuItem(
            child: GestureDetector(
              child: Row(
                children: [
                  Icon(Icons.edit, color: iconColor),
                  SizedBox(width: 8),
                  Text('Editar', style: optionTextStyle),
                ],
              ),
              onTap: () {
                if (store.isLoading) {
                  print('carregando');
                  return;
                }
                print('AAAAAAAA');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        WorkoutGroupCreatePage(idUser, workoutGroup.id),
                  ),
                ).then((_) {
                  // This callback will be executed after WorkoutGroupCreatePage is popped.
                  Navigator.pop(context);
                });
              },
            ),
          ),
          PopupMenuItem(
            child: GestureDetector(
              child: Row(
                children: [
                  Icon(Icons.delete, color: iconColor),
                  SizedBox(width: 8),
                  Text('Deletar', style: optionTextStyle),
                ],
              ),
              onTap: () async {
                if (store.isLoading) {
                  print('carregando');
                  return;
                }
                Navigator.pop(context);
                await store.handleDisableWorkoutGroup(idUser, workoutGroup.id);
                callback(idUser);
              },
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: GestureDetector(
        onTap: () async {
          if (alreadyWorkout) {
            _showAlreadWorkout(context);
            callback(idUser);
            return;
          }
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => WorkoutsPage(
                workoutGroup: workoutGroup,
                callback: callback,
              ),
            ),
          );
        },
        onLongPress: () {
          _showContextMenu(context, workoutGroup);
        },
        onTapDown: _getTapPosition,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Center(
                child: Stack(
                  children: [
                    Image.asset(
                      workoutGroup.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      color: alreadyWorkout ? Colors.black45 : null,
                      colorBlendMode: alreadyWorkout ? BlendMode.darken : null,
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            child: Text(
                              workoutGroup.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (alreadyWorkout)
                      Positioned(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.red,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 4,
                              ),
                              child: const Text(
                                'Você já treinou!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
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

  void _showAlreadWorkout(BuildContext context) {
    const SnackBar snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      content: Text('Você já treinou hoje, vai descansar :)'),
      duration: Duration(seconds: 5), // Optional: Set a custom duration
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
