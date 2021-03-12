library toml.test.ast.date_time.local_date_time_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlLocalDateTime', () {
    group('hashCode', () {
      test('two equal local date-times have the same hash code', () {
        var d1 = TomlLocalDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
        );
        var d2 = TomlLocalDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
        );
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test(
        'local date-times with different dates have different hash codes',
        () {
          var d1 = TomlLocalDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
          );
          var d2 = TomlLocalDateTime(
            TomlFullDate(1969, 7, 20),
            TomlPartialTime(17, 53, 0),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
      test(
        'local date-times with different times have different hash codes',
        () {
          var d1 = TomlLocalDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
          );
          var d2 = TomlLocalDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(20, 17, 0),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
    });
    group('withOffset', () {
      test('builds offset date-time at the given offset', () {
        var date = TomlFullDate(1989, 11, 9);
        var time = TomlPartialTime(18, 53, 0);
        var offset = TomlTimeZoneOffset.positive(1, 0);
        var localDateTime = TomlLocalDateTime(date, time);
        var offsetDateTime = localDateTime.withOffset(offset);
        expect(offsetDateTime.date, equals(date));
        expect(offsetDateTime.time, equals(time));
        expect(offsetDateTime.offset, equals(offset));
      });
    });
  });
}
