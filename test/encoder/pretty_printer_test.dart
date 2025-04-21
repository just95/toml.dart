library toml.test.encoder.pretty_printer_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlPrettyPrinter', () {
    group('visitValue', () {
      group('visitArray', () {
        test('pretty prints empty array correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArray(TomlArray([]));
          expect(prettyPrinter.toString(), equals('[]'));
        });
        test('pretty prints singleton array correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArray(
            TomlArray([TomlInteger.dec(BigInt.from(1))]),
          );
          expect(prettyPrinter.toString(), equals('[1]'));
        });
        test('pretty prints array with multiple items correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArray(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlInteger.dec(BigInt.from(2)),
              TomlInteger.dec(BigInt.from(3)),
            ]),
          );
          expect(prettyPrinter.toString(), equals('[1, 2, 3]'));
        });
      });
      group('visitBoolean', () {
        test('pretty prints `true` correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitBoolean(TomlBoolean(true));
          expect(prettyPrinter.toString(), equals('true'));
        });
        test('pretty prints `false` correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitBoolean(TomlBoolean(false));
          expect(prettyPrinter.toString(), equals('false'));
        });
      });
      group('visitDateTime', () {
        group('visitOffsetDateTime', () {
          test('pretty prints UTC date-time correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitOffsetDateTime(
              TomlOffsetDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0),
                TomlTimeZoneOffset.utc(),
              ),
            );
            expect(prettyPrinter.toString(), equals('1969-07-20 20:17:00Z'));
          });
          test('pretty prints non-UTC date-time correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitOffsetDateTime(
              TomlOffsetDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0),
                TomlTimeZoneOffset.positive(1, 0),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00+01:00'),
            );
          });
          test('pretty prints UTC date-time with milliseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitOffsetDateTime(
              TomlOffsetDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [123]),
                TomlTimeZoneOffset.utc(),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00.123Z'),
            );
          });
          test('pretty prints UTC date-time with milli- and microseconds '
              'correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitOffsetDateTime(
              TomlOffsetDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [123, 456]),
                TomlTimeZoneOffset.utc(),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00.123456Z'),
            );
          });
          test('pretty prints UTC date-time with microseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitOffsetDateTime(
              TomlOffsetDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [0, 456]),
                TomlTimeZoneOffset.utc(),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00.000456Z'),
            );
          });
        });
        group('visitLocalDateTime', () {
          test('pretty prints local date-time correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalDateTime(
              TomlLocalDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0),
              ),
            );
            expect(prettyPrinter.toString(), equals('1969-07-20 20:17:00'));
          });
          test('pretty prints local date-time with milliseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalDateTime(
              TomlLocalDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [123]),
              ),
            );
            expect(prettyPrinter.toString(), equals('1969-07-20 20:17:00.123'));
          });
          test('pretty prints local date-time with milli- and microseconds '
              'correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalDateTime(
              TomlLocalDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [123, 456]),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00.123456'),
            );
          });
          test('pretty prints local date-time with microseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalDateTime(
              TomlLocalDateTime(
                TomlFullDate(1969, 7, 20),
                TomlPartialTime(20, 17, 0, [0, 456]),
              ),
            );
            expect(
              prettyPrinter.toString(),
              equals('1969-07-20 20:17:00.000456'),
            );
          });
        });
        group('visitLocalDate', () {
          test('pretty prints date correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalDate(
              TomlLocalDate(TomlFullDate(1969, 7, 20)),
            );
            expect(prettyPrinter.toString(), equals('1969-07-20'));
          });
        });
        group('visitLocalTime', () {
          test('pretty prints time correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalTime(
              TomlLocalTime(TomlPartialTime(20, 17, 0)),
            );
            expect(prettyPrinter.toString(), equals('20:17:00'));
          });
          test('pretty prints time with milliseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalTime(
              TomlLocalTime(TomlPartialTime(20, 17, 0, [123])),
            );
            expect(prettyPrinter.toString(), equals('20:17:00.123'));
          });
          test('pretty prints time with milli- and microseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalTime(
              TomlLocalTime(TomlPartialTime(20, 17, 0, [123, 456])),
            );
            expect(prettyPrinter.toString(), equals('20:17:00.123456'));
          });
          test('pretty prints time with microseconds correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLocalTime(
              TomlLocalTime(TomlPartialTime(20, 17, 0, [0, 456])),
            );
            expect(prettyPrinter.toString(), equals('20:17:00.000456'));
          });
        });
      });
      group('visitFloat', () {
        test('pretty prints float without decimal places correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(1.0));
          expect(prettyPrinter.toString(), equals('1.0'));
        });
        test('pretty prints float with decimal places correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(13.37));
          expect(prettyPrinter.toString(), equals('13.37'));
        });
        test('pretty prints negative float correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(-273.15));
          expect(prettyPrinter.toString(), equals('-273.15'));
        });
        test('pretty prints positive infinity correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(double.infinity));
          expect(prettyPrinter.toString(), equals('inf'));
        });
        test('pretty prints negative infinity correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(double.negativeInfinity));
          expect(prettyPrinter.toString(), equals('-inf'));
        });
        test('pretty prints NaN correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitFloat(TomlFloat(double.nan));
          expect(prettyPrinter.toString(), equals('nan'));
        });
      });
      group('visitInlineTable', () {
        test('pretty prints empty inline table correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInlineTable(TomlInlineTable([]));
          expect(prettyPrinter.toString(), equals('{}'));
        });
        test(
          'pretty prints inline table with one key/value pair correctly',
          () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitInlineTable(
              TomlInlineTable([
                TomlKeyValuePair(
                  TomlKey([TomlUnquotedKey('foo')]),
                  TomlInteger.dec(BigInt.from(0)),
                ),
              ]),
            );
            expect(prettyPrinter.toString(), equals('{ foo = 0 }'));
          },
        );
        test(
          'pretty prints inline table with multiple key/value pairs correctly',
          () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitInlineTable(
              TomlInlineTable([
                TomlKeyValuePair(
                  TomlKey([TomlUnquotedKey('foo')]),
                  TomlInteger.dec(BigInt.from(0)),
                ),
                TomlKeyValuePair(
                  TomlKey([TomlUnquotedKey('bar')]),
                  TomlInteger.dec(BigInt.from(1)),
                ),
                TomlKeyValuePair(
                  TomlKey([TomlUnquotedKey('baz')]),
                  TomlInteger.dec(BigInt.from(2)),
                ),
              ]),
            );
            expect(
              prettyPrinter.toString(),
              equals('{ foo = 0, bar = 1, baz = 2 }'),
            );
          },
        );
      });
      group('visitInteger', () {
        test('pretty prints zero correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.dec(BigInt.from(0)));
          expect(prettyPrinter.toString(), equals('0'));
        });
        test('pretty prints positive integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.dec(BigInt.from(42)));
          expect(prettyPrinter.toString(), equals('42'));
        });
        test('pretty prints negative integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.dec(BigInt.from(-273)));
          expect(prettyPrinter.toString(), equals('-273'));
        });
        test('pretty prints binary zero correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.bin(BigInt.from(0)));
          expect(prettyPrinter.toString(), equals('0b0'));
        });
        test('pretty prints octal zero correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.oct(BigInt.from(0)));
          expect(prettyPrinter.toString(), equals('0o0'));
        });
        test('pretty prints hexadecimal zero correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.hex(BigInt.from(0)));
          expect(prettyPrinter.toString(), equals('0x0'));
        });
        test('pretty prints binary integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.bin(BigInt.from(42)));
          expect(prettyPrinter.toString(), equals('0b101010'));
        });
        test('pretty prints octal integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.oct(BigInt.from(493)));
          expect(prettyPrinter.toString(), equals('0o755'));
        });
        test('pretty prints hexadecimal integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger.hex(BigInt.from(0xbadc0ded)));
          expect(prettyPrinter.toString(), equals('0xbadc0ded'));
        });
      });

      group('visitString', () {
        group('visitBasicString', () {
          test('encodes simple basic strings correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString('foo'));
            expect(prettyPrinter.toString(), equals('"foo"'));
          });
          test('escapes double quotes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString('foo "bar" baz'));
            expect(prettyPrinter.toString(), equals(r'"foo \"bar\" baz"'));
          });
          test('escapes backslashes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString(r'C:\Users'));
            expect(prettyPrinter.toString(), equals(r'"C:\\Users"'));
          });
          test('escapes control characters', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(
              TomlBasicString('\u0000\u001f\u007f'),
            );
            expect(prettyPrinter.toString(), equals(r'"\u0000\u001f\u007f"'));
          });
          test('does not escape single quotes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString("foo 'bar' baz"));
            expect(prettyPrinter.toString(), equals('"foo \'bar\' baz"'));
          });
          test('escapes newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString('line 1\nline 2'));
            expect(prettyPrinter.toString(), equals(r'"line 1\nline 2"'));
          });
          test('escapes Windows newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(TomlBasicString('line 1\r\nline 2'));
            expect(prettyPrinter.toString(), equals(r'"line 1\r\nline 2"'));
          });
          test('escapes standalone carriage return', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitBasicString(
              TomlBasicString('line 1\rstill line 1'),
            );
            expect(prettyPrinter.toString(), equals(r'"line 1\rstill line 1"'));
          });
        });
        group('visitLiteralString', () {
          test('encodes simple literal strings correctly', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitLiteralString(TomlLiteralString('foo'));
            expect(prettyPrinter.toString(), equals("'foo'"));
          });
        });
        group('visitMultilineBasicString', () {
          test('always inserts a newline after the opening delimiter', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo'),
            );
            expect(prettyPrinter.toString(), equals('"""\nfoo"""'));
          });
          test('does not escape single double quotes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo "bar" baz'),
            );
            expect(prettyPrinter.toString(), equals('"""\nfoo "bar" baz"""'));
          });
          test('does not escape two consecutive double quotes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo ""bar"" baz'),
            );
            expect(prettyPrinter.toString(), equals('"""\nfoo ""bar"" baz"""'));
          });
          test('escapes the third consecutive double quote', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo """bar""" baz'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nfoo ""\\"bar""\\" baz"""'),
            );
          });
          test('escapes every third consecutive double quote', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo """""""bar""""""" baz'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nfoo ""\\"""\\""bar""\\"""\\"" baz"""'),
            );
          });
          test('does not escape newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('line 1\nline 2'),
            );
            expect(prettyPrinter.toString(), equals('"""\nline 1\nline 2"""'));
          });
          test('does not escape Windows newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('line 1\r\nline 2'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nline 1\r\nline 2"""'),
            );
          });
          test('escapes standalone carriage return', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('line 1\rstill line 1'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nline 1\\rstill line 1"""'),
            );
          });
          test('escapes backslashes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString(r'C:\Users'),
            );
            expect(
              prettyPrinter.toString(),
              equals(
                '"""\n'
                r'C:\\Users"""',
              ),
            );
          });
          test('escapes control characters', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('\u0000\u001f\u007f'),
            );
            expect(
              prettyPrinter.toString(),
              equals(
                '"""\n'
                r'\u0000\u001f\u007f"""',
              ),
            );
          });
        });
        group('visitMultilineLiteralString', () {
          test('always inserts a newline after the opening delimiter', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineLiteralString(
              TomlMultilineLiteralString('foo'),
            );
            expect(prettyPrinter.toString(), equals("'''\nfoo'''"));
          });
          test('does not escape newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineLiteralString(
              TomlMultilineLiteralString('line 1\nline 2'),
            );
            expect(prettyPrinter.toString(), equals("'''\nline 1\nline 2'''"));
          });
          test('does not escape Windows newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineLiteralString(
              TomlMultilineLiteralString('line 1\r\nline 2'),
            );
            expect(
              prettyPrinter.toString(),
              equals("'''\nline 1\r\nline 2'''"),
            );
          });
        });
      });
    });
    group('visitSimpleKey', () {
      group('visitUnquotedKey', () {
        test('prints unquoted key without quotes', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitSimpleKey(TomlUnquotedKey('key'));
          expect(prettyPrinter.toString(), equals('key'));
        });
      });
      group('visitQuotedKey', () {
        test('prints basic quoted key with double quotes', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitSimpleKey(TomlQuotedKey(TomlBasicString('key')));
          expect(prettyPrinter.toString(), equals('"key"'));
        });
        test('prints literal quoted key with single quotes', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitSimpleKey(TomlQuotedKey(TomlLiteralString('key')));
          expect(prettyPrinter.toString(), equals("'key'"));
        });
      });
    });
    group('visitKey', () {
      test('prints no dot when there is a single simple key', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitKey(TomlKey([TomlUnquotedKey('table')]));
        expect(prettyPrinter.toString(), equals('table'));
      });
      test('uses dots without padding as separator', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitKey(
          TomlKey([
            TomlUnquotedKey('parent'),
            TomlUnquotedKey('table'),
            TomlUnquotedKey('child'),
          ]),
        );
        expect(prettyPrinter.toString(), equals('parent.table.child'));
      });
    });
    group('visitExpression', () {
      group('visitKeyValuePair', () {
        test('uses equals sign and one space padding as separator', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitKeyValuePair(
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key1')]),
              TomlInteger.dec(BigInt.from(1)),
            ),
          );
          expect(prettyPrinter.toString(), equals('key1 = 1'));
        });
        test('uses dots to separate parts of dotted keys', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitKeyValuePair(
            TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('a'),
                TomlUnquotedKey('b'),
                TomlUnquotedKey('c'),
              ]),
              TomlInteger.dec(BigInt.from(1)),
            ),
          );
          expect(prettyPrinter.toString(), equals('a.b.c = 1'));
        });
      });
      group('visitStandardTable', () {
        test('uses square brackets without padding as delimiter', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitStandardTable(
            TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
          );
          expect(prettyPrinter.toString(), equals('[table]'));
        });
      });
      group('visitArrayTable', () {
        test('uses double square brackets without padding as delimiter', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArrayTable(
            TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
          );
          expect(prettyPrinter.toString(), equals('[[array]]'));
        });
      });
    });
    group('visitDocument', () {
      test('always ends documents with newline', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(TomlDocument([]));
        expect(prettyPrinter.toString(), equals('\n'));
      });
      test('separates key/value pairs by newlines', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(
          TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key1')]),
              TomlInteger.dec(BigInt.from(1)),
            ),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key2')]),
              TomlInteger.dec(BigInt.from(2)),
            ),
          ]),
        );
        expect(prettyPrinter.toString(), equals('key1 = 1\nkey2 = 2\n'));
      });
      test('inserts blank line before standard table headers', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(
          TomlDocument([
            TomlStandardTable(TomlKey([TomlUnquotedKey('table1')])),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key1')]),
              TomlInteger.dec(BigInt.from(1)),
            ),
            TomlStandardTable(TomlKey([TomlUnquotedKey('table2')])),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key2')]),
              TomlInteger.dec(BigInt.from(2)),
            ),
          ]),
        );
        expect(
          prettyPrinter.toString(),
          equals('[table1]\nkey1 = 1\n\n[table2]\nkey2 = 2\n'),
        );
      });
      test('inserts blank line before array table headers', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(
          TomlDocument([
            TomlArrayTable(TomlKey([TomlUnquotedKey('array1')])),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key1')]),
              TomlInteger.dec(BigInt.from(1)),
            ),
            TomlArrayTable(TomlKey([TomlUnquotedKey('array2')])),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key2')]),
              TomlInteger.dec(BigInt.from(2)),
            ),
          ]),
        );
        expect(
          prettyPrinter.toString(),
          equals('[[array1]]\nkey1 = 1\n\n[[array2]]\nkey2 = 2\n'),
        );
      });
    });
  });
}
