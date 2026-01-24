import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/students/data/repositories/student_repository.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';
import 'package:my_academy/features/students/presentation/pages/students_page.dart';

void main() {
  testWidgets('StudentsPage renders correctly with data',
      (WidgetTester tester) async {
    // Mock user
    const user = UserEntity(
      id: 'trainer1',
      name: 'Trainer',
      email: 'trainer@example.com',
    );

    // Mock students
    const students = [
      StudentEntity(
        id: '1',
        name: 'Student 1',
        email: 's1@example.com',
      ),
      StudentEntity(
        id: '2',
        name: 'Student 2',
        email: 's2@example.com',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier(user)),
          studentsProvider('trainer1').overrideWith((ref) => Future.value(students)),
        ],
        child: const MaterialApp(
          home: StudentsPage(),
        ),
      ),
    );

    // Initial load
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Alunos'), findsOneWidget);
    expect(find.text('Student 1'), findsOneWidget);
    expect(find.text('Student 2'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('StudentsPage renders correctly when empty',
      (WidgetTester tester) async {
    // Mock user
    const user = UserEntity(
      id: 'trainer1',
      name: 'Trainer',
      email: 'trainer@example.com',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier(user)),
          studentsProvider('trainer1').overrideWith((ref) => Future.value([])),
        ],
        child: const MaterialApp(
          home: StudentsPage(),
        ),
      ),
    );

    // Initial load
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Nenhum aluno encontrado'), findsOneWidget);
    expect(find.text('Adicionar Aluno'), findsOneWidget);
  });
}

// Mock Auth Notifier
class MockAuthNotifier extends AuthNotifier {
  final UserEntity? _initialUser;

  MockAuthNotifier(this._initialUser);

  @override
  Future<UserEntity?> build() async {
    return _initialUser;
  }
}
