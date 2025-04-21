import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// A class that is used to test encoding of [TomlEncodableKey] and
/// [TomlEncodableValue] objects.
class TomlEncodableWrapper with TomlEncodableKeyMixin {
  /// The wrapped value.
  final dynamic value;

  /// The wrapped key or `null` if it does not differ from the [value].
  final dynamic key;

  /// Creates a new wrapper for the given value.
  const TomlEncodableWrapper(this.value, [this.key]);

  @override
  dynamic toTomlValue() => value;

  @override
  dynamic toTomlKey() => key ?? super.toTomlKey();
}

void main() {
  group('TomlAstBuilder', () {
    group('buildValue', () {
      test('builds integer from int', () {
        expect(TomlValue.from(42), equals(TomlInteger.dec(BigInt.from(42))));
      });
      test('builds integer from BigInt', () {
        expect(
          TomlValue.from(BigInt.from(42)),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('preserves binary TOML integer values', () {
        var integer = TomlInteger.bin(BigInt.from(42));
        expect(TomlValue.from(integer), equals(integer));
      });
      test('preserves octal TOML integer values', () {
        var integer = TomlInteger.oct(BigInt.from(42));
        expect(TomlValue.from(integer), equals(integer));
      });
      test('preserves decimal TOML integer values', () {
        var integer = TomlInteger.dec(BigInt.from(42));
        expect(TomlValue.from(integer), equals(integer));
      });
      test('preserves hexadecimal TOML integer values', () {
        var integer = TomlInteger.hex(BigInt.from(42));
        expect(TomlValue.from(integer), equals(integer));
      });
      test('builds float from double', () {
        expect(TomlValue.from(13.37), equals(TomlFloat(13.37)));
      });
      test('builds boolean from bool', () {
        expect(TomlValue.from(true), equals(TomlBoolean(true)));
        expect(TomlValue.from(false), equals(TomlBoolean(false)));
      });
      test('builds offset date-time from UTC DateTime', () {
        var date = DateTime.utc(1969, 7, 20, 20, 17);
        expect(
          TomlValue.from(date),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1969, 7, 20),
              TomlPartialTime(20, 17, 0),
              TomlTimeZoneOffset.utc(),
            ),
          ),
        );
      });
      test('builds offset date-time from local DateTime', () {
        var date = DateTime(1969, 7, 20, 20, 17);
        expect(
          TomlValue.from(date),
          equals(
            TomlOffsetDateTime(
              TomlFullDate(1969, 7, 20),
              TomlPartialTime(20, 17, 0),
              TomlTimeZoneOffset.localAtInstant(date),
            ),
          ),
        );
      });
      test('preserves TOML offset date-time values', () {
        var date = TomlOffsetDateTime(
          TomlFullDate(1969, 7, 20),
          TomlPartialTime(20, 17, 0),
          TomlTimeZoneOffset.utc(),
        );
        expect(TomlValue.from(date), equals(date));
      });
      test('preserves TOML local date-time values', () {
        var date = TomlLocalDateTime(
          TomlFullDate(1969, 7, 20),
          TomlPartialTime(20, 17, 0),
        );
        expect(TomlValue.from(date), equals(date));
      });
      test('preserves TOML local date values', () {
        var date = TomlLocalDate(TomlFullDate(1969, 7, 20));
        expect(TomlValue.from(date), equals(date));
      });
      test('preserves TOML local time values', () {
        var time = TomlLocalTime(TomlPartialTime(20, 17, 0));
        expect(TomlValue.from(time), equals(time));
      });
      test('builds literal string from String by default', () {
        expect(TomlValue.from('foo'), equals(TomlLiteralString('foo')));
      });
      test('builds basic string from String with apostrophe', () {
        expect(TomlValue.from("'"), equals(TomlBasicString("'")));
      });
      test('builds multiline literal string from String with newlines', () {
        expect(TomlValue.from('\n'), equals(TomlMultilineLiteralString('\n')));
      });
      test('builds multiline basic string from String with newlines and '
          'three apostrophes', () {
        expect(
          TomlValue.from("'''\n"),
          equals(TomlMultilineBasicString("'''\n")),
        );
      });
      test('preserves TOML basic string values', () {
        var str = TomlBasicString('test');
        expect(TomlValue.from(str), equals(str));
      });
      test('preserves TOML multiline basic string values', () {
        var str = TomlMultilineBasicString('test');
        expect(TomlValue.from(str), equals(str));
      });
      test('preserves TOML literal string values', () {
        var str = TomlLiteralString('test');
        expect(TomlValue.from(str), equals(str));
      });
      test('preserves TOML multiline literal string values', () {
        var str = TomlMultilineLiteralString('test');
        expect(TomlValue.from(str), equals(str));
      });
      test('builds empty array from empty List', () {
        expect(TomlValue.from(<dynamic>[]), equals(TomlArray([])));
      });
      test('builds empty array from empty Iterable', () {
        expect(
          TomlValue.from([0, 1, 2, 3].where((n) => n.isNegative)),
          equals(TomlArray([])),
        );
      });
      test('builds array from Iterable', () {
        expect(
          TomlValue.from([0, 1, 2, 3].where((n) => n.isEven)),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(0)),
              TomlInteger.dec(BigInt.from(2)),
            ]),
          ),
        );
      });
      test('can build heterogeneous array', () {
        expect(
          TomlValue.from([1, true, 3.141]),
          equals(
            TomlArray([
              TomlInteger.dec(BigInt.from(1)),
              TomlBoolean(true),
              TomlFloat(3.141),
            ]),
          ),
        );
      });
      test('builds empty inline table from empty Map', () {
        expect(
          TomlValue.from(<String, dynamic>{}),
          equals(TomlInlineTable([])),
        );
      });
      test('builds inline table from Map with non-dynamic value type', () {
        expect(
          TomlValue.from({'foo': 42}),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('foo')]),
                TomlInteger.dec(BigInt.from(42)),
              ),
            ]),
          ),
        );
      });
      test('unwraps TomlEncodableKey objects', () {
        expect(
          TomlValue.from({TomlEncodableWrapper('foo'): 42}),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('foo')]),
                TomlInteger.dec(BigInt.from(42)),
              ),
            ]),
          ),
        );
      });
      test('unwraps TomlEncodableKey objects recursively', () {
        expect(
          TomlValue.from({
            TomlEncodableWrapper(TomlEncodableWrapper('foo')): 42,
          }),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('foo')]),
                TomlInteger.dec(BigInt.from(42)),
              ),
            ]),
          ),
        );
      });
      test('uses toTomlKey to unwrap TomlEncodableKey objects', () {
        expect(
          TomlValue.from({
            TomlEncodableWrapper('foo', 'bar'): TomlEncodableWrapper(
              'foo',
              'bar',
            ),
          }),
          equals(
            TomlInlineTable([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('bar')]),
                TomlLiteralString('foo'),
              ),
            ]),
          ),
        );
      });
      test('unwraps TomlEncodableValue objects', () {
        expect(
          TomlValue.from(TomlEncodableWrapper(42)),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('unwraps TomlEncodableValue objects recursively', () {
        expect(
          TomlValue.from(TomlEncodableWrapper(TomlEncodableWrapper(42))),
          equals(TomlInteger.dec(BigInt.from(42))),
        );
      });
      test('rejects null values', () {
        expect(
          () => TomlValue.from(null),
          throwsA(equals(TomlUnknownValueTypeException(null))),
        );
      });
      test('rejects values of types that are not encodable', () {
        var obj = Object();
        expect(
          () => TomlValue.from(obj),
          throwsA(equals(TomlUnknownValueTypeException(obj))),
        );
      });
    });
    group('buildSimpleKey', () {
      test('builds unquoted key if key contains ASCII letters, ASCII digits, '
          'underscores, and dashes only', () {
        expect(
          TomlSimpleKey.from('A-Z_a-z_0-9'),
          equals(TomlUnquotedKey('A-Z_a-z_0-9')),
        );
      });
      test('builds literal quoted key if there are non-ASCII letters', () {
        expect(
          TomlSimpleKey.from('ʎǝʞ'),
          equals(TomlQuotedKey(TomlLiteralString('ʎǝʞ'))),
        );
      });
      test(
        'builds basic quoted key if there are non-ASCII letters that have to '
        'be escaped',
        () {
          expect(
            TomlSimpleKey.from("'"),
            equals(TomlQuotedKey(TomlBasicString("'"))),
          );
        },
      );
      test('does not build multiline strings', () {
        expect(
          TomlSimpleKey.from('\n'),
          equals(TomlQuotedKey(TomlBasicString('\n'))),
        );
      });
      test('rejects null as keys', () {
        expect(
          () => TomlSimpleKey.from(null),
          throwsA(equals(TomlUnknownKeyTypeException(null))),
        );
      });
      test('rejects keys of types that are not encodable', () {
        var obj = Object();
        expect(
          () => TomlSimpleKey.from(obj),
          throwsA(equals(TomlUnknownKeyTypeException(obj))),
        );
      });
    });
    group('buildDocument', () {
      test('builds a standard table header for an empty Map', () {
        expect(
          TomlDocument.fromMap({'table': <String, dynamic>{}}),
          equals(
            TomlDocument([
              TomlStandardTable(TomlKey([TomlUnquotedKey('table')])),
            ]),
          ),
        );
      });
      test('omits redundant headers of parent tables', () {
        expect(
          TomlDocument.fromMap({
            'parent': {'table': <String, dynamic>{}},
          }),
          equals(
            TomlDocument([
              TomlStandardTable(
                TomlKey([TomlUnquotedKey('parent'), TomlUnquotedKey('table')]),
              ),
            ]),
          ),
        );
      });
      test('builds a key/value pair if an array of tables is empty', () {
        expect(
          TomlDocument.fromMap({'array': <Map>[]}),
          equals(
            TomlDocument([
              TomlKeyValuePair(
                TomlKey([TomlUnquotedKey('array')]),
                TomlArray([]),
              ),
            ]),
          ),
        );
      });
      test(
        'builds a standard array of tables header for every Map in a List',
        () {
          expect(
            TomlDocument.fromMap({
              'array': [
                <String, dynamic>{},
                <String, dynamic>{},
                <String, dynamic>{},
              ],
            }),
            equals(
              TomlDocument([
                TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
                TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
                TomlArrayTable(TomlKey([TomlUnquotedKey('array')])),
              ]),
            ),
          );
        },
      );
    });
  });
}
