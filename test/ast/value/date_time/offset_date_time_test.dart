library toml.test.ast.date_time.offset_date_time_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlOffsetDateTime', () {
    group('toUtcDateTime', () {
      test('converts date-times with numeric offset correctly', () {
        var offsetDateTime = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(18, 53, 0),
          TomlTimeZoneOffset.positive(1, 0),
        );
        expect(
          offsetDateTime.toUtcDateTime(),
          equals(DateTime.utc(1989, 11, 9, 17, 53)),
        );
      });
    });
  });
}
