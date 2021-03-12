library toml.test.ast.value.float_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlFloat', () {
    group('hashCode', () {
      test('the same floating point values have the same hash code', () {
        expect(TomlFloat(1.23).hashCode, equals(TomlFloat(1.23).hashCode));
      });
      test('two nan values have the same hash code', () {
        expect(
          TomlFloat(double.nan).hashCode,
          equals(TomlFloat(double.nan).hashCode),
        );
      });
      test('different floating point values have different hash codes', () {
        expect(
          TomlFloat(1.23).hashCode,
          isNot(equals(TomlFloat(2.34).hashCode)),
        );
      });
    });
    group('operator ==', () {
      test('two nan values are considered equal', () {
        expect(TomlFloat(double.nan), equals(TomlFloat(double.nan)));
      });
    });
  });
}
