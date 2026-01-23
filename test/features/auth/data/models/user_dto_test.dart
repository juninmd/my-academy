import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/data/models/user_dto.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';

void main() {
  const userDto = UserDto(
    id: '1',
    email: 'test@test.com',
    name: 'Test',
    photoUrl: 'url',
    role: 'student',
  );

  test('fromJson should return a valid model', () {
    final Map<String, dynamic> jsonMap = {
      'id': '1',
      'email': 'test@test.com',
      'name': 'Test',
      'photoUrl': 'url',
      'role': 'student',
    };

    final result = UserDto.fromJson(jsonMap);
    expect(result, userDto);
  });

  test('toJson should return a JSON map', () {
    final result = userDto.toJson();
    final expectedJson = {
      'id': '1',
      'email': 'test@test.com',
      'name': 'Test',
      'photoUrl': 'url',
      'role': 'student',
    };
    expect(result, expectedJson);
  });

  test('fromEntity should return a valid UserDto', () {
      const entity = UserEntity(
        id: '1',
        email: 'test@test.com',
        name: 'Test',
        photoUrl: 'url',
        role: 'student',
      );
      final result = UserDto.fromEntity(entity);
      expect(result, userDto);
  });
}
