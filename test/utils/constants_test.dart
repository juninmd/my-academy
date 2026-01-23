import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/utils/constants.dart';

void main() {
  test('constants should have correct values', () {
    expect(baseUrl, isNotEmpty);
    expect(mockAuthToken, isNotEmpty);
    expect(useMockAuth, isA<bool>());
  });
}
