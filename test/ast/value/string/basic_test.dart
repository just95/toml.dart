library toml.test.ast.value.string.basic_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlBasicString', () {
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
