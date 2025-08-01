import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlBasicString', () {
    group('escape', () {
      test('escapes double quotes', () {
        expect(TomlBasicString.escape('"'), equals(r'\"'));
      });
      test('does not escape single quotes', () {
        expect(TomlBasicString.escape("'"), equals("'"));
      });
      test('escapes newlines', () {
        expect(TomlBasicString.escape('\n'), equals(r'\n'));
      });
      test('escapes windows newlines', () {
        expect(TomlBasicString.escape('\r\n'), equals(r'\r\n'));
      });
      test('escapes standalone carriage return newlines', () {
        expect(TomlBasicString.escape('\r'), equals(r'\r'));
      });
      test('does not escape tabs', () {
        expect(TomlBasicString.escape('\t'), equals('\t'));
      });
      test('escapes control characters', () {
        expect(TomlBasicString.escape('\x07'), equals(r'\u0007'));
      });
      test('does not escape surrogate pairs', () {
        expect(TomlBasicString.escape('\u{1f9a6}'), equals('\u{1f9a6}'));
      });
      test('cannot escape standalone high surrogate characters', () {
        expect(
          () => TomlBasicString.escape('\ud83e'),
          throwsA(equals(TomlInvalidEscapeSequenceException('\\ud83e'))),
        );
      });
      test('cannot escape standalone low surrogate characters', () {
        expect(
          () => TomlBasicString.escape('\udda6'),
          throwsA(equals(TomlInvalidEscapeSequenceException('\\udda6'))),
        );
      });
    });
    group('canEncode', () {
      test('cannot encode strings with non-scalar Unicode values', () {
        expect(TomlBasicString.canEncode('\udda6'), isFalse);
      });
    });
    group('construct', () {
      test(
        'cannot construct basic string strings with non-scalar Unicode value',
        () {
          expect(
            () => TomlBasicString('\udda6'),
            throwsA(isA<ArgumentError>()),
          );
        },
      );
    });
    group('hashCode', () {
      test('two equal basic strings have the same hash code', () {
        var s1 = TomlBasicString('value');
        var s2 = TomlBasicString('value');
        expect(s1.hashCode, equals(s2.hashCode));
      });
      test('different basic strings have different hash codes', () {
        var s1 = TomlBasicString('value1');
        var s2 = TomlBasicString('value2');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('basic and literal strings have different hash codes', () {
        var s1 = TomlBasicString('value');
        var s2 = TomlLiteralString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('basic and multiline basic strings have different hash codes', () {
        var s1 = TomlBasicString('value');
        var s2 = TomlMultilineBasicString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('basic and multiline literal strings have different hash codes', () {
        var s1 = TomlBasicString('value');
        var s2 = TomlMultilineLiteralString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
    });
  });
}
