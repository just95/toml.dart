import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlValue.parse', () {
    group('Array', () {
      test('can parse empty array', () {
        expect(TomlValue.parse('[]'), equals(TomlArray([])));
      });
      test('can parse empty array with whitespace', () {
        expect(TomlValue.parse('[ ]'), equals(TomlArray([])));
      });
      test('can parse array of integers', () {
        expect(
          TomlValue.parse('[1, 2, 3]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse heterogeneous arrays', () {
        expect(
          TomlValue.parse('[1, true, 3.0]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlBoolean(true),
              TomlFloat(3.0),
            ]),
          ),
        );
      });
      test('can parse array with trailing comma', () {
        expect(
          TomlValue.parse('[1, 2, 3,]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('cannot parse array with comma only', () {
        var input = '[,]';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: '"]" expected',
                source: input,
                offset: 1,
              ),
            ),
          ),
        );
      });
      test('can parse array with whitespace after the opening bracket', () {
        expect(
          TomlValue.parse('[ 1, 2, 3]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with whitespace before the closing bracket', () {
        expect(
          TomlValue.parse('[1, 2, 3 ]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with whitespace before commas', () {
        expect(
          TomlValue.parse('[1 , 2 , 3]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with newlines after the opening bracket', () {
        expect(
          TomlValue.parse('[\n1, 2, 3]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with newlines before the closing bracket', () {
        expect(
          TomlValue.parse('[1, 2, 3\n]'),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with newlines after commas', () {
        expect(
          TomlValue.parse(
            '[1,\n'
            ' 2,\n'
            ' 3]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with newlines before commas', () {
        expect(
          TomlValue.parse(
            '[1\n'
            ', 2\n'
            ', 3]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with indentation before commas', () {
        expect(
          TomlValue.parse(
            '[   1\n'
            '  , 2\n'
            '  , 3\n'
            ']',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with indentation before closing bracket', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3\n'
            '  ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment after opening bracket', () {
        expect(
          TomlValue.parse(
            '[ # Comment\n'
            '  1, 2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment after opening bracket', () {
        expect(
          TomlValue.parse(
            '[ # Line 1\n'
            '  # Line 2\n'
            '  1, 2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment before closing bracket', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3 # Comment\n'
            ']',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment before closing bracket', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3 # Line 1\n'
            '          # Line 2\n'
            ']',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment after comma', () {
        expect(
          TomlValue.parse(
            '[ 1, # Comment\n'
            '  2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment after comma', () {
        expect(
          TomlValue.parse(
            '[ 1, # Line 1\n'
            '     # Line 2\n'
            '  2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment before comma', () {
        expect(
          TomlValue.parse(
            '[ 1 # Comment\n'
            ', 2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment before comma', () {
        expect(
          TomlValue.parse(
            '[ 1 # Line 1\n'
            '    # Line 2\n'
            ', 2, 3 ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment after trailing comma', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3, # Comment\n'
            ']',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment after trailing comma', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3, # Line 1\n'
            '           # Line 2\n'
            ']',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with comment before trailing comma', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3 # Comment\n'
            ', ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('can parse array with multiline comment before trailing comma', () {
        expect(
          TomlValue.parse(
            '[ 1, 2, 3 # Line 1\n'
            '          # Line 2\n'
            ', ]',
          ),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          ),
        );
      });
      test('cannot parse array with missing closing bracket', () {
        var input = '[ 1, 2, 3';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: '"]" expected',
                source: input,
                offset: 9,
              ),
            ),
          ),
        );
      });
      test('cannot parse array with missing value', () {
        var input = '[ 1, , 3 ]';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: '"]" expected',
                source: input,
                offset: 5,
              ),
            ),
          ),
        );
      });
    });
    group('Boolean', () {
      test('can parse true', () {
        expect(TomlValue.parse('true'), equals(TomlBoolean(true)));
      });
      test('can parse false', () {
        expect(TomlValue.parse('false'), equals(TomlBoolean(false)));
      });
    });
    group('Offset Date-Time', () {
      test('can parse UTC date-times', () {
        expect(
          TomlValue.parse('1989-11-09 17:53:00Z'),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test('can parse UTC date-times without seconds', () {
        expect(
          TomlValue.parse('1989-11-09 17:53Z'),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test('allows \'T\' as a separator between date and time', () {
        expect(
          TomlValue.parse('1989-11-09T17:53:00Z'),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test('can parse date-times with numeric time zone offset', () {
        expect(
          TomlValue.parse('1989-11-09 18:53:00+01:00'),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(18, 53, 0),
              TomlTimeZoneOffset.positive(1, 0),
            ),
          ),
        );
      });
      test(
        'can parse date-times with numeric time zone offset without seconds',
        () {
          expect(
            TomlValue.parse('1989-11-09 18:53+01:00'),
            equals(
              TomlOffsetDateTime(
                TomlFullDate(1989, 11, 9),
                TomlPartialTime(18, 53, 0),
                TomlTimeZoneOffset.positive(1, 0),
              ),
            ),
          );
        },
      );
      test('can parse date-times with fractions of a second', () {
        expect(
          TomlValue.parse('1989-11-09 18:53:00.0099999+01:00'),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(18, 53, 0, [009, 999, 900]),
              TomlTimeZoneOffset.positive(1, 0),
            ),
          ),
        );
      });
      test('rejects offset date-times with invalid hours', () {
        expect(
          () => TomlValue.parse('1989-11-09 18:53:00+24:00'),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('rejects offset date-times with invalid minutes', () {
        expect(
          () => TomlValue.parse('1989-11-09 18:53:00+01:60'),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
    });
    group('Local Date-Time', () {
      test('can parse date-times without time-zone offset', () {
        expect(
          TomlValue.parse('1989-11-09 17:53:00'),
          equals(
            TomlLocalDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
            ),
          ),
        );
      });
      test('can parse date-times without seconds and time-zone offset', () {
        expect(
          TomlValue.parse('1989-11-09 17:53'),
          equals(
            TomlLocalDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
            ),
          ),
        );
      });
      test('allows \'T\' as a separator between date and time', () {
        expect(
          TomlValue.parse('1989-11-09T17:53:00'),
          equals(
            TomlLocalDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(17, 53, 0),
            ),
          ),
        );
      });
      test('can parse date-times with fractions of a second', () {
        expect(
          TomlValue.parse('1989-11-09 18:53:00.0099999'),
          equals(
            TomlLocalDateTime(
              TomlFullDate(1989, 11, 9),
              TomlPartialTime(18, 53, 0, [009, 999, 900]),
            ),
          ),
        );
      });
    });
    group('Local Date', () {
      test('can parse dates without time', () {
        expect(
          TomlValue.parse('1989-11-09'),
          equals(TomlLocalDate(TomlFullDate(1989, 11, 9))),
        );
      });
      test('rejects dates with invalid months', () {
        expect(
          () => TomlValue.parse('1989-13-09'),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('rejects dates with invalid day', () {
        expect(
          () => TomlValue.parse('1989-11-31'),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
      test('accepts leap day of leap-year', () {
        expect(
          TomlValue.parse('2020-02-29'),
          equals(TomlLocalDate(TomlFullDate(2020, 2, 29))),
        );
      });
      test('rejects leap day of non-leap-year', () {
        expect(
          () => TomlValue.parse('2021-02-29'),
          throwsA(isA<TomlInvalidDateTimeException>()),
        );
      });
    });
    group('Local Time', () {
      test('can parse time without date', () {
        expect(
          TomlValue.parse('17:53:00'),
          equals(TomlLocalTime(TomlPartialTime(17, 53, 0))),
        );
      });
      test('can parse time without seconds and date', () {
        expect(
          TomlValue.parse('17:53'),
          equals(TomlLocalTime(TomlPartialTime(17, 53, 0))),
        );
      });
      test('can parse time with fractions of a second', () {
        expect(
          TomlValue.parse('18:53:00.0099999'),
          equals(TomlLocalTime(TomlPartialTime(18, 53, 0, [009, 999, 900]))),
        );
      });
    });
    group('Float', () {
      test('can parse zero without sign', () {
        expect(TomlValue.parse('0.0'), equals(TomlFloat(0.0)));
      });
      test('can parse zero with plus sign', () {
        var node = TomlValue.parse('+0.0');
        expect(node, isA<TomlFloat>());
        if (node is TomlFloat) {
          expect(node.value, isZero);
          expect(node.value.isNegative, equals(false));
        }
      });
      test('can parse zero with minus sign', () {
        var node = TomlValue.parse('-0.0');
        expect(node, isA<TomlFloat>());
        if (node is TomlFloat) {
          expect(node.value, isZero);
          expect(node.value.isNegative, equals(true));
        }
      });
      test('can parse positive float with plus sign', () {
        expect(TomlValue.parse('+1.0'), equals(TomlFloat(1.0)));
      });
      test('can parse positive float without plus sign', () {
        expect(TomlValue.parse('3.1415'), equals(TomlFloat(3.1415)));
      });
      test('can parse negative float', () {
        expect(TomlValue.parse('-0.01'), equals(TomlFloat(-0.01)));
      });
      test('can parse float with zero in exponent', () {
        expect(TomlValue.parse('1e0'), equals(TomlFloat(1)));
      });
      test('can parse float without fractional part but with exponent', () {
        expect(TomlValue.parse('1e6'), equals(TomlFloat(1e6)));
      });
      test('can parse float with plus sign in exponent', () {
        expect(TomlValue.parse('1e+6'), equals(TomlFloat(1e6)));
      });
      test('can parse float with minus sign in exponent', () {
        expect(TomlValue.parse('1e-6'), equals(TomlFloat(1e-6)));
      });
      test('can parse float with fractional and exponent part', () {
        expect(TomlValue.parse('6.626e-34'), equals(TomlFloat(6.626e-34)));
      });
      test('rejects float with decimal dot but integer part', () {
        var input = '.1415';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'value expected',
                source: input,
                offset: 0,
              ),
            ),
          ),
        );
      });
      test('rejects float with decimal dot but no fractional digits', () {
        var input = '3.';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 1,
              ),
            ),
          ),
        );
      });
      test('rejects float with decimal dot and exponent part but no '
          'fractional digits', () {
        var input = '3.e+20';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 1,
              ),
            ),
          ),
        );
      });
      test('requires the fractional part to precede the exponent part', () {
        var input = '6e-34.626';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 5,
              ),
            ),
          ),
        );
      });
      test('allows underscores in integer part', () {
        expect(TomlValue.parse('1_2.34e57'), equals(TomlFloat(12.34e57)));
      });
      test('allows underscores in fraction part', () {
        expect(TomlValue.parse('12.3_4e57'), equals(TomlFloat(12.34e57)));
      });
      test('allows underscores in exponent', () {
        expect(TomlValue.parse('12.34e5_7'), equals(TomlFloat(12.34e57)));
      });
      test('does not allow leading underscores in integer part', () {
        var input = '_12.34e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'value expected',
                source: input,
                offset: 0,
              ),
            ),
          ),
        );
      });
      test('does not allow leading underscores in fractional part', () {
        var input = '12._34e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 2,
              ),
            ),
          ),
        );
      });
      test('does not allow leading underscores in exponent', () {
        var input = '12.34e_57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 5,
              ),
            ),
          ),
        );
      });
      test('does not allow trailing underscores in integer part', () {
        var input = '12_.34e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 2,
              ),
            ),
          ),
        );
      });
      test('does not allow trailing underscores in fractional part', () {
        var input = '12.34_e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 5,
              ),
            ),
          ),
        );
      });
      test('does not allow trailing underscores in exponent', () {
        var input = '12.34e57_';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 8,
              ),
            ),
          ),
        );
      });
      test('does not allow consecutive underscores in integer part', () {
        var input = '1__2.34e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 1,
              ),
            ),
          ),
        );
      });
      test('does not allow consecutive underscores in fractional part', () {
        var input = '12.3__4e57';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 4,
              ),
            ),
          ),
        );
      });
      test('does not allow consecutive underscores in exponent', () {
        var input = '12.34e5__7';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: 'end of input expected',
                source: input,
                offset: 7,
              ),
            ),
          ),
        );
      });
      test('allows leading zeros in exponent part', () {
        expect(TomlValue.parse('12.34e+009'), equals(TomlFloat(12.34e9)));
      });
      test('can parse positive infinity without plus sign', () {
        expect(TomlValue.parse('inf'), equals(TomlFloat(double.infinity)));
      });
      test('can parse positive infinity with plus sign', () {
        expect(TomlValue.parse('+inf'), equals(TomlFloat(double.infinity)));
      });
      test('can parse negative infinity', () {
        expect(
          TomlValue.parse('-inf'),
          equals(TomlFloat(double.negativeInfinity)),
        );
      });
      test('can parse NaN without sign', () {
        expect(TomlValue.parse('nan'), equals(TomlFloat(double.nan)));
      });
      test('can parse NaN with plus sign', () {
        expect(TomlValue.parse('+nan'), equals(TomlFloat(double.nan)));
      });
      test('can parse NaN with minus sign', () {
        expect(TomlValue.parse('-nan'), equals(TomlFloat(double.nan)));
      });
    });
    group('Integer', () {
      group('Binary', () {
        test('can parse binary integers', () {
          expect(
            TomlValue.parse('0b101010'),
            equals(TomlInteger.bin(BigInt.from(42))),
          );
        });
        test('can parse binary integers with leading zeros', () {
          expect(
            TomlValue.parse('0b00101010'),
            equals(TomlInteger.bin(BigInt.from(42))),
          );
        });
        test('can parse binary integers with underscores', () {
          expect(
            TomlValue.parse('0b10_10_10'),
            equals(TomlInteger.bin(BigInt.from(42))),
          );
        });
        test('cannot parse binary integer with leading underscores', () {
          var input = '0b_101010';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse binary integer with trailing underscores', () {
          var input = '0b101010_';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 8,
                ),
              ),
            ),
          );
        });
        test('cannot parse binary integer with consecutive underscores', () {
          var input = '0b10__1010';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 4,
                ),
              ),
            ),
          );
        });
        test('cannot parse binary integer without digits', () {
          var input = '0b';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse binary integer with non-binary digits', () {
          var input = '0b123';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 3,
                ),
              ),
            ),
          );
        });
      });
      group('Octal', () {
        test('can parse octal integers', () {
          expect(
            TomlValue.parse('0o755'),
            equals(TomlInteger.oct(BigInt.from(493))),
          );
        });
        test('can parse octal integers with leading zeros', () {
          expect(
            TomlValue.parse('0o0755'),
            equals(TomlInteger.oct(BigInt.from(493))),
          );
        });
        test('can parse octal integers with underscores', () {
          expect(
            TomlValue.parse('0o7_5_5'),
            equals(TomlInteger.oct(BigInt.from(493))),
          );
        });
        test('cannot parse octal integer with leading underscores', () {
          var input = '0o_755';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with trailing underscores', () {
          var input = '0o755_';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 5,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with consecutive underscores', () {
          var input = '0o7__55';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 3,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer without digits', () {
          var input = '0o';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with non-octal digits', () {
          var input = '0o888';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
      });
      group('Decimal', () {
        test('can parse zero without sign', () {
          expect(TomlValue.parse('0'), equals(TomlInteger.dec(BigInt.from(0))));
        });
        test('can parse zero with plus sign', () {
          expect(
            TomlValue.parse('+0'),
            equals(TomlInteger.dec(BigInt.from(0))),
          );
        });
        test('can parse zero with minus sign', () {
          expect(
            TomlValue.parse('-0'),
            equals(TomlInteger.dec(BigInt.from(0))),
          );
        });
        test('can parse positive number with plus sign', () {
          expect(
            TomlValue.parse('+99'),
            equals(TomlInteger.dec(BigInt.from(99))),
          );
        });
        test('can parse positive number without plus sign', () {
          expect(
            TomlValue.parse('42'),
            equals(TomlInteger.dec(BigInt.from(42))),
          );
        });
        test('can parse negative number', () {
          expect(
            TomlValue.parse('-17'),
            equals(TomlInteger.dec(BigInt.from(-17))),
          );
        });
        test('does not allow leading zeros', () {
          var input = '0777';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('allows underscores to be used as separators', () {
          expect(
            TomlValue.parse('1_000'),
            equals(TomlInteger.dec(BigInt.from(1000))),
          );
        });
        test('allows underscores between every number', () {
          expect(
            TomlValue.parse('1_2_3_4_5'),
            equals(TomlInteger.dec(BigInt.from(12345))),
          );
        });
        test('does not allow leading underscores', () {
          var input = '_1000';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'value expected',
                  source: input,
                  offset: 0,
                ),
              ),
            ),
          );
        });
        test('does not allow trailing underscores', () {
          var input = '1000_';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 4,
                ),
              ),
            ),
          );
        });
        test('does not allow consecutive underscores', () {
          var input = '1__000';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
      });
      group('Hexadecimal', () {
        test('can parse lower case hexadecimal integers', () {
          expect(
            TomlValue.parse('0xbadc0ded'),
            equals(TomlInteger.hex(BigInt.from(0xbadc0ded))),
          );
        });
        test('can parse upper case hexadecimal integers', () {
          expect(
            TomlValue.parse('0xBADC0DED'),
            equals(TomlInteger.hex(BigInt.from(0xbadc0ded))),
          );
        });
        test('can parse mixed case hexadecimal integers', () {
          expect(
            TomlValue.parse('0xBadC0ded'),
            equals(TomlInteger.hex(BigInt.from(0xbadc0ded))),
          );
        });
        test('can parse hexadecimal integers with leading zeros', () {
          expect(
            TomlValue.parse('0x0000c0de'),
            equals(TomlInteger.hex(BigInt.from(0xc0de))),
          );
        });
        test('can parse octal integers with underscores', () {
          expect(
            TomlValue.parse('0xbad_c0ded'),
            equals(TomlInteger.hex(BigInt.from(0xbadc0ded))),
          );
        });
        test('cannot parse octal integer with leading underscores', () {
          var input = '0x_badc0ded';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with trailing underscores', () {
          var input = '0xbadc0ded_';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 10,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with consecutive underscores', () {
          var input = '0xbad__c0ded';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 5,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer without digits', () {
          var input = '0x';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('cannot parse octal integer with non-octal digits', () {
          var input = '0xZZZ';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
      });
    });
    group('Inline Table', () {
      test('can parse empty inline table', () {
        expect(TomlValue.parse('{}'), equals(TomlInlineTable([])));
      });
      test('can parse empty inline table with whitespace', () {
        expect(TomlValue.parse('{ }'), equals(TomlInlineTable([])));
      });
      test('can parse inline table with single key/value pair', () {
        expect(
          TomlValue.parse('{ key = "value" }'),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('key')]),
                TomlBasicString('value'),
              ),
            ]),
          ),
        );
      });
      test('can parse inline table with multiple key/value pairs', () {
        expect(
          TomlValue.parse('{ x = 1, y = 2, z = 3 }'),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows trailing comma in inline table', () {
        var input = '{ x = 1, y = 2, z = 3, }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('does not allow inline table with comma only', () {
        var input = '{,}';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: '"}" expected',
                source: input,
                offset: 1,
              ),
            ),
          ),
        );
      });
      test('allows multiline values in inline table', () {
        expect(
          TomlValue.parse(
            '{ key = """\n'
            '""" }',
          ),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('key')]),
                TomlMultilineBasicString(''),
              ),
            ]),
          ),
        );
      });
      test('allows newline after opening brace of inline table', () {
        var input =
            '{\n'
            '  x = 1, y = 2, z = 3 }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows newline before closing brace of inline table', () {
        var input =
            '{ x = 1, y = 2, z = 3 \n'
            '}';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows newline before commas in inline table', () {
        var input =
            '{ x = 1\n'
            ', y = 2\n'
            ', z = 3 }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows newline before trailing comma in inline table', () {
        var input =
            '{ x = 1, y = 2, z = 3\n'
            ', }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows newline after commas in inline table', () {
        var input =
            '{ x = 1, y = 2, z = 3,\n'
            ' }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('allows newline after trailing comma in inline table', () {
        var input =
            '{ x = 1,\n'
            '  y = 2,\n'
            '  z = 3 }';
        expect(
          TomlValue.parse(input),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('x')]),
                TomlInteger.dec(BigInt.from(1)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('y')]),
                TomlInteger.dec(BigInt.from(2)),
              ),
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('z')]),
                TomlInteger.dec(BigInt.from(3)),
              ),
            ]),
          ),
        );
      });
      test('cannot parse inline table with missing closing brace', () {
        var input = '{ x = 1, y = 2, z = 3';
        expect(
          () => TomlValue.parse(input),
          throwsA(
            equals(
              TomlParserException(
                message: '"}" expected',
                source: input,
                offset: 21,
              ),
            ),
          ),
        );
      });
    });
    group('String', () {
      group('Basic', () {
        test('can parse empty basic string', () {
          expect(TomlValue.parse('""'), equals(TomlBasicString('')));
        });
        test('can parse basic string with escape sequences', () {
          expect(
            TomlValue.parse(
              '"I\'m a string. '
              r'\"You can quote me\". '
              r'Name\tJos\u00E9\nLocation\tSF."',
            ),
            equals(
              TomlBasicString(
                "I'm a string. "
                '"You can quote me". '
                'Name\tJos\u00E9\nLocation\tSF.',
              ),
            ),
          );
        });
        test('can parse basic string with long Unicode escape sequences', () {
          expect(
            TomlValue.parse(r'"\U0001f9a6"'),
            equals(TomlBasicString('\u{1f9a6}')),
          );
        });
        test('can parse basic string with escaped backslash', () {
          expect(
            TomlValue.parse(r'"some\\windows\\path"'),
            equals(TomlBasicString(r'some\windows\path')),
          );
        });
        test('does not allow invalid escape sequences', () {
          expect(
            () => TomlValue.parse(r'"some\windows\path"'),
            throwsA(isA<TomlInvalidEscapeSequenceException>()),
          );
        });
        test('does not allow newlines', () {
          var input =
              '"Line 1\n'
              'Line 2"';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('does not allow windows newlines', () {
          var input =
              '"Line 1\r\n'
              'Line 2"';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('does not allow standalone carriage returns', () {
          var input =
              '"Line 1\r'
              'Line 2"';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('allows raw tabs', () {
          expect(
            TomlValue.parse('"Column 1\tColumn 2"'),
            equals(TomlBasicString('Column 1\tColumn 2')),
          );
        });
        test('does not allow control characters', () {
          var input = '"\u0000"';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 1,
                ),
              ),
            ),
          );
        });
        test('does not allow unpaired UTF-16 surrogate code points', () {
          var input = '"High surrogate \uD83E without low surrogate"';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 16,
                ),
              ),
            ),
          );
        });
        test('allows UTF-16 surrogate pairs', () {
          expect(
            TomlValue.parse('"High and low surrogate \uD83E\uDDA6 as a pair"'),
            equals(
              TomlBasicString('High and low surrogate \uD83E\uDDA6 as a pair'),
            ),
          );
        });
        test(
          'does not allow escape sequences for unpaired UTF-16 surrogate code '
          'points',
          () {
            expect(
              () => TomlValue.parse(r'"\uD83E"'),
              throwsA(equals(TomlInvalidEscapeSequenceException(r'\uD83E'))),
            );
          },
        );
        test(
          'does not allow escape sequences for non-scalar Unicode values',
          () {
            expect(
              () => TomlValue.parse(r'"\U00110000"'),
              throwsA(
                equals(TomlInvalidEscapeSequenceException(r'\U00110000')),
              ),
            );
          },
        );
        test('cannot parse basic string without closing delimiter', () {
          var input = '"Hello, World!';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"' expected",
                  source: input,
                  offset: 14,
                ),
              ),
            ),
          );
        });
      });
      group('Multiline Basic', () {
        test('can parse empty multiline basic strings', () {
          expect(
            TomlValue.parse('""""""'),
            equals(TomlMultilineBasicString('')),
          );
        });
        test('can parse multiline basic string without newlines', () {
          expect(
            TomlValue.parse('"""Roses are red, Violets are blue"""'),
            equals(TomlMultilineBasicString('Roses are red, Violets are blue')),
          );
        });
        test('can parse multiline basic string with newlines', () {
          expect(
            TomlValue.parse(
              '"""Roses are red\n'
              'Violets are blue"""',
            ),
            equals(
              TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue',
              ),
            ),
          );
        });
        test('allows Windows newlines', () {
          expect(
            TomlValue.parse(
              '"""Roses are red\r\n'
              'Violets are blue"""',
            ),
            equals(
              TomlMultilineBasicString(
                'Roses are red\r\n'
                'Violets are blue',
              ),
            ),
          );
        });
        test('does not allow standalone carriage returns', () {
          var input =
              '"""Roses are red\r'
              'Violets are blue"""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"\"\"' expected",
                  source: input,
                  offset: 16,
                ),
              ),
            ),
          );
        });
        test('trims first newline after opening delimiter', () {
          expect(
            TomlValue.parse(
              '"""\n'
              'Roses are red\n'
              'Violets are blue"""',
            ),
            equals(
              TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue',
              ),
            ),
          );
        });
        test('does not trim final newline before closing delimiter', () {
          expect(
            TomlValue.parse(
              '"""Roses are red\n'
              'Violets are blue\n'
              '"""',
            ),
            equals(
              TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue\n',
              ),
            ),
          );
        });
        test('allows trailing newlines and whitespace to be escaped', () {
          expect(
            TomlValue.parse(
              '"""\\\n'
              '  The quick brown \\\n'
              '\tfox jumps over \\  \n'
              '\t\tthe lazy dog.\\    \n'
              '"""',
            ),
            equals(
              TomlMultilineBasicString(
                'The quick brown fox jumps over the lazy dog.',
              ),
            ),
          );
        });
        test('requires line-ending backslashes to be unescaped', () {
          expect(
            TomlValue.parse(
              '"""Roses are red \\\\\n'
              'Violets are blue\n'
              '"""',
            ),
            equals(
              TomlMultilineBasicString(
                'Roses are red \\\n'
                'Violets are blue\n',
              ),
            ),
          );
        });
        test('allows two consecutive double quotes without escaping', () {
          expect(
            TomlValue.parse('"""Foo ""Bar"" Baz"""'),
            equals(TomlMultilineBasicString('Foo ""Bar"" Baz')),
          );
        });
        test('requires the third consecutive double quote to be escaped', () {
          var input = '"""Foo """Bar""" Baz"""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 10,
                ),
              ),
            ),
          );
          expect(
            TomlValue.parse(r'"""Foo ""\"Bar""\" Baz"""'),
            equals(TomlMultilineBasicString('Foo """Bar""" Baz')),
          );
        });
        test('allows double quote after opening delimiter', () {
          expect(
            TomlValue.parse('""""Foo"""'),
            equals(TomlMultilineBasicString('"Foo')),
          );
        });
        test('allows two double quotes after opening delimiter', () {
          expect(
            TomlValue.parse('"""""Foo"""'),
            equals(TomlMultilineBasicString('""Foo')),
          );
        });
        test('requires the third double quote after opening delimiter to be '
            'escaped', () {
          var input = '""""""Foo"""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 6,
                ),
              ),
            ),
          );
          expect(
            TomlValue.parse(r'"""""\"Foo"""'),
            equals(TomlMultilineBasicString('"""Foo')),
          );
        });
        test('allows double quote before closing delimiter', () {
          expect(
            TomlValue.parse('"""Foo""""'),
            equals(TomlMultilineBasicString('Foo"')),
          );
        });
        test('allows two double quotes before closing delimiter', () {
          expect(
            TomlValue.parse('"""Foo"""""'),
            equals(TomlMultilineBasicString('Foo""')),
          );
        });
        test('requires the third double quote before closing delimiter to be '
            'escaped', () {
          var input = '"""Foo""""""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 9,
                ),
              ),
            ),
          );
          expect(
            TomlValue.parse(r'"""Foo""\""""'),
            equals(TomlMultilineBasicString('Foo"""')),
          );
        });
        test(
          'rejects more than three double quotes before closing delimiter',
          () {
            for (var i = 4; i < 9; i++) {
              var input = '"""Foo${'"' * i}"""';
              expect(
                () => TomlValue.parse(input),
                throwsA(
                  equals(
                    TomlParserException(
                      message: 'end of input expected',
                      source: input,
                      offset: 9,
                    ),
                  ),
                ),
              );
            }
          },
        );
        test('allows raw tabs', () {
          expect(
            TomlValue.parse('"""Roses are red\tViolets are blue"""'),
            equals(TomlMultilineBasicString('Roses are red\tViolets are blue')),
          );
        });
        test('does not allow control characters', () {
          var input = '"""\u0000"""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"\"\"' expected",
                  source: input,
                  offset: 3,
                ),
              ),
            ),
          );
        });
        test('does not allow unpaired UTF-16 surrogate code points', () {
          var input = '"""High surrogate \uD83E without low surrogate"""';
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: "closing '\"\"\"' expected",
                  source: input,
                  offset: 18,
                ),
              ),
            ),
          );
        });
        test('allows UTF-16 surrogate pairs', () {
          expect(
            TomlValue.parse(
              '"""High and low surrogate \uD83E\uDDA6 as a pair"""',
            ),
            equals(
              TomlMultilineBasicString(
                'High and low surrogate \uD83E\uDDA6 as a pair',
              ),
            ),
          );
        });
        test(
          'cannot parse multiline basic string without closing delimiter',
          () {
            var input = '"""Hello, World!';
            expect(
              () => TomlValue.parse(input),
              throwsA(
                equals(
                  TomlParserException(
                    message: "closing '\"\"\"' expected",
                    source: input,
                    offset: 16,
                  ),
                ),
              ),
            );
          },
        );
      });
      group('Literal', () {
        test('can parse empty literal strings', () {
          expect(TomlValue.parse("''"), equals(TomlLiteralString('')));
        });
        test('ignores escape sequences in literal strings', () {
          expect(
            TomlValue.parse(r"'C:\Users\nodejs\templates'"),
            equals(TomlLiteralString(r'C:\Users\nodejs\templates')),
          );
        });
        test('allows raw tabs', () {
          expect(
            TomlValue.parse("'Roses are red\tViolets are blue'"),
            equals(TomlLiteralString('Roses are red\tViolets are blue')),
          );
        });
        test('does not allow newlines', () {
          var input =
              "'Line 1\n"
              "Line 2'";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'" expected',
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('does not allow windows newlines', () {
          var input =
              "'Line 1\r\n"
              "Line 2'";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'" expected',
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('does not allow standalone carriage returns', () {
          var input =
              "'Line 1\r"
              "Line 2'";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'" expected',
                  source: input,
                  offset: 7,
                ),
              ),
            ),
          );
        });
        test('does not allow unpaired UTF-16 surrogate code points', () {
          var input = "'High surrogate \uD83E without low surrogate'";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'" expected',
                  source: input,
                  offset: 16,
                ),
              ),
            ),
          );
        });
        test('allows UTF-16 surrogate pairs', () {
          expect(
            TomlValue.parse("'High and low surrogate \uD83E\uDDA6 as a pair'"),
            equals(
              TomlLiteralString(
                'High and low surrogate \uD83E\uDDA6 as a pair',
              ),
            ),
          );
        });
        test('cannot parse literal string without closing delimiter', () {
          var input = "'Hello, World!";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'" expected',
                  source: input,
                  offset: 14,
                ),
              ),
            ),
          );
        });
      });
      group('Multiline Literal', () {
        test('can parse empty multiline literal strings', () {
          expect(
            TomlValue.parse("''''''"),
            equals(TomlMultilineLiteralString('')),
          );
        });
        test('trims first newline after opening delimiter', () {
          expect(
            TomlValue.parse(
              "'''\n"
              'Roses are red\n'
              'Violets are blue'
              "'''",
            ),
            equals(
              TomlMultilineLiteralString(
                'Roses are red\n'
                'Violets are blue',
              ),
            ),
          );
        });
        test('does not trim final newline before closing delimiter', () {
          expect(
            TomlValue.parse(
              "'''Roses are red\n"
              'Violets are blue\n'
              "'''",
            ),
            equals(
              TomlMultilineLiteralString(
                'Roses are red\n'
                'Violets are blue\n',
              ),
            ),
          );
        });
        test('allows two consecutive single quotes', () {
          expect(
            TomlValue.parse("'''Foo ''Bar'' Baz'''"),
            equals(TomlMultilineLiteralString("Foo ''Bar'' Baz")),
          );
        });
        test('rejects three consecutive single quotes', () {
          var input = "'''Foo '''Bar''' Baz'''";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 10,
                ),
              ),
            ),
          );
        });
        test('allows single quote after opening delimiter', () {
          expect(
            TomlValue.parse("''''Foo'''"),
            equals(TomlMultilineLiteralString("'Foo")),
          );
        });
        test('allows two single quotes after opening delimiter', () {
          expect(
            TomlValue.parse("'''''Foo'''"),
            equals(TomlMultilineLiteralString("''Foo")),
          );
        });
        test('rejects three single quotes after opening delimiter', () {
          var input = "''''''Foo'''";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 6,
                ),
              ),
            ),
          );
        });
        test('allows single quote before closing delimiter', () {
          expect(
            TomlValue.parse("'''Foo''''"),
            equals(TomlMultilineLiteralString("Foo'")),
          );
        });
        test('allows two single quotes before closing delimiter', () {
          expect(
            TomlValue.parse("'''Foo'''''"),
            equals(TomlMultilineLiteralString("Foo''")),
          );
        });
        test('rejects three single quotes before closing delimiter', () {
          var input = "'''Foo''''''";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'end of input expected',
                  source: input,
                  offset: 9,
                ),
              ),
            ),
          );
        });
        test(
          'rejects more than three single quotes before closing delimiter',
          () {
            for (var i = 4; i < 9; i++) {
              var input = "'''Foo${"'" * i}'''";
              expect(
                () => TomlValue.parse(input),
                throwsA(
                  equals(
                    TomlParserException(
                      message: 'end of input expected',
                      source: input,
                      offset: 9,
                    ),
                  ),
                ),
              );
            }
          },
        );
        test('allows raw tabs', () {
          expect(
            TomlValue.parse("'''Roses are red\tViolets are blue'''"),
            equals(
              TomlMultilineLiteralString('Roses are red\tViolets are blue'),
            ),
          );
        });
        test('allows Windows newlines', () {
          expect(
            TomlValue.parse(
              "'''Roses are red\r\n"
              "Violets are blue'''",
            ),
            equals(
              TomlMultilineLiteralString(
                'Roses are red\r\n'
                'Violets are blue',
              ),
            ),
          );
        });
        test('does not allow standalone carriage returns', () {
          var input =
              "'''Roses are red\r"
              "Violets are blue'''";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'\'\'" expected',
                  source: input,
                  offset: 16,
                ),
              ),
            ),
          );
        });
        test('does not allow unpaired UTF-16 surrogate code points', () {
          var input = "'''High surrogate \uD83E without low surrogate'''";
          expect(
            () => TomlValue.parse(input),
            throwsA(
              equals(
                TomlParserException(
                  message: 'closing "\'\'\'" expected',
                  source: input,
                  offset: 18,
                ),
              ),
            ),
          );
        });
        test('allows UTF-16 surrogate pairs', () {
          expect(
            TomlValue.parse(
              "'''High and low surrogate \uD83E\uDDA6 as a pair'''",
            ),
            equals(
              TomlMultilineLiteralString(
                'High and low surrogate \uD83E\uDDA6 as a pair',
              ),
            ),
          );
        });
        test(
          'cannot parse multiline literal string without closing delimiter',
          () {
            var input = "'''Hello, World!";
            expect(
              () => TomlValue.parse(input),
              throwsA(
                equals(
                  TomlParserException(
                    message: 'closing "\'\'\'" expected',
                    source: input,
                    offset: 16,
                  ),
                ),
              ),
            );
          },
        );
      });
    });
  });
}
