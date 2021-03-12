library toml.test.ast.value.array_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlArray', () {
    group('hashCode', () {
      test('two equal arrays have the same hash code', () {
        var a1 = TomlArray([
          TomlInteger.dec(BigInt.zero),
          TomlInteger.dec(BigInt.one),
          TomlInteger.dec(BigInt.two),
        ]);
        var a2 = TomlArray([
          TomlInteger.dec(BigInt.zero),
          TomlInteger.dec(BigInt.one),
          TomlInteger.dec(BigInt.two),
        ]);
        expect(a1.hashCode, equals(a2.hashCode));
      });
      test('two arrays with different items have different hash codes', () {
        var a1 = TomlArray([
          TomlInteger.dec(BigInt.zero),
          TomlInteger.dec(BigInt.one),
          TomlInteger.dec(BigInt.two),
        ]);
        var a2 = TomlArray([
          TomlInteger.dec(BigInt.two),
          TomlInteger.dec(BigInt.one),
          TomlInteger.dec(BigInt.zero),
        ]);
        expect(a1.hashCode, isNot(equals(a2.hashCode)));
      });
    });
  });
}
