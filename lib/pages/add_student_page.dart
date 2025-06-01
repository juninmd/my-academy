import 'package:flutter/material.dart';
import 'package:my_academy/services/my_academy/personal_api.dart';

import '../constants.dart';
import '../dto/student-dto.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../services/my_academy/user_api.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({Key? key}) : super(key: key);

  @override
  _AddStudentPageState createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final TextEditingController _emailController = TextEditingController();
  final List<bool> _selectedDays = List.generate(7, (index) => false);
  TimeOfDay _selectedTime = TimeOfDay(hour: 12, minute: 0);

  final List<Schedule> schedules = [];
  Users? student;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Aluno'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (student != null)
              Card(
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
                          backgroundImage: NetworkImage(student!.photoUrl!),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        student!.name!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
              onChanged: (value) {
                searchUsersByEmail(value);
              },
            ),
            SizedBox(height: 16),
            Text(
              'Dias da Semana',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: List.generate(
                7,
                (index) => FilterChip(
                  label: Text(getDayOfWeekName(index + 1)),
                  selected: _selectedDays[index],
                  onSelected: (selected) {
                    setState(() {
                      _selectedDays[index] = selected;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Horário',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              children: List.generate(
                7,
                (index) {
                  if (_selectedDays[index]) {
                    return ListTile(
                      title: Text(
                        'Horário de ${getDayOfWeekName(index + 1)}: ${_selectedTime.format(context)}',
                      ),
                      trailing: Icon(Icons.access_time),
                      onTap: () => _selectTime(index),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                },
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                _addStudent();
              },
              icon: Icon(Icons.person_add),
              label: Text('Adicionar Aluno'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(int dayIndex) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> searchUsersByEmail(String email) async {
    try {
      setState(() async {
        student = await getUserByEmail(email);
      });
    } catch (Exception) {
      setState(() async {
        student = null;
      });
    }
  }

  void _addStudent() async {
    // Collect selected days
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        schedules.add(Schedule(
            dayOfWeek: i + 1,
            time: _selectedTime.format(context),
            personalsId: 1 // todo
            ));
      }
    }
    _createStudents();
  }

  void _createStudents() async {
    // Collect email
    final String email = _emailController.text;

    // Prepare payload
    var payload = StudentDto(schedule: schedules, student: Users(email: email));

    // Post data to API
    try {
      await postStudents(FireBaseUser!.uid, payload);
      // Optionally show success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aluno adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      // Handle errors
      print('Error adding student: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar aluno.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
