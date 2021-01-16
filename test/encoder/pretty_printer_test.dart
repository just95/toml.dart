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
        test('pretty prints one elementry array correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArray(TomlArray([TomlInteger(1)]));
          expect(prettyPrinter.toString(), equals('[1]'));
        });
        test('pretty prints array with multiple items correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitArray(TomlArray([
            TomlInteger(1),
            TomlInteger(2),
            TomlInteger(3),
          ]));
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
        test('pretty prints UTC date-time correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitDateTime(TomlDateTime(
            DateTime.utc(1969, 7, 20, 20, 17),
          ));
          expect(prettyPrinter.toString(), equals('1969-07-20T20:17:00Z'));
        });
        test('pretty prints UTC date-time with milliseconds correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitDateTime(TomlDateTime(
            DateTime.utc(1969, 7, 20, 20, 17, 0, 123),
          ));
          expect(prettyPrinter.toString(), equals('1969-07-20T20:17:00.123Z'));
        });
        test('pretty prints local date-time with offset', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitDateTime(TomlDateTime(
            DateTime(1969, 7, 20, 20, 17),
          ));
          expect(
            prettyPrinter.toString(),
            matches(r'1969-07-20T20:17:00[+-]\d\d:\d\d'),
          );
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
      });
      group('visitInlineTable', () {
        test('pretty prints empty inline table correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInlineTable(TomlInlineTable([]));
          expect(prettyPrinter.toString(), equals('{}'));
        });
        test('pretty prints inline table with one key/value pair correctly',
            () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInlineTable(TomlInlineTable([
            TomlKeyValuePair(TomlUnquotedKey('foo'), TomlInteger(0)),
          ]));
          expect(prettyPrinter.toString(), equals('{ foo = 0 }'));
        });
        test(
          'pretty prints inline table with multiple key/value pairs correctly',
          () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitInlineTable(TomlInlineTable([
              TomlKeyValuePair(TomlUnquotedKey('foo'), TomlInteger(0)),
              TomlKeyValuePair(TomlUnquotedKey('bar'), TomlInteger(1)),
              TomlKeyValuePair(TomlUnquotedKey('baz'), TomlInteger(2)),
            ]));
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
          prettyPrinter.visitInteger(TomlInteger(0));
          expect(prettyPrinter.toString(), equals('0'));
        });
        test('pretty prints positive integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger(42));
          expect(prettyPrinter.toString(), equals('42'));
        });
        test('pretty prints negative integer correctly', () {
          var prettyPrinter = TomlPrettyPrinter();
          prettyPrinter.visitInteger(TomlInteger(-273));
          expect(prettyPrinter.toString(), equals('-273'));
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
          test('does not escape two consequtive double quotes', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo ""bar"" baz'),
            );
            expect(prettyPrinter.toString(), equals('"""\nfoo ""bar"" baz"""'));
          });
          test('escapes the third consequtive double quote', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo """bar""" baz'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nfoo ""\\"bar""\\" baz"""'),
            );
          });
          test('escapes every third consequtive double quote', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('foo """""""bar""""""" baz'),
            );
            expect(
              prettyPrinter.toString(),
              equals('"""\nfoo ""\\"""\\""bar""\\"""\\"" baz"""'),
            );
          });
          test('does not escapes newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineBasicString(
              TomlMultilineBasicString('line 1\nline 2'),
            );
            expect(prettyPrinter.toString(), equals('"""\nline 1\nline 2"""'));
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
          test('does not escapes newlines', () {
            var prettyPrinter = TomlPrettyPrinter();
            prettyPrinter.visitMultilineLiteralString(
              TomlMultilineLiteralString('line 1\nline 2'),
            );
            expect(prettyPrinter.toString(), equals("'''\nline 1\nline 2'''"));
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
            TomlUnquotedKey('child')
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
            TomlKeyValuePair(TomlUnquotedKey('key1'), TomlInteger(1)),
          );
          expect(prettyPrinter.toString(), equals('key1 = 1'));
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
        prettyPrinter.visitDocument(TomlDocument([
          TomlKeyValuePair(TomlUnquotedKey('key1'), TomlInteger(1)),
          TomlKeyValuePair(TomlUnquotedKey('key2'), TomlInteger(2)),
        ]));
        expect(prettyPrinter.toString(), equals('key1 = 1\nkey2 = 2\n'));
      });
      test('inserts blank line before standard table headers', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(TomlDocument([
          TomlStandardTable(TomlKey([TomlUnquotedKey('table1')])),
          TomlKeyValuePair(TomlUnquotedKey('key1'), TomlInteger(1)),
          TomlStandardTable(TomlKey([TomlUnquotedKey('table2')])),
          TomlKeyValuePair(TomlUnquotedKey('key2'), TomlInteger(2)),
        ]));
        expect(
          prettyPrinter.toString(),
          equals('[table1]\nkey1 = 1\n\n[table2]\nkey2 = 2\n'),
        );
      });
      test('inserts blank line before array table headers', () {
        var prettyPrinter = TomlPrettyPrinter();
        prettyPrinter.visitDocument(TomlDocument([
          TomlArrayTable(TomlKey([TomlUnquotedKey('array1')])),
          TomlKeyValuePair(TomlUnquotedKey('key1'), TomlInteger(1)),
          TomlArrayTable(TomlKey([TomlUnquotedKey('array2')])),
          TomlKeyValuePair(TomlUnquotedKey('key2'), TomlInteger(2)),
        ]));
        expect(
          prettyPrinter.toString(),
          equals('[[array1]]\nkey1 = 1\n\n[[array2]]\nkey2 = 2\n'),
        );
      });
    });
  });
}
