@TestOn('vm')
library toml.test.encoder.ast_builder.vm_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('VM', () {
    group('TomlAstBuilder', () {
      group('buildValue', () {
        test('builds float from double without decimal places', () {
          var builder = TomlAstBuilder();
          expect(builder.buildValue(42.0), equals(TomlFloat(42.0)));
        });
      });
    });
  });
}
