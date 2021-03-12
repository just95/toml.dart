library toml.test.ast.value.string.literal_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlLiteralString', () {
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
