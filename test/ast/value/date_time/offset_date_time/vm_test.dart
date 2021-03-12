@TestOn('vm')
library toml.test.ast.date_time.offset_date_time_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlOffsetDateTime', () {
    group('fromDateTime', () {
      group('VM', () {
        test('converts date-times with microsecond precision correctly', () {
          expect(
            TomlOffsetDateTime.fromDateTime(
              DateTime.utc(1989, 11, 9, 17, 53, 0, 123, 456),
            ),
            equals(TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0, [123, 456]),
              TomlTimeZoneOffset.utc(),
            )),
          );
        });
        test('converts date-times with micro- but no milliseconds correctly',
            () {
          expect(
            TomlOffsetDateTime.fromDateTime(
              DateTime.utc(1989, 11, 9, 17, 53, 0, 0, 123),
            ),
            equals(TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0, [0, 123]),
              TomlTimeZoneOffset.utc(),
            )),
          );
        });
      });
    });
  });
}
