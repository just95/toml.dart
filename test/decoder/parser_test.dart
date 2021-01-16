library toml.test.decoder.parser_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('Parser', () {
    group('TomlValue.parse', () {
      group('Array', () {
        test('can parse empty array', () {
          expect(
            TomlValue.parse('[]'),
            equals(TomlArray([])),
          );
        });
        test('can parse empty array with whitespace', () {
          expect(
            TomlValue.parse('[ ]'),
            equals(TomlArray([])),
          );
        });
        test('can parse array of integers', () {
          expect(
            TomlValue.parse('[1, 2, 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with trailing comma', () {
          expect(
            TomlValue.parse('[1, 2, 3,]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('cannot parse array with comma only', () {
          expect(
            () => TomlValue.parse('[,]'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('can parse array with whitespace after the opening bracket', () {
          expect(
            TomlValue.parse('[ 1, 2, 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with whitespace before the closing bracket', () {
          expect(
            TomlValue.parse('[1, 2, 3 ]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with whitespace before commas', () {
          expect(
            TomlValue.parse('[1 , 2 , 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with newlines after the opening bracket', () {
          expect(
            TomlValue.parse('[\n1, 2, 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with newlines before the closing bracket', () {
          expect(
            TomlValue.parse('[1, 2, 3\n]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with newlines after commas', () {
          expect(
            TomlValue.parse('[1,\n 2,\n 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('can parse array with newlines before commas', () {
          expect(
            TomlValue.parse('[1\n, 2\n, 3]'),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
        test('rejects homogeneous arrays', () {
          expect(
            () => TomlValue.parse('[1, 2.0, 3]'),
            throwsA(isA<FormatException>()),
          );
        });
        test('can parse array with comments', () {
          expect(
            TomlValue.parse(
              '[    # Comment after opening bracket\n'
              '  1, # Comment after comma\n'
              '  2  # Comment before comma\n'
              ', 3  # Comment before closing bracket\n'
              ']',
            ),
            equals(TomlArray([TomlInteger(1), TomlInteger(2), TomlInteger(3)])),
          );
        });
      });
      group('Boolean', () {
        test('can parse true', () {
          expect(
            TomlValue.parse('true'),
            equals(TomlBoolean(true)),
          );
        });
        test('can parse false', () {
          expect(
            TomlValue.parse('false'),
            equals(TomlBoolean(false)),
          );
        });
      });
      group('Date-Time', () {
        test('can parse UTC date-times', () {
          expect(
            TomlValue.parse('1989-11-09T17:53:00Z'),
            equals(TomlDateTime(DateTime.utc(1989, 11, 9, 17, 53))),
          );
        });
        test('can parse date-times with time zone offset', () {
          expect(
            TomlValue.parse('1989-11-09T18:53:00+01:00'),
            equals(TomlDateTime(DateTime.utc(1989, 11, 9, 17, 53))),
          );
        });
        test('can parse date-times with fractions of a second', () {
          expect(
            TomlValue.parse('1989-11-09T18:53:00.999999+01:00'),
            equals(
              TomlDateTime(DateTime.utc(1989, 11, 9, 17, 53, 0, 999, 999)),
            ),
          );
        });
      });
      group('Float', () {
        test('can parse zero without sign', () {
          expect(
            TomlValue.parse('0.0'),
            equals(TomlFloat(0.0)),
          );
        });
        test('can parse zero with plus sign', () {
          expect(
            TomlValue.parse('+0.0'),
            equals(TomlFloat(0.0)),
          );
        });
        test('can parse zero with minus sign', () {
          expect(
            TomlValue.parse('-0.0'),
            equals(TomlFloat(0.0)),
          );
        });
        test('can parse positive float with plus sign', () {
          expect(
            TomlValue.parse('+1.0'),
            equals(TomlFloat(1.0)),
          );
        });
        test('can parse positive float without plus sign', () {
          expect(
            TomlValue.parse('3.1415'),
            equals(TomlFloat(3.1415)),
          );
        });
        test('can parse negative float', () {
          expect(
            TomlValue.parse('-0.01'),
            equals(TomlFloat(-0.01)),
          );
        });
        test('can parse float with zero in exponent', () {
          expect(
            TomlValue.parse('1e0'),
            equals(TomlFloat(1)),
          );
        });
        test('can parse float without fractional part but with exponent', () {
          expect(
            TomlValue.parse('1e6'),
            equals(TomlFloat(1e6)),
          );
        });
        test('can parse float with plus sign in exponent', () {
          expect(
            TomlValue.parse('1e+6'),
            equals(TomlFloat(1e6)),
          );
        });
        test('can parse float with minus sign in exponent', () {
          expect(
            TomlValue.parse('1e-6'),
            equals(TomlFloat(1e-6)),
          );
        });
        test('can parse float with fractional and exponent part', () {
          expect(
            TomlValue.parse('6.626e-34'),
            equals(TomlFloat(6.626e-34)),
          );
        });
        test('allows underscores in integer part', () {
          expect(
            TomlValue.parse('1_2.34e57'),
            equals(TomlFloat(12.34e57)),
          );
        });
        test('allows underscores in fraction part', () {
          expect(
            TomlValue.parse('12.3_4e57'),
            equals(TomlFloat(12.34e57)),
          );
        });
        test('allows underscores in exponent', () {
          expect(
            TomlValue.parse('12.34e5_7'),
            equals(TomlFloat(12.34e57)),
          );
        });
        test('does not allow leading underscores in integer part', () {
          expect(
            () => TomlValue.parse('_12.34e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow leading underscores in fractional part', () {
          expect(
            () => TomlValue.parse('12._34e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow leading underscores in exponent', () {
          expect(
            () => TomlValue.parse('12.34e_57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow trailing underscores in integer part', () {
          expect(
            () => TomlValue.parse('12_.34e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow trailing underscores in fractional part', () {
          expect(
            () => TomlValue.parse('12.34_e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow trailing underscores in exponent', () {
          expect(
            () => TomlValue.parse('12.34e57_'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow consecutive underscores in integer part', () {
          expect(
            () => TomlValue.parse('1__2.34e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow consecutive underscores in fractional part', () {
          expect(
            () => TomlValue.parse('12.3__4e57'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow consecutive underscores in exponent', () {
          expect(
            () => TomlValue.parse('12.34e5__7'),
            throwsA(isA<TomlParserException>()),
          );
        });
      });
      group('Integer', () {
        test('can parse zero without sign', () {
          expect(
            TomlValue.parse('0'),
            equals(TomlInteger(0)),
          );
        });
        test('can parse zero with plus sign', () {
          expect(
            TomlValue.parse('+0'),
            equals(TomlInteger(0)),
          );
        });
        test('can parse zero with minus sign', () {
          expect(
            TomlValue.parse('-0'),
            equals(TomlInteger(0)),
          );
        });
        test('can parse positive number with plus sign', () {
          expect(
            TomlValue.parse('+99'),
            equals(TomlInteger(99)),
          );
        });
        test('can parse positive number without plus sign', () {
          expect(
            TomlValue.parse('42'),
            equals(TomlInteger(42)),
          );
        });
        test('can parse negative number', () {
          expect(
            TomlValue.parse('-17'),
            equals(TomlInteger(-17)),
          );
        });
        test('does not allow leading zeros', () {
          expect(
            () => TomlValue.parse('0777'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('allows underscores to be used as separators', () {
          expect(
            TomlValue.parse('1_000'),
            equals(TomlInteger(1000)),
          );
        });
        test('allows underscores between every number', () {
          expect(
            TomlValue.parse('1_2_3_4_5'),
            equals(TomlInteger(12345)),
          );
        });
        test('does not allow leading underscores', () {
          expect(
            () => TomlValue.parse('_1000'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow trailing underscores', () {
          expect(
            () => TomlValue.parse('1000_'),
            throwsA(isA<TomlParserException>()),
          );
        });
        test('does not allow consecutive underscores', () {
          expect(
            () => TomlValue.parse('1__000'),
            throwsA(isA<TomlParserException>()),
          );
        });
      });
      group('String', () {
        group('Basic', () {
          test('can parse empty basic string', () {
            expect(
              TomlValue.parse('""'),
              equals(TomlBasicString('')),
            );
          });
          test('can parse basic string with escape sequences', () {
            expect(
              TomlValue.parse(
                '"I\'m a string. '
                r'\"You can quote me\". '
                r'Name\tJos\u00E9\nLocation\tSF."',
              ),
              equals(TomlBasicString(
                'I\'m a string. '
                '\"You can quote me\". '
                'Name\tJos\u00E9\nLocation\tSF.',
              )),
            );
          });
          test('does not allow invalid escape sequences', () {
            expect(
              () => TomlValue.parse(r'"some\windows\path"'),
              throwsA(isA<TomlInvalidEscapeSequenceException>()),
            );
          });
        });
        group('Multi-Line Basic', () {
          test('can parse empty multi-line basic strings', () {
            expect(
              TomlValue.parse(
                '""""""',
              ),
              equals(TomlMultilineBasicString('')),
            );
          });
          test('can parse multi-line basic string without newlines', () {
            expect(
              TomlValue.parse(
                '"""Roses are red, Violets are blue"""',
              ),
              equals(TomlMultilineBasicString(
                'Roses are red, Violets are blue',
              )),
            );
          });
          test('can parse multi-line basic string with newlines', () {
            expect(
              TomlValue.parse(
                '"""Roses are red\n'
                'Violets are blue"""',
              ),
              equals(TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue',
              )),
            );
          });
          test('trims first newline after opening delimiter', () {
            expect(
              TomlValue.parse(
                '"""\n'
                'Roses are red\n'
                'Violets are blue"""',
              ),
              equals(TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue',
              )),
            );
          });
          test('does not trim final newline before closing delimiter', () {
            expect(
              TomlValue.parse(
                '"""Roses are red\n'
                'Violets are blue\n'
                '"""',
              ),
              equals(TomlMultilineBasicString(
                'Roses are red\n'
                'Violets are blue\n',
              )),
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
              equals(TomlMultilineBasicString(
                'The quick brown fox jumps over the lazy dog.',
              )),
            );
          });
          test('allows two consecutive double quotes without escaping', () {
            expect(
              TomlValue.parse('"""Foo ""Bar"" Baz"""'),
              equals(TomlMultilineBasicString(
                'Foo ""Bar"" Baz',
              )),
            );
          });
          test('requires the third consecutive double quote to be escaped', () {
            expect(
              () => TomlValue.parse('"""Foo """Bar""" Baz"""'),
              throwsA(isA<TomlParserException>()),
            );
            expect(
              TomlValue.parse(r'"""Foo ""\"Bar""\" Baz"""'),
              equals(TomlMultilineBasicString(
                'Foo """Bar""" Baz',
              )),
            );
          });
        });
        group('Literal', () {
          test('can parse empty literal strings', () {
            expect(
              TomlValue.parse("''"),
              equals(TomlLiteralString('')),
            );
          });
          test('ignores escape sequences in literal strings', () {
            expect(
              TomlValue.parse(r"'C:\Users\nodejs\templates'"),
              equals(TomlLiteralString(r'C:\Users\nodejs\templates')),
            );
          });
        });
        group('Multi-Line Literal', () {
          test('can parse empty multi-line literal strings', () {
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
              equals(TomlMultilineLiteralString(
                'Roses are red\n'
                'Violets are blue',
              )),
            );
          });
          test('does not trim final newline before closing delimiter', () {
            expect(
              TomlValue.parse(
                "'''Roses are red\n"
                'Violets are blue\n'
                "'''",
              ),
              equals(TomlMultilineLiteralString(
                'Roses are red\n'
                'Violets are blue\n',
              )),
            );
          });
        });
      });
    });
  });
}
