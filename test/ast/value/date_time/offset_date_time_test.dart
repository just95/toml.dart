import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlOffsetDateTime', () {
    group('hashCode', () {
      test('two equal offset date-times have the same hash code', () {
        var d1 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.utc(),
        );
        var d2 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.utc(),
        );
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test(
        'offset date-times with different dates have different hash codes',
        () {
          var d1 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.utc(),
          );
          var d2 = TomlOffsetDateTime(
            TomlFullDate(1969, 7, 20),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.utc(),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
      test(
        'offset date-times with different times have different hash codes',
        () {
          var d1 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.utc(),
          );
          var d2 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(20, 17, 0),
            TomlTimeZoneOffset.utc(),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
      test('offset date-times with utc and positive offsets have different '
          'hash codes', () {
        var d1 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.utc(),
        );
        var d2 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.positive(1, 0),
        );
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
      test('offset date-times with utc and negative offsets have different '
          'hash codes', () {
        var d1 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.utc(),
        );
        var d2 = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.negative(1, 0),
        );
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
      test(
        'offset date-times with positive and negative offsets have different '
        'hash codes',
        () {
          var d1 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.positive(1, 0),
          );
          var d2 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.negative(1, 0),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
      test(
        'offset date-times with different offsets that identify the same point '
        'in time have different hash codes',
        () {
          var d1 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(17, 53, 0),
            TomlTimeZoneOffset.utc(),
          );
          var d2 = TomlOffsetDateTime(
            TomlFullDate(1989, 11, 9),
            TomlPartialTime(18, 53, 0),
            TomlTimeZoneOffset.positive(1, 0),
          );
          expect(d1.toUtcDateTime(), equals(d2.toUtcDateTime()));
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
    });
    group('fromDateTime', () {
      test('converts date-times with second precision correctly', () {
        expect(
          TomlOffsetDateTime.fromDateTime(DateTime.utc(1989, 11, 9, 17, 53)),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test('converts date-times with millisecond precision correctly', () {
        expect(
          TomlOffsetDateTime.fromDateTime(
            DateTime.utc(1989, 11, 9, 17, 53, 0, 123),
          ),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0, [123]),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test(
        'converts non-utc date-times to offset date-times in local time zone',
        () {
          var dateTime = DateTime(1989, 11, 9, 17, 53);
          expect(
            TomlOffsetDateTime.fromDateTime(dateTime),
            equals(
              TomlOffsetDateTime(
                TomlFullDate(1989, 11, 9),
                TomlPartialTime(17, 53, 0),
                TomlTimeZoneOffset.localAtInstant(dateTime),
              ),
            ),
          );
        },
      );
    });
    group('toUtcDateTime', () {
      test('converts date-times with positive offset correctly', () {
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
      test('converts date-times with negative offset correctly', () {
        var offsetDateTime = TomlOffsetDateTime(
          TomlFullDate(2017, 6, 6),
          TomlPartialTime(12, 34, 56),
          TomlTimeZoneOffset.negative(5, 0),
        );
        expect(
          offsetDateTime.toUtcDateTime(),
          equals(DateTime.utc(2017, 6, 6, 17, 34, 56)),
        );
      });
    });
  });
}
