library toml.test.ast.value.string.ml_basic_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlMultilineBasicString', () {
    group('hashCode', () {
      test('two equal multiline basic strings have the same hash code', () {
        var s1 = TomlMultilineBasicString('value');
        var s2 = TomlMultilineBasicString('value');
        expect(s1.hashCode, equals(s2.hashCode));
      });
      test('different multiline basic strings have different hash codes', () {
        var s1 = TomlMultilineBasicString('value1');
        var s2 = TomlMultilineBasicString('value2');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
      test('multiline basic and literal strings have different hash codes', () {
        var s1 = TomlMultilineBasicString('value');
        var s2 = TomlMultilineLiteralString('value');
        expect(s1.hashCode, isNot(equals(s2.hashCode)));
      });
    });
  });
}
