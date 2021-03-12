library toml.test.ast.date_time.local_time_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlLocalTime', () {
    group('hashCode', () {
      test('two equal local times have the same hash code', () {
        var t1 = TomlLocalTime(TomlPartialTime(17, 53, 0));
        var t2 = TomlLocalTime(TomlPartialTime(17, 53, 0));
        expect(t1.hashCode, equals(t2.hashCode));
      });
      test('two different local times have different hash codes', () {
        var t1 = TomlLocalTime(TomlPartialTime(17, 53, 0));
        var t2 = TomlLocalTime(TomlPartialTime(20, 17, 0));
        expect(t1.hashCode, isNot(equals(t2.hashCode)));
      });
    });
    group('atTime', () {
      test('builds local date-time at the given time', () {
        var date = TomlFullDate(1989, 11, 9);
        var time = TomlPartialTime(17, 53, 0);
        var localTime = TomlLocalTime(time);
        var localDateTime = localTime.atDate(date);
        expect(localDateTime.date, equals(date));
        expect(localDateTime.time, equals(time));
      });
    });
  });
}
