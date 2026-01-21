import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/students/domain/entities/student_entity.dart';

void main() {
  group('StudentEntity', () {
    test('should have correct props', () {
      const student = StudentEntity(
        id: '1',
        name: 'John Doe',
        email: 'john@example.com',
        photoUrl: 'https://example.com/photo.jpg',
      );

      expect(student.id, '1');
      expect(student.name, 'John Doe');
      expect(student.email, 'john@example.com');
      expect(student.photoUrl, 'https://example.com/photo.jpg');
      expect(student.props, ['1', 'John Doe', 'john@example.com', 'https://example.com/photo.jpg']);
    });
  });
}
