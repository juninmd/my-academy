import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/exercise.dart';
import '../widgets/custom_text_controller.dart';

class ExerciseEditPage extends StatefulWidget {
  final Exercise exercise;
  Function callback;

  ExerciseEditPage({required this.callback, required this.exercise});

  @override
  _ExerciseEditPageState createState() => _ExerciseEditPageState();
}

class _ExerciseEditPageState extends State<ExerciseEditPage> {
  late int id;
  late int sets;
  late int reps;
  late int weight;

  @override
  void initState() {
    super.initState();
    sets = widget.exercise.sets;
    reps = widget.exercise.reps;
    weight = widget.exercise.weight;
  }

  void _saveExercise() {
    if (weight > widget.exercise.weight) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            const Text('Parabéns! Você levantou uma carga maior desta vez!'),
      ));
    }
    widget.callback(weight,reps,sets);
    Navigator.pop(
      context,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Exercício"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(widget.exercise.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.exercise.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              textDirection: TextDirection.rtl,
              controller: CustomTextController(text: sets.toString()),
              decoration: InputDecoration(
                labelText: "Séries",
                hintText: sets > 0 ? sets.toString() : "0",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  sets = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: CustomTextController(text: reps.toString()),
              decoration: InputDecoration(
                labelText: "Repetições",
                hintText: reps > 0 ? reps.toString() : "0",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  reps = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: CustomTextController(text: weight.toString()),
              decoration: InputDecoration(
                labelText: "Peso",
                hintText: weight > 0 ? weight.toString() : "0",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  weight = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveExercise,
              child: const Text("Salvar"),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
