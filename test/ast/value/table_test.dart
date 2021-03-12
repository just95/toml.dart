library toml.test.ast.value.array_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlInlineTable', () {
    group('hashCode', () {
      test('two equal inline tables have the same hash code', () {
        var a1 = TomlInlineTable([
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('zero')]),
            TomlInteger.dec(BigInt.zero),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('one')]),
            TomlInteger.dec(BigInt.one),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('two')]),
            TomlInteger.dec(BigInt.two),
          ),
        ]);
        var a2 = TomlInlineTable([
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('zero')]),
            TomlInteger.dec(BigInt.zero),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('one')]),
            TomlInteger.dec(BigInt.one),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('two')]),
            TomlInteger.dec(BigInt.two),
          ),
        ]);
        expect(a1.hashCode, equals(a2.hashCode));
      });
      test('inline tables with different keys have different hash codes', () {
        var a1 = TomlInlineTable([
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('zero')]),
            TomlInteger.dec(BigInt.zero),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('one')]),
            TomlInteger.dec(BigInt.one),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('two')]),
            TomlInteger.dec(BigInt.two),
          ),
        ]);
        var a2 = TomlInlineTable([
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('0')]),
            TomlInteger.dec(BigInt.zero),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('1')]),
            TomlInteger.dec(BigInt.one),
          ),
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('2')]),
            TomlInteger.dec(BigInt.two),
          ),
        ]);
        expect(a1.hashCode, isNot(equals(a2.hashCode)));
      });
    });
    test('inline tables with different order have different hash codes', () {
      var a1 = TomlInlineTable([
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('zero')]),
          TomlInteger.dec(BigInt.zero),
        ),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('one')]),
          TomlInteger.dec(BigInt.one),
        ),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('two')]),
          TomlInteger.dec(BigInt.two),
        ),
      ]);
      var a2 = TomlInlineTable([
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('two')]),
          TomlInteger.dec(BigInt.two),
        ),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('one')]),
          TomlInteger.dec(BigInt.one),
        ),
        TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('zero')]),
          TomlInteger.dec(BigInt.zero),
        ),
      ]);
      expect(a1.hashCode, isNot(equals(a2.hashCode)));
    });
  });
}
