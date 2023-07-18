import 'package:flutter/material.dart';

class ClassesPage extends StatelessWidget {
  final List<Student> students = [
    Student(
      name: 'CBUM',
      profilePicture:
      'https://cultura.uol.com.br/upload/tvcultura/esporte/20230531122015_screenshot-20230531-121938-instagram-1-.jpg',
      classHour: '09:00',
      age: 18,
      location: 'City A',
    ),
    Student(
      name: 'Ramon Dino',
      profilePicture:
      'https://ac24horas.com/wp-content/uploads/2022/12/Ramon-Dino-1280x720.jpg',
      classHour: '10:30',
      age: 20,
      location: 'City B',
    ),
    // Add more students here...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aulas do dia'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            color: Colors.black45, // Set the desired background color
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  'Professor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white, // Set the desired text color
                  ),
                ),
                SizedBox(height: 8),
                CircleAvatar(
                  backgroundImage: Image.network(
                      'https://p2.trrsf.com/image/fget/cf/1200/1600/middle/images.terra.com/2023/05/10/53361422-arnold-schwarzenegger.jpg')
                      .image,
                  radius: 40,
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text(
                '${students.length} alunos hoje',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                return StudentCard(
                  student: students[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Student {
  final String name;
  final String profilePicture;
  final String classHour;
  final int age;
  final String location;

  Student({
    required this.name,
    required this.profilePicture,
    required this.classHour,
    required this.age,
    required this.location,
  });
}

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: Image.network(student.profilePicture).image,
        ),
        title: Text(student.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Horário: ${student.classHour}'),
            SizedBox(height: 4),
            Text('Idade: ${student.age}'),
            SizedBox(height: 4),
            Text('Localização: ${student.location}'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward),
        onTap: () {
          // Handle student card tap
        },
      ),
    );
  }
}
