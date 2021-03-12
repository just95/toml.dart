library toml.test.ast.expression.key_value_pair_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

void main() {
  group('TomlKeyValuePair', () {
    group('hashCode', () {
      test('equal key/value pairs have the same hash code', () {
        var d1 = TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        );
        var d2 = TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        );
        expect(d1.hashCode, equals(d2.hashCode));
      });
      test('key/value pairs with different keys have different hash codes', () {
        var d1 = TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key1')]),
          TomlLiteralString('value'),
        );
        var d2 = TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key2')]),
          TomlLiteralString('value'),
        );
        expect(d1.hashCode, isNot(equals(d2.hashCode)));
      });
      test(
        'key/value pairs with different values have different hash codes',
        () {
          var d1 = TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value1'),
          );
          var d2 = TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value2'),
          );
          expect(d1.hashCode, isNot(equals(d2.hashCode)));
        },
      );
    });
  });
}
