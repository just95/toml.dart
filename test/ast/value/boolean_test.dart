library toml.test.ast.value.boolean_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlBoolean', () {
    group('hashCode', () {
      test('the same boolean values have the same hash code', () {
        expect(TomlBoolean(true).hashCode, equals(TomlBoolean(true).hashCode));
        expect(
          TomlBoolean(false).hashCode,
          equals(TomlBoolean(false).hashCode),
        );
      });
      test('different boolean values have different hash codes', () {
        expect(
          TomlBoolean(true).hashCode,
          isNot(equals(TomlBoolean(false).hashCode)),
        );
      });
    });
  });
}
