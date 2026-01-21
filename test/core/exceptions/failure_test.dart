import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/exceptions/failure.dart';

void main() {
  group('Failure', () {
    test('ServerFailure should have correct props', () {
      const failure = ServerFailure('Server Error', statusCode: 500);
      expect(failure.message, 'Server Error');
      expect(failure.statusCode, 500);
      expect(failure.props, ['Server Error', 500]);
    });

    test('NetworkFailure should have correct props', () {
      const failure = NetworkFailure('Network Error');
      expect(failure.message, 'Network Error');
      expect(failure.statusCode, null);
      expect(failure.props, ['Network Error', null]);
    });

    test('CacheFailure should have correct props', () {
      const failure = CacheFailure('Cache Error');
      expect(failure.message, 'Cache Error');
      expect(failure.statusCode, null);
      expect(failure.props, ['Cache Error', null]);
    });

    test('AuthFailure should have correct props', () {
      const failure = AuthFailure('Auth Error');
      expect(failure.message, 'Auth Error');
      expect(failure.statusCode, null);
      expect(failure.props, ['Auth Error', null]);
    });
  });
}
