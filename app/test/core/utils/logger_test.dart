import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/utils/logger.dart';
import 'package:logger/logger.dart';

void main() {
  test('logger should be initialized', () {
    expect(logger, isA<Logger>());
  });
}
