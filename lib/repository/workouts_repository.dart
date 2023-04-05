import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_group_repository.dart';

// exercise_group_of_day = Id do exercício do dia
// exercise_frequency = vai salvando quantos dias vou treinando
// last_exercise_date = dia do último exercício feito
// last_exercise_group = Id do último exercício feito.

String getWeekDay() {
  DateTime dateNow = DateTime.now();
  List<String> diasDaSemana = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo'
  ];
  return diasDaSemana[dateNow.weekday - 1];
}

Future<int> getExerciseIdOfDay() async {
  final prefs = await SharedPreferences.getInstance();
  final exerciseOfDay = prefs.getInt('exercise_group_of_day') ?? 0;
  return exerciseOfDay;
}

void setExerciseOfDay(int exerciseGroupId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('exercise_group_of_day', exerciseGroupId);
}

Future<int> getLastExercise() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final exerciseOfDay = prefs.getInt('last_exercise_group') ?? 0;
  return exerciseOfDay;
}

void setLastExercise(int exerciseGroupId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('last_exercise_group', exerciseGroupId);
}

Future<int> getExerciseFrequency() async {
  final prefs = await SharedPreferences.getInstance();
  final exerciseFrequency = prefs.getInt('exercise_frequency') ?? 0;
  return exerciseFrequency;
}

Future<void> setExerciseFrequency(int exerciseFrequency) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('exercise_frequency', exerciseFrequency);
}

Future<String?> getLastExerciseDate() async {
  final prefs = await SharedPreferences.getInstance();
  final exerciseFrequency = prefs.getString('last_exercise_date');
  return exerciseFrequency;
}

Future<void> setLastExerciseDate(String date) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('last_exercise_date', date);
}

Future<void> checkExerciseOfDay() async {
  DateTime dateNow = DateTime.now();
  String? lastDayExercise = await getLastExerciseDate();

  // Se o último exercício realizado já foi hoje para a lógica
  if ("${dateNow.day}/${dateNow.month}/${dateNow.year}" == lastDayExercise) {
    return;
  }

  // Pega o dia atual
  String currentDay = getWeekDay();

  // Se faltou na quinta ou na sexta perde a frequência
  if (currentDay == 'Sexta' || currentDay == 'Sábado') {
    if (lastDayExercise !=
        dateNow.add(const Duration(days: -1)).toIso8601String()) {
      // Perdeu a frequência
      await setExerciseFrequency(0);
    }
  }

  // Se faltou no sábado perde a frequência
  if (currentDay == 'Segunda') {
    if (lastDayExercise !=
        dateNow.add(const Duration(days: -2)).toIso8601String()) {
      // Perdeu a frequência
      await setExerciseFrequency(0);
    }
  }

  int lastExercise = await getLastExercise();
  if (currentDay == 'Sábado' ||
      currentDay == 'Quinta' ||
      currentDay == 'Sexta') {
    int exerciseIdOfDay = (lastExercise + 1) % exerciseGroups.length;
    setExerciseOfDay(exerciseIdOfDay);
  } else if (currentDay == 'Segunda') {
    setExerciseOfDay(0);
  } else if (currentDay == 'Terça') {
    setExerciseOfDay(1);
  } else if (currentDay == 'Quarta') {
    setExerciseOfDay(2);
  } else {
    // Se for segunda / terça / quarta tem personal
    // Se for domingo é descanso
    setExerciseOfDay(0);
  }
}

Future<void> saveExerciseOfDay() async {
  DateTime dateNow = DateTime.now();
  String? lastDayExercise = await getLastExerciseDate();

  // Se o último exercício realizado já foi hoje para a lógica
  if ("${dateNow.day}/${dateNow.month}/${dateNow.year}" == lastDayExercise) {
    return;
  }

  // Aumenta a frequência de exercícios
  int exerciseFrequency = await getExerciseFrequency();
  await setExerciseFrequency(exerciseFrequency + 1);

  // pega qual foi o último exercício e acrescenta 1
  int lastExercise = await getLastExercise();
  int exerciseIdOfDay = (lastExercise + 1) % exerciseGroups.length;
  setLastExercise(exerciseIdOfDay);

  await setLastExerciseDate("${dateNow.day}/${dateNow.month}/${dateNow.year}");
}

Future<void> clearAll() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
}

Future<bool> checkAlreadWorkoutToday() async {
  DateTime dateNow = DateTime.now();
  String? lastDayExercise = await getLastExerciseDate();

  // Se o último exercício realizado já foi hoje para a lógica
  if ("${dateNow.day}/${dateNow.month}/${dateNow.year}" == lastDayExercise) {
    return true;
  }
  return false;
}
