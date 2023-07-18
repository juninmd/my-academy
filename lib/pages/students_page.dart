import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:my_academy/pages/workout_group_page.dart';

import '../constants.dart';
import '../models/workout_personal_session.dart';
import '../services/my_academy/workout_personals_sessions_api.dart';

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
        title: Text('Aulas do dia'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(
                "${store.students.length} alunos hoje",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
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
  final WorkoutPersonalSession student;

  const StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(student.users.photoUrl),
        ),
        title: Text(student.users.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Horário: ${DateFormat('HH:mm').format(student.date.toUtc())}'),
            SizedBox(height: 4),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  WorkoutGroupPage(student.userId, student.users.name),
            ),
          );
        },
      ),
    );
  }
}

class StudentsPageStore extends ChangeNotifier {
  List<WorkoutPersonalSession> students = [];
  bool isLoading = true;

  Future<void> loadValues() async {
    try {
      isLoading = true;
      students = await getStudentsSessions(
          idUser);
    } catch (error) {
      print(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
