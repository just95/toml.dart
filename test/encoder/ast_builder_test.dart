library toml.test.encoder.ast_builder_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// A class that is used to test encoding of [TomlEncodable] values.
class TomlEncodableWrapper implements TomlEncodable {
  /// The wrapped value.
  final dynamic value;

  /// Creates a new wrapper for the given value.
  TomlEncodableWrapper(this.value);

  @override
  dynamic toToml() => value;
}

void main() {
  group('TomlAstBuilder', () {
    group('buildValue', () {
      test('builds integer from int', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue(42), equals(TomlInteger(42)));
      });
      test('builds float from double', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue(13.37), equals(TomlFloat(13.37)));
      });
      test('builds boolean from bool', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue(true), equals(TomlBoolean(true)));
        expect(builder.buildValue(false), equals(TomlBoolean(false)));
      });
      test('builds date-time from DateTime', () {
        var builder = TomlAstBuilder();
        var now = DateTime.now();
        expect(builder.buildValue(now), equals(TomlDateTime(now)));
      });
      test('builds literal string from String by default', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue('foo'), equals(TomlLiteralString('foo')));
      });
      test('builds basic string from String with apostrophe', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue("'"), equals(TomlBasicString("'")));
      });
      test('builds multiline literal string from String with newlines', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue('\n'),
          equals(TomlMultilineLiteralString('\n')),
        );
      });
      test(
        'builds multiline basic string from String with newlines and '
        'three apostrophes',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildValue("'''\n"),
            equals(TomlMultilineBasicString("'''\n")),
          );
        },
      );
      test('builds empty array from empty List', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue([]), equals(TomlArray([])));
      });
      test('builds array from empty Iterable', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue([0, 1, 2, 3].where((n) => n.isEven)),
          equals(TomlArray([TomlInteger(0), TomlInteger(2)])),
        );
      });
      test('builds empty inline table from empty Map', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(<String, dynamic>{}),
          equals(TomlInlineTable([])),
        );
      });
      test('builds inline table from Map with non-dynamic value type', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(<String, int>{'foo': 42}),
          equals(TomlInlineTable([
            TomlKeyValuePair(TomlUnquotedKey('foo'), TomlInteger(42)),
          ])),
        );
      });
      test('builds inline table from Map without type annotation', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({'foo': 42}),
          equals(TomlInlineTable([
            TomlKeyValuePair(TomlUnquotedKey('foo'), TomlInteger(42)),
          ])),
        );
      });
      test('requires the key type of empty Map to be annotated', () {
        var builder = TomlAstBuilder();
        var emptyMap = {};
        expect(
          () => builder.buildValue(emptyMap),
          throwsA(equals(TomlUnknownValueTypeException(emptyMap))),
        );
      });
      test('unwraps TomlEncodable values', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(TomlEncodableWrapper(42)),
          equals(TomlInteger(42)),
        );
      });
      test('unwraps TomlEncodable values recursively', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(TomlEncodableWrapper(TomlEncodableWrapper(42))),
          equals(TomlInteger(42)),
        );
      });
    });
    group('buildSimpleKey', () {
      test(
        'builds unquoted key if key contains ASCII letters, ASCII digits, '
        'underscores, and dashes only',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildSimpleKey('A-Z_a-z_0-9'),
            equals(TomlUnquotedKey('A-Z_a-z_0-9')),
          );
        },
      );
      test(
        'builds literal quoted key if there are non-ASCII letters',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildSimpleKey('ʎǝʞ'),
            equals(TomlQuotedKey(TomlLiteralString('ʎǝʞ'))),
          );
        },
      );
      test(
        'builds basic quoted key if there are non-ASCII letters that have to '
        'be escaped',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildSimpleKey("'"),
            equals(TomlQuotedKey(TomlBasicString("'"))),
          );
        },
      );
      test('does not build multiline strings', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildSimpleKey('\n'),
          equals(TomlQuotedKey(TomlBasicString('\n'))),
        );
      });
    });
    group('buildDocument', () {
      test('builds a standard table header for an empty Map', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildDocument({'table': <String, dynamic>{}}),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([TomlUnquotedKey('table')]))
          ])),
        );
      });
      test('omits redundant headers of parent tables', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildDocument({
            'parent': {'table': <String, dynamic>{}}
          }),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([
              TomlUnquotedKey('parent'),
              TomlUnquotedKey('table'),
            ]))
          ])),
        );
      });
      test(
        'builds a key/value pair if an array of tables is empty',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildDocument({'array': <Map<String, dynamic>>[]}),
            equals(TomlDocument([
              TomlKeyValuePair(TomlUnquotedKey('array'), TomlArray([])),
            ])),
          );
        },
      );
      test(
        'builds a standard array of tables header for every Map in a List',
        () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildDocument({
              'array': [
                <String, dynamic>{},
                <String, dynamic>{},
                <String, dynamic>{},
              ]
            }),
            equals(TomlDocument([
              TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
              TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
              TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
            ])),
          );
        },
      );
    });
  });
}
