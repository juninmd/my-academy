import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';
import 'package:my_academy/features/students/presentation/pages/student_details_page.dart';

void main() {
  testWidgets('StudentDetailsPage displays info', (tester) async {
    const student = StudentEntity(
      id: '1',
      name: 'John Doe',
      email: 'john@example.com',
    );

    await tester.pumpWidget(const ProviderScope(
      child: MaterialApp(
        home: StudentDetailsPage(student: student),
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);

    // Scroll to find elements at bottom
    await tester.dragUntilVisible(
      find.text('Email'),
      find.byType(CustomScrollView),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });
}
