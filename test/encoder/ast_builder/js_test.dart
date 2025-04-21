@TestOn('js')
library;

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
      });
    });
  });
}
