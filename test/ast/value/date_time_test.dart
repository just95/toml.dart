import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlFullDate', () {
    group('constructor', () {
      test('cannot construct date with month greater than 12', () {
        expect(
          () => TomlFullDate(1995, 17, 7),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct date with month less than 1', () {
        expect(
          () => TomlFullDate(1998, 0, 9),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct date with day less than 1', () {
        expect(
          () => TomlFullDate(1995, 17, 0),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct date with day after last day of the month', () {
        expect(
          () => TomlFullDate(1998, 1, 32),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
        expect(
          () => TomlFullDate(1998, 11, 31),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct date for february 29th in non leap years', () {
        expect(() => TomlFullDate(1996, 2, 29), returnsNormally);
        expect(
          () => TomlFullDate(1995, 2, 29),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
    });
    group('toString', () {
      test('converts date to string', () {
        expect(TomlFullDate(1995, 7, 17).toString(), equals('1995-07-17'));
      });
    });
  });
  group('TomlPartialTime', () {
    group('constructor', () {
      test('cannot construct time with negative hour', () {
        expect(
          () => TomlPartialTime(-1, 23, 45),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with hour greater than 23', () {
        expect(
          () => TomlPartialTime(24, 23, 45),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with negative minute', () {
        expect(
          () => TomlPartialTime(1, -23, 45),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with minute greater than 59', () {
        expect(
          () => TomlPartialTime(1, 60, 45),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with negative second', () {
        expect(
          () => TomlPartialTime(1, 23, -45),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with second greater than 60', () {
        expect(
          () => TomlPartialTime(1, 23, 61),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('can construct time for leap second', () {
        expect(TomlPartialTime(1, 23, 60).second, equals(60));
      });
      test('can construct time without fractional seconds', () {
        expect(TomlPartialTime(1, 23, 45).secondFractions, isEmpty);
      });
      test('can construct time with fractional seconds', () {
        expect(
          TomlPartialTime(1, 23, 45, [678]).secondFractions,
          equals([678]),
        );
      });
      test('can construct time with zero fractional seconds', () {
        expect(TomlPartialTime(1, 23, 45, [0]).secondFractions, equals([0]));
      });
      test('cannot construct time with negative fractional second', () {
        expect(
          () => TomlPartialTime(1, 23, 45, [-679]),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct time with fractional second greater than 999', () {
        expect(
          () => TomlPartialTime(1, 23, 45, [1000]),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('can construct time with more than nanosecond precision', () {
        expect(
          TomlPartialTime(0, 0, 0, [1, 1, 1, 1, 1, 1]).secondFractions.length,
          equals(6),
        );
      });
    });
    group('millisecond', () {
      test('gets the first element of the second fractions', () {
        expect(
          TomlPartialTime(0, 0, 0, [123, 456, 789]).millisecond,
          equals(123),
        );
      });
      test('defaults to zero', () {
        expect(TomlPartialTime(0, 0, 0).millisecond, equals(0));
      });
    });
    group('microsecond', () {
      test('gets the second element of the second fractions', () {
        expect(
          TomlPartialTime(0, 0, 0, [123, 456, 789]).microsecond,
          equals(456),
        );
      });
      test('defaults to zero', () {
        expect(TomlPartialTime(0, 0, 0, [123]).microsecond, equals(0));
      });
    });
    group('nanosecond', () {
      test('gets the third element of the second fractions', () {
        expect(
          TomlPartialTime(0, 0, 0, [123, 456, 789]).nanosecond,
          equals(789),
        );
      });
      test('defaults to zero', () {
        expect(TomlPartialTime(0, 0, 0, [123, 456]).nanosecond, equals(0));
      });
    });
    group('toString', () {
      test('can convert time without second fractions to a string', () {
        expect(TomlPartialTime(1, 23, 45).toString(), equals('01:23:45'));
      });
      test('can convert time with milliseconds to a string', () {
        expect(
          TomlPartialTime(1, 23, 45, [678]).toString(),
          equals('01:23:45.678'),
        );
      });
      test('can convert time with nanoseconds to a string', () {
        expect(
          TomlPartialTime(1, 23, 45, [6, 7, 8]).toString(),
          equals('01:23:45.006007008'),
        );
      });
    });
  });
  group('TomlTimeZoneOffset', () {
    group('positive', () {
      test('cannot construct offset with negative hours', () {
        expect(
          () => TomlTimeZoneOffset.positive(-1, 0),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with hours greater than 23', () {
        expect(
          () => TomlTimeZoneOffset.positive(24, 0),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with negative minutes', () {
        expect(
          () => TomlTimeZoneOffset.positive(0, -1),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with minutes greater than 59', () {
        expect(
          () => TomlTimeZoneOffset.positive(0, 60),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
    });
    group('negative', () {
      test('cannot construct offset with negative hours', () {
        expect(
          () => TomlTimeZoneOffset.negative(-1, 0),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with hours greater than 23', () {
        expect(
          () => TomlTimeZoneOffset.negative(24, 0),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with negative minutes', () {
        expect(
          () => TomlTimeZoneOffset.negative(0, -1),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('cannot construct offset with minutes greater than 59', () {
        expect(
          () => TomlTimeZoneOffset.negative(0, 60),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
    });
    group('fromDuration', () {
      test('can convert positive hours to a time-zone offset', () {
        expect(
          TomlTimeZoneOffset.fromDuration(Duration(hours: 1)),
          equals(TomlTimeZoneOffset.positive(1, 0)),
        );
      });
      test('can convert positive minutes to a time-zone offset', () {
        expect(
          TomlTimeZoneOffset.fromDuration(Duration(minutes: 90)),
          equals(TomlTimeZoneOffset.positive(1, 30)),
        );
      });
      test('can convert negative hours to a time-zone offset', () {
        expect(
          TomlTimeZoneOffset.fromDuration(Duration(hours: -1)),
          equals(TomlTimeZoneOffset.negative(1, 0)),
        );
      });
      test('can convert negative minutes to a time-zone offset', () {
        expect(
          TomlTimeZoneOffset.fromDuration(Duration(minutes: -90)),
          equals(TomlTimeZoneOffset.negative(1, 30)),
        );
      });
    });
    group('local', () {
      test('creates a non-UTC time zone offset', () {
        expect(TomlTimeZoneOffset.local().isUtc, isFalse);
      });
    });
    group('localAtInstant', () {
      test('creates a non-UTC time zone offset from local DateTime', () {
        expect(
          TomlTimeZoneOffset.localAtInstant(DateTime(1989, 11, 9)).isUtc,
          isFalse,
        );
      });
      test('creates a non-UTC time zone offset from UTC DateTime', () {
        expect(
          TomlTimeZoneOffset.localAtInstant(DateTime.utc(1989, 11, 9)).isUtc,
          isFalse,
        );
      });
    });
    group('toString', () {
      test('can convert UTC time-zone offset to a string', () {
        expect(TomlTimeZoneOffset.utc().toString(), equals('Z'));
      });
      test('can convert positive time-zone offset to a string', () {
        expect(TomlTimeZoneOffset.positive(1, 0).toString(), equals('+01:00'));
      });
      test('can convert negative time-zone offset to a string', () {
        expect(TomlTimeZoneOffset.negative(1, 0).toString(), equals('-01:00'));
      });
    });
  });
}
