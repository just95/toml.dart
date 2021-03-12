library toml.test.ast.value.string.literal_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlLiteralString', () {
    group('canEncode', () {
      test('cannot encode single quotes', () {
        expect(TomlLiteralString.canEncode("'"), isFalse);
      });
      test('can encode double quotes', () {
        expect(TomlLiteralString.canEncode('"'), isTrue);
      });
      test('cannot encode newline', () {
        expect(TomlLiteralString.canEncode('\n'), isFalse);
      });
      test('cannot encode windows newline', () {
        expect(TomlLiteralString.canEncode('\r\n'), isFalse);
      });
      test('cannot encode standalone carriage return', () {
        expect(TomlLiteralString.canEncode('\r'), isFalse);
      });
      test('can encode tab', () {
        expect(TomlLiteralString.canEncode('\t'), isTrue);
      });
      test('cannot encode control character', () {
        expect(TomlLiteralString.canEncode('\u0007'), isFalse);
      });
      test('can encode surrogate pairs', () {
        expect(TomlLiteralString.canEncode('\u{1f9a6}'), isTrue);
      });
      test('cannot encode standalone high surrogate characters', () {
        expect(TomlLiteralString.canEncode('\ud83e'), isFalse);
      });
      test('cannot encode standalone low surrogate characters', () {
        expect(TomlLiteralString.canEncode('\udda6'), isFalse);
      });
    });
    group('constructor', () {
      test('cannot construct literal string from non-encodable string', () {
        expect(() => TomlLiteralString("'"), throwsA(isA<ArgumentError>()));
      });
    });
    group('hashCode', () {
      test('two equal literal strings have the same hash code', () {
        var s1 = TomlLiteralString('value');
        var s2 = TomlLiteralString('value');
        expect(s1.hashCode, equals(s2.hashCode));
      });
      test('different literal strings have different hash codes', () {
        var s1 = TomlLiteralString('value1');
        var s2 = TomlLiteralString('value2');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('literal and multiline basic strings have different hash codes', () {
        var s1 = TomlLiteralString('value');
        var s2 = TomlMultilineBasicString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('literal and multiline literal strings have different hash codes',
          () {
        var s1 = TomlLiteralString('value');
        var s2 = TomlMultilineLiteralString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
    });
  });
}
