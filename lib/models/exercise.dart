class Exercise {
  String name;
  String image;
  int sets;
  int id;
  int reps;
  int weight;
  bool finish;
  int exerciseGroup;
  List<String> tips;
  List<String> errors;

  Exercise({required this.id, required this.name, required this.image,
    required this.sets, required this.reps, required this.weight, this.finish = false,
 required this.exerciseGroup, required this.tips, required this.errors});
}