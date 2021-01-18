library toml.test.decoder.parser.document_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlDocument.parse', () {
    group('Key/Value Pair', () {
      test('can parse key/value pair with unquoted key', () {
        expect(
          TomlDocument.parse('key = "value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key')]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('can parse key/value pair with literal quoted key', () {
        expect(
          TomlDocument.parse("'ʎǝʞ' = 'value'"),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlQuotedKey(TomlLiteralString('ʎǝʞ'))]),
              TomlLiteralString('value'),
            )
          ])),
        );
      });
      test('can parse key/value pair with basic quoted key', () {
        expect(
          TomlDocument.parse('"ʎǝʞ" = "value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlQuotedKey(TomlBasicString('ʎǝʞ'))]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('allows whitespace around equals sign to be omitted', () {
        expect(
          TomlDocument.parse('key="value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key')]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('allows key/value pairs to be indented', () {
        expect(
          TomlDocument.parse('  key = "value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key')]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('allows comment after key/value pair', () {
        expect(
          TomlDocument.parse('key = "value" # Comment'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key')]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('does not allow the key to be on a new line', () {
        expect(
          () => TomlDocument.parse(
            'key\n'
            ' = "value"',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('does not allow the value to be on a new line', () {
        expect(
          () => TomlDocument.parse(
            'key =\n'
            '  "value"',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('allows two key/value pairs on the different lines', () {
        expect(
          TomlDocument.parse(
            'key1 = 1\n'
            'key2 = 2',
          ),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key1')]),
              TomlInteger.dec(BigInt.from(1)),
            ),
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key2')]),
              TomlInteger.dec(BigInt.from(2)),
            ),
          ])),
        );
      });
      test('rejects two key/value pairs on the same line', () {
        expect(
          () => TomlDocument.parse('key1 = 1 key2 = 2'),
          throwsA(isA<TomlParserException>()),
        );
      });
    });
    group('Standard Table', () {
      test('can parse standard table header with unquoted keys', () {
        expect(
          TomlDocument.parse('[a.b.c]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('can parse standard table header with literal quoted key', () {
        expect(
          TomlDocument.parse("[a.'β'.c]"),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlQuotedKey(TomlLiteralString('β')),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('can parse standard table header with basic quoted key', () {
        expect(
          TomlDocument.parse('[a."β".c]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlQuotedKey(TomlBasicString('β')),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows comment after standard table header', () {
        expect(
          TomlDocument.parse('[a.b.c] # Comment'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace after opening bracket', () {
        expect(
          TomlDocument.parse('[ a.b.c]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace before closing bracket', () {
        expect(
          TomlDocument.parse('[a.b.c ]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace around dots', () {
        expect(
          TomlDocument.parse('[a . b . c]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('rejects empty standard table header', () {
        expect(
          () => TomlDocument.parse('[]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects empty standard table header that ends with dot', () {
        expect(
          () => TomlDocument.parse('[a.b.c.]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects empty standard table header that starts with dot', () {
        expect(
          () => TomlDocument.parse('[.a.b.c]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects standard table header with consecutive dots', () {
        expect(
          () => TomlDocument.parse('[a..b.c]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects standard table header that contains a dot only', () {
        expect(
          () => TomlDocument.parse('[.]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines after opening bracket', () {
        expect(
          () => TomlDocument.parse(
            '[\n'
            'a.b.c]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines before closing bracket', () {
        expect(
          () => TomlDocument.parse(
            '[a.b.c\n'
            ']',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines after dots', () {
        expect(
          () => TomlDocument.parse(
            '[a.\n'
            'b.\n'
            'c]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines before dots', () {
        expect(
          () => TomlDocument.parse(
            '[a\n'
            '.b\n'
            '.c]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('allows two standard table headers on the different lines', () {
        expect(
          TomlDocument.parse(
            '[a]\n'
            '[b]',
          ),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([TomlUnquotedKey('a')])),
            TomlStandardTable(TomlKey([TomlUnquotedKey('b')])),
          ])),
        );
      });
      test('rejects two standard table headers on the same line', () {
        expect(
          () => TomlDocument.parse('[a] [b]'),
          throwsA(isA<TomlParserException>()),
        );
      });
    });
    group('Array Table', () {
      test('can parse array table header with unquoted keys', () {
        expect(
          TomlDocument.parse('[[a.b.c]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('can parse array table header with literal quoted key', () {
        expect(
          TomlDocument.parse("[[a.'β'.c]]"),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlQuotedKey(TomlLiteralString('β')),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('can parse array table header with basic quoted key', () {
        expect(
          TomlDocument.parse('[[a."β".c]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlQuotedKey(TomlBasicString('β')),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows comment after array table header', () {
        expect(
          TomlDocument.parse('[[a.b.c]] # Comment'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace after opening brackets', () {
        expect(
          TomlDocument.parse('[[ a.b.c]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace before closing brackets', () {
        expect(
          TomlDocument.parse('[[a.b.c ]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('allows whitespace around dots', () {
        expect(
          TomlDocument.parse('[[a . b . c]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
              TomlUnquotedKey('c'),
            ]))
          ])),
        );
      });
      test('rejects whitespace between backets', () {
        expect(
          () => TomlDocument.parse('[ [a.b.c] ]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects array table header with consecutive dots', () {
        expect(
          () => TomlDocument.parse('[[a..b.c]]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects array table header that contains a dot only', () {
        expect(
          () => TomlDocument.parse('[[.]]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines after opening brackets', () {
        expect(
          () => TomlDocument.parse(
            '[[\n'
            'a.b.c]]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines before closing brackets', () {
        expect(
          () => TomlDocument.parse(
            '[[a.b.c\n'
            ']]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines after dots', () {
        expect(
          () => TomlDocument.parse(
            '[[a.\n'
            'b.\n'
            'c]]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects newlines before dots', () {
        expect(
          () => TomlDocument.parse(
            '[[a\n'
            '.b\n'
            '.c]]',
          ),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('rejects empty array table header', () {
        expect(
          () => TomlDocument.parse('[[]]'),
          throwsA(isA<TomlParserException>()),
        );
      });
      test('allows two array table headers on the different lines', () {
        expect(
          TomlDocument.parse(
            '[[a]]\n'
            '[[b]]',
          ),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([TomlUnquotedKey('a')])),
            TomlArrayTable(TomlKey([TomlUnquotedKey('b')])),
          ])),
        );
      });
      test('rejects two array table headers on the same line', () {
        expect(
          () => TomlDocument.parse('[[a]] [[b]]'),
          throwsA(isA<TomlParserException>()),
        );
      });
    });
  });
}
