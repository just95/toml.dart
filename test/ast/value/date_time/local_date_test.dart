library toml.test.ast.date_time.local_date_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlLocalDate', () {
    group('hashCode', () {
      test('two equal local dates have the same hash code', () {
        var d1 = TomlLocalDate(TomlFullDate(1989, 11, 9));
        var d2 = TomlLocalDate(TomlFullDate(1989, 11, 9));
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test('two different local dates have different hash codes', () {
        var d1 = TomlLocalDate(TomlFullDate(1989, 11, 9));
        var d2 = TomlLocalDate(TomlFullDate(1969, 7, 20));
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
    });
    group('atTime', () {
      test('builds local date-time at the given time', () {
        var date = TomlFullDate(1989, 11, 9);
        var time = TomlPartialTime(17, 53, 0);
        var localDate = TomlLocalDate(date);
        var localDateTime = localDate.atTime(time);
        expect(localDateTime.date, equals(date));
        expect(localDateTime.time, equals(time));
      });
    });
  });
}
