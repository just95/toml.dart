library toml.test.util.date_test;

import 'package:test/test.dart';

import 'package:toml/src/util/date.dart';

void main() {
  group('YearExtension', () {
    group('isLeapYear', () {
      test('identifies non-centurial years divisible by 4 as leap years', () {
        expect(2012.isLeapYear, isTrue);
        expect(2016.isLeapYear, isTrue);
        expect(2020.isLeapYear, isTrue);
      });
      test('does not identify non-centurial years not divisible by 4 as leap '
          'years', () {
        expect(1995.isLeapYear, isFalse);
        expect(1998.isLeapYear, isFalse);
        expect(2021.isLeapYear, isFalse);
      });
      test('identifies centurial years divisible by 400 as leap years', () {
        expect(1600.isLeapYear, isTrue);
        expect(2000.isLeapYear, isTrue);
        expect(2400.isLeapYear, isTrue);
      });
      test('does not identify centurial years not divisible by 400 as leap '
          'years', () {
        expect(1700.isLeapYear, isFalse);
        expect(1800.isLeapYear, isFalse);
        expect(1900.isLeapYear, isFalse);
      });
    });
    group('daysOfMonth', () {
      test('returns 28 for february of non-leap years', () {
        expect(2021.daysOfMonth(DateTime.february), 28);
      });
      test('returns 29 for february of leap years', () {
        expect(2020.daysOfMonth(DateTime.february), 29);
      });
      test('rejects months before January', () {
        expect(() => 1995.daysOfMonth(0), throwsA(isA<ArgumentError>()));
      });
      test('accepts months between 1 and 12', () {
        for (var month = 1; month <= 12; month++) {
          expect(() => 1995.daysOfMonth(month), returnsNormally);
        }
      });
      test('rejects months after December', () {
        expect(() => 1995.daysOfMonth(13), throwsA(isA<ArgumentError>()));
      });
    });
  });
}
