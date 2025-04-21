import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlMultilineLiteralString', () {
    group('canEncode', () {
      test('can encode single quotes', () {
        expect(TomlMultilineLiteralString.canEncode("'"), isTrue);
      });
      test('cannot encode encode three consecutive single quotes', () {
        expect(TomlMultilineLiteralString.canEncode("'''"), isFalse);
      });
      test('can encode double quotes', () {
        expect(TomlMultilineLiteralString.canEncode('"'), isTrue);
      });
      test('can encode newline', () {
        expect(TomlMultilineLiteralString.canEncode('\n'), isTrue);
      });
      test('can encode windows newline', () {
        expect(TomlMultilineLiteralString.canEncode('\r\n'), isTrue);
      });
      test('cannot encode standalone carriage return', () {
        expect(TomlMultilineLiteralString.canEncode('\r'), isFalse);
      });
      test('can encode tab', () {
        expect(TomlMultilineLiteralString.canEncode('\t'), isTrue);
      });
      test('cannot encode control character', () {
        expect(TomlMultilineLiteralString.canEncode('\u0007'), isFalse);
      });
      test('can encode surrogate pairs', () {
        expect(TomlMultilineLiteralString.canEncode('\u{1f9a6}'), isTrue);
      });
      test('cannot encode standalone high surrogate characters', () {
        expect(TomlMultilineLiteralString.canEncode('\ud83e'), isFalse);
      });
      test('cannot encode standalone low surrogate characters', () {
        expect(TomlMultilineLiteralString.canEncode('\udda6'), isFalse);
      });
    });
    group('constructor', () {
      test(
        'cannot construct multiline literal string from non-encodable string',
        () {
          expect(
            () => TomlMultilineLiteralString("'''"),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });
    group('hashCode', () {
      test('two equal multiline literal strings have the same hash code', () {
        var s1 = TomlMultilineLiteralString('value');
        var s2 = TomlMultilineLiteralString('value');
        expect(s1.hashCode, equals(s2.hashCode));
      });
      test('different multiline literal strings have different hash codes', () {
        var s1 = TomlMultilineLiteralString('value1');
        var s2 = TomlMultilineLiteralString('value2');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
    });
  });
}
