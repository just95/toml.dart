library toml.test.encoder.ast_builder_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// A class that is used to test encoding of [TomlEncodableKey] and
/// [TomlEncodableValue] objects.
class TomlEncodableWrapper extends TomlEncodableKey {
  /// The wrapped value.
  final dynamic value;

  /// The wrapped key or `null` if it does not differ from the [value].
  final dynamic key;

  /// Creates a new wrapper for the given value.
  TomlEncodableWrapper(this.value, [this.key]);

  @override
  dynamic toTomlValue() => value;

  @override
  dynamic toTomlKey() => key ?? value;
}

void main() {
  group('TomlAstBuilder', () {
    group('buildValue', () {
      test('builds integer from int', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(42),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('builds integer from BigInt', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(BigInt.from(42)),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('preserves binary TOML integer values', () {
        var builder = TomlAstBuilder();
        var integer = TomlInteger.bin(BigInt.from(42));
        expect(
          builder.buildValue(integer),
          equals(integer),
        );
      });
      test('preserves octal TOML integer values', () {
        var builder = TomlAstBuilder();
        var integer = TomlInteger.oct(BigInt.from(42));
        expect(
          builder.buildValue(integer),
          equals(integer),
        );
      });
      test('preserves decimal TOML integer values', () {
        var builder = TomlAstBuilder();
        var integer = TomlInteger.dec(BigInt.from(42));
        expect(
          builder.buildValue(integer),
          equals(integer),
        );
      });
      test('preserves hexadecimal TOML integer values', () {
        var builder = TomlAstBuilder();
        var integer = TomlInteger.hex(BigInt.from(42));
        expect(
          builder.buildValue(integer),
          equals(integer),
        );
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
      test('builds offset date-time from UTC DateTime', () {
        var builder = TomlAstBuilder();
        var date = DateTime.utc(1969, 7, 20, 20, 17);
        expect(
            builder.buildValue(date),
            equals(TomlOffsetDateTime(
              TomlFullDate(1969, 7, 20),
              TomlPartialTime(20, 17, 0),
              TomlTimeZoneOffset.utc(),
            )));
      });
      test('builds offset date-time from local DateTime', () {
        var builder = TomlAstBuilder();
        var date = DateTime(1969, 7, 20, 20, 17);
        expect(
            builder.buildValue(date),
            equals(TomlOffsetDateTime(
              TomlFullDate(1969, 7, 20),
              TomlPartialTime(20, 17, 0),
              TomlTimeZoneOffset.local(),
            )));
      });
      test('preserves TOML offset date-time values', () {
        var builder = TomlAstBuilder();
        var date = TomlOffsetDateTime(
          TomlFullDate(1969, 7, 20),
          TomlPartialTime(20, 17, 0),
          TomlTimeZoneOffset.utc(),
        );
        expect(builder.buildValue(date), equals(date));
      });
      test('preserves TOML local date-time values', () {
        var builder = TomlAstBuilder();
        var date = TomlLocalDateTime(
          TomlFullDate(1969, 7, 20),
          TomlPartialTime(20, 17, 0),
        );
        expect(builder.buildValue(date), equals(date));
      });
      test('preserves TOML local date values', () {
        var builder = TomlAstBuilder();
        var date = TomlLocalDate(
          TomlFullDate(1969, 7, 20),
        );
        expect(builder.buildValue(date), equals(date));
      });
      test('preserves TOML local time values', () {
        var builder = TomlAstBuilder();
        var time = TomlLocalTime(
          TomlPartialTime(20, 17, 0),
        );
        expect(builder.buildValue(time), equals(time));
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
      test('preserves TOML basic string values', () {
        var builder = TomlAstBuilder();
        var str = TomlBasicString('test');
        expect(builder.buildValue(str), equals(str));
      });
      test('preserves TOML multiline basic string values', () {
        var builder = TomlAstBuilder();
        var str = TomlMultilineBasicString('test');
        expect(builder.buildValue(str), equals(str));
      });
      test('preserves TOML literal string values', () {
        var builder = TomlAstBuilder();
        var str = TomlLiteralString('test');
        expect(builder.buildValue(str), equals(str));
      });
      test('preserves TOML multiline literal string values', () {
        var builder = TomlAstBuilder();
        var str = TomlMultilineLiteralString('test');
        expect(builder.buildValue(str), equals(str));
      });
      test('builds empty array from empty List', () {
        var builder = TomlAstBuilder();
        expect(builder.buildValue([]), equals(TomlArray([])));
      });
      test('builds empty array from empty Iterable', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue([0, 1, 2, 3].where((n) => n.isNegative)),
          equals(TomlArray([])),
        );
      });
      test('builds array from Iterable', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue([0, 1, 2, 3].where((n) => n.isEven)),
          equals(TomlArray([
            TomlInteger.dec(BigInt.from(0)),
            TomlInteger.dec(BigInt.from(2))
          ])),
        );
      });
      test('can build heterogeneous array', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue([1, true, 3.141]),
          equals(TomlArray([
            TomlInteger.dec(BigInt.from(1)),
            TomlBoolean(true),
            TomlFloat(3.141),
          ])),
        );
      });
      test('builds empty inline table from empty Map', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({}),
          equals(TomlInlineTable([])),
        );
      });
      test('builds inline table from Map with non-dynamic value type', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({'foo': 42}),
          equals(TomlInlineTable([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('foo')]),
              TomlInteger.dec(BigInt.from(42)),
            ),
          ])),
        );
      });
      test('unwraps TomlEncodableKey objects', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({TomlEncodableWrapper('foo'): 42}),
          equals(TomlInlineTable([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('foo')]),
              TomlInteger.dec(BigInt.from(42)),
            ),
          ])),
        );
      });
      test('unwraps TomlEncodableKey objects recursively', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({
            TomlEncodableWrapper(TomlEncodableWrapper('foo')): 42,
          }),
          equals(TomlInlineTable([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('foo')]),
              TomlInteger.dec(BigInt.from(42)),
            ),
          ])),
        );
      });
      test('uses toTomlKey to unwrap TomlEncodableKey objects', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue({
            TomlEncodableWrapper('foo', 'bar'):
                TomlEncodableWrapper('foo', 'bar')
          }),
          equals(TomlInlineTable([
            TomlKeyValuePair(
              TomlKey([TomlUnquotedKey('bar')]),
              TomlLiteralString('foo'),
            ),
          ])),
        );
      });
      test('unwraps TomlEncodableValue objects', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(TomlEncodableWrapper(42)),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('unwraps TomlEncodableValue objects recursively', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildValue(TomlEncodableWrapper(TomlEncodableWrapper(42))),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('rejects null values', () {
        var builder = TomlAstBuilder();
        expect(
          () => builder.buildValue(null),
          throwsA(equals(TomlUnknownValueTypeException(null))),
        );
      });
      test('rejects values of types that are not encodable', () {
        var builder = TomlAstBuilder();
        var obj = Object();
        expect(
          () => builder.buildValue(obj),
          throwsA(equals(TomlUnknownValueTypeException(obj))),
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
      test('rejects null as keys', () {
        var builder = TomlAstBuilder();
        expect(
          () => builder.buildSimpleKey(null),
          throwsA(equals(TomlUnknownKeyTypeException(null))),
        );
      });
      test('rejects keys of types that are not encodable', () {
        var builder = TomlAstBuilder();
        var obj = Object();
        expect(
          () => builder.buildSimpleKey(obj),
          throwsA(equals(TomlUnknownKeyTypeException(obj))),
        );
      });
    });
    group('buildDocument', () {
      test('builds a standard table header for an empty Map', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildDocument({'table': {}}),
          equals(TomlDocument([
            TomlStandardTable(TomlKey([TomlUnquotedKey('table')]))
          ])),
        );
      });
      test('omits redundant headers of parent tables', () {
        var builder = TomlAstBuilder();
        expect(
          builder.buildDocument({
            'parent': {'table': {}}
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
            builder.buildDocument({'array': <Map>[]}),
            equals(TomlDocument([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('array')]),
                TomlArray([]),
              ),
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
              'array': [{}, {}, {}]
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
