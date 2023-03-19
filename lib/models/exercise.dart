class Exercise {
  String name;
  String image;
  int sets;
  int id;
  int reps;
  int weight;
  bool finish;
  int muscleGroup;

  Exercise({required this.id, required this.name, required this.image,
    required this.sets, required this.reps, required this.weight, this.finish = false,
 required this.muscleGroup});
}