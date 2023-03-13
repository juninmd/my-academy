import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'exercise.dart';

class ExerciseEditPage extends StatefulWidget {
  final Exercise exercise;

  ExerciseEditPage({required this.exercise});

  @override
  _ExerciseEditPageState createState() => _ExerciseEditPageState();
}

class _ExerciseEditPageState extends State<ExerciseEditPage> {
  late String name;
  late String image;
  late int sets;
  late int reps;
  late int weight;

  @override
  void initState() {
    super.initState();
    name = widget.exercise.name;
    image = widget.exercise.image;
    sets = widget.exercise.sets;
    reps = widget.exercise.reps;
    weight = widget.exercise.weight;
  }

  void _saveExercise() {
    if (weight > 0) {
      Fluttertoast.showToast(
        msg: "Parabéns! Você levantou uma carga maior desta vez!",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
    // Adicione aqui a lógica para salvar os valores de sets, reps, weight
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Exercício"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              widget.exercise.image,
              height: 200,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 16),
            Text(
              widget.exercise.name,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Séries",
                hintText: sets > 0 ? sets.toString() : "0",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  sets = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Repetições",
                hintText: reps > 0 ? reps.toString() : "0",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  reps = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: "Peso",
                hintText: weight > 0 ? weight.toString() : "0",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  weight = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveExercise,
              child: Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }
}
