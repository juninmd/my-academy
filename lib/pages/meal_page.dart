import 'package:flutter/material.dart';

class Meal {
  final String name;
  final String description;
  final String photoUrl;
  final TimeOfDay time;
  List<String> substitutions = [];

  Meal(
      {required this.name,
      required this.description,
      required this.photoUrl,
      required this.time,
      required this.substitutions});
}

class MealPage extends StatefulWidget {
  const MealPage({Key? key}) : super(key: key);
  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final List<Meal> meals = [
    Meal(
      name: 'Café da manhã',
      description: 'Pão, queijo, presunto, café e suco',
      photoUrl: 'https://picsum.photos/200',
      time: const TimeOfDay(hour: 8, minute: 0),
      substitutions: [],
    ),
    Meal(
      name: 'Almoço',
      description: 'Arroz, feijão, bife e salada',
      photoUrl: 'https://picsum.photos/200',
      time: const TimeOfDay(hour: 12, minute: 0),
      substitutions: [],
    ),
    Meal(
      name: 'Jantar',
      description: 'Sopa, pão e suco',
      photoUrl: 'https://picsum.photos/200',
      time: const TimeOfDay(hour: 18, minute: 0),
      substitutions: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 1,
          title: const Text(
            "Alimentação",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: meals.length,
          itemBuilder: (context, index) {
            final meal = meals[index];

            return Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        meal.photoUrl,
                        height: 200.0,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 8.0,
                        left: 16.0,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Colors.white,
                              size: 18.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              meal.time.format(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(meal.description),
                  const SizedBox(height: 16.0),
                  Row(children: const [
                    Icon(Icons.star, color: Colors.yellow),
                    SizedBox(width: 8.0),
                    Icon(Icons.star, color: Colors.yellow),
                    SizedBox(width: 8.0),
                    Icon(Icons.star, color: Colors.yellow),
                    SizedBox(width: 8.0),
                    Icon(Icons.star_half, color: Colors.yellow),
                    SizedBox(width: 8.0),
                  ]),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Possible substitutions:',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meal.substitutions.length,
                    itemBuilder: (context, index) {
                      final substitution = meal.substitutions[index];

                      return Text(
                        '- $substitution',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        )
    );
  }
}
