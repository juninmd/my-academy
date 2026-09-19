import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_role.dart';

void main() {
  test('gym owners onboard as OWNER, never as ADMIN', () {
    expect(UserRole.owner.apiValue, 'OWNER');
    expect(UserRole.fromApi('OWNER'), UserRole.owner);
  });

  test('an ADMIN account still gets the gym owner navigation', () {
    expect(UserRole.fromApi('ADMIN'), UserRole.owner);
  });

  test('unknown or missing roles fall back to student', () {
    expect(UserRole.fromApi(null), UserRole.student);
    expect(UserRole.fromApi('SUPERUSER'), UserRole.student);
    expect(UserRole.fromApi('PERSONAL'), UserRole.personal);
  });
}
