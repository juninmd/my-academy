import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    test('should have correct props', () {
      const user = UserEntity(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        photoUrl: 'http://example.com/photo.jpg',
        role: 'student',
      );

      expect(user.id, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test User');
      expect(user.photoUrl, 'http://example.com/photo.jpg');
      expect(user.role, 'student');
      expect(user.props, [
        '123',
        'test@example.com',
        'Test User',
        'http://example.com/photo.jpg',
        'student',
      ]);
    });
  });
}
