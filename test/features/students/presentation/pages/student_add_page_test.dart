import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/students/data/repositories/student_repository.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';
import 'package:my_academy/features/students/presentation/pages/student_add_page.dart';

@GenerateNiceMocks([MockSpec<StudentRepository>()])
import 'student_add_page_test.mocks.dart';

class FakeAuthNotifier extends AsyncNotifier<UserEntity?> {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  late MockStudentRepository mockRepository;

  setUp(() {
    mockRepository = MockStudentRepository();
  });

  testWidgets('StudentAddPage adds student', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(
          const UserEntity(id: 'u1', email: 'e', name: 'n')
        )),
        studentRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: const MaterialApp(
        home: StudentAddPage(),
      ),
    ));

    expect(find.text('Adicionar Aluno'), findsOneWidget);

    // Fill form
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'new@student.com');
    await tester.testTextInput.receiveAction(TextInputAction.next); // Trigger checkEmail if using onFieldSubmitted

    when(mockRepository.checkStudentExists(any)).thenAnswer((_) async => const Right(null));
    when(mockRepository.addStudent(any, any)).thenAnswer((_) async => const Right(
       StudentEntity(id: '1', name: 'New Student', email: 'new@student.com')
    ));

    await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'), 'New Student');

    await tester.pump();

    // Submit
    // Find button. It is in AppBar actions.
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    verify(mockRepository.addStudent(any, 'u1')).called(1);
  });
}
