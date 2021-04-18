library toml.test.decoder.parser.document_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlDocument.parse', () {
    group('Comments', () {
      test('can parse comments', () {
        expect(
          TomlDocument.parse('# Comment'),
          equals(TomlDocument([])),
        );
      });
      test('comments end with newline', () {
        expect(
          TomlDocument.parse(
            '# Comment\n'
            'key = "value"',
          ),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('key')]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('comments cannot contain control characters', () {
        var input = '# Comment \u0000';
        expect(
          () => TomlDocument.parse(input),
          throwsA(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 10,
          )),
        );
      });
      test('comments cannot contain DEL character', () {
        var input = '# Comment \x7F';
        expect(
          () => TomlDocument.parse(input),
          throwsA(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 10,
          )),
        );
      });
      test('comments cannot contain unpaired UTF-16 surrogate code points', () {
        var input = '# High surrogate \uD83E without low surrogate';
        expect(
          () => TomlDocument.parse(input),
          throwsA(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 17,
          )),
        );
      });
      test('comments can contain UTF-16 surrogate pairs', () {
        expect(
          TomlDocument.parse(
            '# High and low surrogate \uD83E\uDDA6 as a pair',
          ),
          equals(TomlDocument([])),
        );
      });
    });
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
      test('can parse key/value pair with dotted key', () {
        expect(
          TomlDocument.parse('a.b.c = "value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('a'),
                TomlUnquotedKey('b'),
                TomlUnquotedKey('c'),
              ]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('allows whitespace between dots', () {
        expect(
          TomlDocument.parse('a . b . c = "value"'),
          equals(TomlDocument([
            TomlKeyValuePair(
              TomlKey([
                TomlUnquotedKey('a'),
                TomlUnquotedKey('b'),
                TomlUnquotedKey('c'),
              ]),
              TomlBasicString('value'),
            )
          ])),
        );
      });
      test('does not allow newlines after dots', () {
        var input = 'a.\n'
            'b.\n'
            'c = "value"';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"=" expected',
            source: input,
            offset: 1,
          ))),
        );
      });
      test('does not allow newlines before dots', () {
        var input = 'a\n'
            '.b\n'
            '.c = "value"';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"=" expected',
            source: input,
            offset: 1,
          ))),
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
      test('does not allow syntax errors in values', () {
        var input = 'key = "value';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: "closing '\"' expected",
            source: input,
            offset: 12,
          ))),
        );
      });
      test('does not allow the equal sign to be on a new line', () {
        var input = 'key\n'
            ' = "value"';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"=" expected',
            source: input,
            offset: 3,
          ))),
        );
      });
      test('does not allow the value to be on a new line', () {
        var input = 'key =\n'
            '  "value"';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'value expected',
            source: input,
            offset: 5,
          ))),
        );
      });
      test('allows two key/value pairs on different lines', () {
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
        var input = 'key1 = 1 key2 = 2';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 9,
          ))),
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
      test('allows standard table header to be indented', () {
        expect(
          TomlDocument.parse('  [a.b.c]'),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
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
        var input = '[]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 1,
          ))),
        );
      });
      test('rejects standard table header that ends with dot', () {
        var input = '[a.b.c.]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]" expected',
            source: input,
            offset: 6,
          ))),
        );
      });
      test('rejects standard table header that starts with dot', () {
        var input = '[.a.b.c]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 1,
          ))),
        );
      });
      test('rejects standard table header with consecutive dots', () {
        var input = '[a..b.c]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]" expected',
            source: input,
            offset: 2,
          ))),
        );
      });
      test('rejects standard table header that contains a dot only', () {
        var input = '[.]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 1,
          ))),
        );
      });
      test('rejects newlines after opening bracket', () {
        var input = '[\n'
            'a.b.c]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 1,
          ))),
        );
      });
      test('rejects newlines before closing bracket', () {
        var input = '[a.b.c\n'
            ']';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]" expected',
            source: input,
            offset: 6,
          ))),
        );
      });
      test('rejects newlines after dots', () {
        var input = '[a.\n'
            'b.\n'
            'c]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]" expected',
            source: input,
            offset: 2,
          ))),
        );
      });
      test('rejects newlines before dots', () {
        var input = '[a\n'
            '.b\n'
            '.c]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]" expected',
            source: input,
            offset: 2,
          ))),
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
        var input = '[a] [b]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 4,
          ))),
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
      test('allows array table header to be indented', () {
        expect(
          TomlDocument.parse('  [[a.b.c]]'),
          equals(TomlDocument([
            TomlArrayTable(TomlKey([
              TomlUnquotedKey('a'),
              TomlUnquotedKey('b'),
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
        var input = '[ [a.b.c] ]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 2,
          ))),
        );
      });
      test('rejects array table header with consecutive dots', () {
        var input = '[[a..b.c]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]]" expected',
            source: input,
            offset: 3,
          ))),
        );
      });
      test('rejects array table header that contains a dot only', () {
        var input = '[[.]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 2,
          ))),
        );
      });
      test('rejects newlines after opening brackets', () {
        var input = '[[\n'
            'a.b.c]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 2,
          ))),
        );
      });
      test('rejects newlines before closing brackets', () {
        var input = '[[a.b.c\n'
            ']]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]]" expected',
            source: input,
            offset: 7,
          ))),
        );
      });
      test('rejects newlines after dots', () {
        var input = '[[a.\n'
            'b.\n'
            'c]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]]" expected',
            source: input,
            offset: 3,
          ))),
        );
      });
      test('rejects newlines before dots', () {
        var input = '[[a\n'
            '.b\n'
            '.c]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: '"]]" expected',
            source: input,
            offset: 3,
          ))),
        );
      });
      test('rejects empty array table header', () {
        var input = '[[]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'key expected',
            source: input,
            offset: 2,
          ))),
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
        var input = '[[a]] [[b]]';
        expect(
          () => TomlDocument.parse(input),
          throwsA(equals(TomlParserException(
            message: 'newline or end of input expected',
            source: input,
            offset: 6,
          ))),
        );
      });
    });
  });
}
