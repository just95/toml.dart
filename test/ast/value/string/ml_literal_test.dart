library toml.test.ast.value.string.ml_literal_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlMultilineLiteralString', () {
    group('canEncode', () {
      test('cannot encode string with standalone carriage return', () {
        expect(
          TomlMultilineLiteralString.canEncode('line 1\rstill line 1'),
          isFalse,
        );
      });
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
