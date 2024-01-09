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
      _tapPosition.value = localPosition;
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
          _tapPosition.value!.dx,
          _tapPosition.value!.dy,
        ),
        items: [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: iconColor),
                SizedBox(width: 8),
                Text('Editar', style: optionTextStyle),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: iconColor),
                SizedBox(width: 8),
                Text('Deletar', style: optionTextStyle),
              ],
            ),
          ),
        ],
      ).then((value) async {
        if (value == null || store.isLoading) return;

        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  WorkoutGroupCreatePage(idUser, workoutGroup.id),
            ),
          ).then((_) {
            callback(idUser);
          });
        } else if (value == 'delete') {
          await store.handleDisableWorkoutGroup(idUser, workoutGroup.id);
          callback(idUser);
        }
      });
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: InkWell(
        onTapDown: _getTapPosition,
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
        child: Stack(
          // Adicionado o Stack envolvendo o Column
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Container(
                //   height: 160, // Altura desejada para o container
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       fit: BoxFit.cover,
                //       image: AssetImage(workoutGroup
                //           .image), // Substitua pelo caminho da sua imagem
                //     ),
                //   ),
                // ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                  child: Text(
                    workoutGroup.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                if (alreadyWorkout)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Chip(
                      backgroundColor: Colors.deepPurple,
                      label: const Text(
                        'Você já treinou!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
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
