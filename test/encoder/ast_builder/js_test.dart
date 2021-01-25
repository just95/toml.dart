@TestOn('js')
library toml.test.encoder.ast_builder.js_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('JS', () {
    group('TomlAstBuilder', () {
      group('buildValue', () {
        test('builds integer from double without decimal places', () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildValue(42.0),
            equals(TomlInteger.dec(BigInt.from(42))),
          );
        });
        test('array of floats from mixed array of floats and integers', () {
          var builder = TomlAstBuilder();
          expect(
            builder.buildValue([1.0, 3.141, 42]),
            equals(TomlArray([
              TomlFloat(1.0),
              TomlFloat(3.141),
              TomlFloat(42.0),
            ])),
          );
        });
      });
    });
  });
}
