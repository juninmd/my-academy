import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_academy/core/exceptions/failure.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/students/data/repositories/student_repository.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';
import 'package:my_academy/features/students/presentation/pages/student_add_page.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

class FakeStudentRepository implements StudentRepository {
  bool addStudentCalled = false;

  @override
  Future<Either<Failure, StudentEntity>> addStudent(
    StudentEntity student,
    String personalId,
  ) async {
    addStudentCalled = true;
    return const Right(
      StudentEntity(id: '1', name: 'New Student', email: 'new@student.com'),
    );
  }

  @override
  Future<Either<Failure, StudentEntity?>> checkStudentExists(
    String email,
  ) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<StudentEntity>>> getStudents(
    String userId,
  ) async {
    return const Right([]);
  }

  @override
  Future<bool> isPersonal(String userId) async {
    return true;
  }
}

void main() {
  testWidgets('StudentAddPage adds student', (tester) async {
    final fakeRepository = FakeStudentRepository();

    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder:
              (context, state) => Scaffold(
                body: TextButton(
                  onPressed: () => context.push('/add'),
                  child: const Text('Go Add'),
                ),
              ),
        ),
        GoRoute(
          path: '/add',
          builder: (context, state) => const StudentAddPage(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => FakeAuthNotifier(
              const UserEntity(id: 'u1', email: 'e', name: 'n'),
            ),
          ),
          studentRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    // Wait for auth provider to settle
    await tester.pumpAndSettle();

    // Navigate to Add Page
    await tester.tap(find.text('Go Add'));
    await tester.pumpAndSettle();

    expect(find.text('Adicionar Aluno'), findsAtLeastNWidgets(1));

    // Fill form
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'new@student.com',
    );
    await tester.testTextInput.receiveAction(TextInputAction.next);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nome completo'),
      'New Student',
    );

    await tester.pump();

    // Submit
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(fakeRepository.addStudentCalled, true);
  });
}
