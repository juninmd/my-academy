import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_academy/pages/workout_group_page.dart';

import '../constants.dart';
import '../dto/student-dto.dart';
import '../services/my_academy/personal_api.dart';
import 'add_student_page.dart';

final studentsPageStoreProvider =
    ChangeNotifierProvider((ref) => StudentsPageStore());

class StudentsPage extends HookConsumerWidget {
  const StudentsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final StudentsPageStore store = ref.watch(studentsPageStoreProvider);

    useEffect(() {
      store.loadValues();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text('Alunos'),
        backgroundColor: Colors.deepPurple,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 1,
                  child: ListTile(
                    leading: Icon(Icons.people_alt_rounded),
                    title: Text('Adicionar alunos'),
                  ),
                ),
              ],
              onSelected: (int value) async {
                switch (value) {
                  case 1:
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddStudentPage(),
                      ),
                    );
                    break;
                }
              },
            )
        ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "${store.students.length} aluno(s)",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: store.isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : store.students.isEmpty
                    ? Center(
                        child: Text('Nenhum aluno encontrado.'),
                      )
                    : ListView.builder(
                        itemCount: store.students.length,
                        itemBuilder: (context, index) {
                          return StudentCard(
                            student: store.students[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class StudentCard extends StatelessWidget {
  final StudentDto student;

  const StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(student.student.photoUrl!),
              ),
            ),
            SizedBox(height: 16),
            Text(
              student.student.name!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Último treino: pernas - ${_formatDate(DateTime.now())}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: student.schedule.map((schedule) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Dia: ${getDayOfWeekName(schedule.dayOfWeek)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Horário: ${schedule.time}',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WorkoutGroupPage(student.student.id!),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}



class StudentsPageStore extends ChangeNotifier {
  List<StudentDto> students = [];
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      students = await getStudents(FireBaseUser!.uid);
    } catch (error) {
      students = [];
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
