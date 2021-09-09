@TestOn('vm')
library toml.test.decoder.parser.value.vm_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// The smallest signed 64-bit integer (`-2^63`).
final int minInt64 = -9223372036854775808;

/// [minInt64] as a [BigInt].
final BigInt minInt64Big = -(BigInt.two.pow(63));

/// The largest signed 64-bit integer (`2^63 - 1`).
final int maxInt64 = 9223372036854775807;

/// [maxInt64] as a [BigInt].
final BigInt maxInt64Big = BigInt.two.pow(63) - BigInt.one;

void main() {
  group('VM', () {
    group('TomlValueBuilder', () {
      group('visitInteger', () {
        test('uses int for smallest negative 64-bit integer', () {
          var builder = TomlValueBuilder();
          expect(
            builder.visitInteger(TomlInteger.dec(minInt64Big)),
            equals(minInt64),
          );
        });
        test('uses BigInt for number too small for signed 64-bit integer', () {
          var builder = TomlValueBuilder();
          expect(
            builder.visitInteger(TomlInteger.dec(minInt64Big - BigInt.one)),
            equals(minInt64Big - BigInt.one),
          );
        });
        test('uses int for largest positive 64-bit integer', () {
          var builder = TomlValueBuilder();
          expect(
            builder.visitInteger(TomlInteger.dec(maxInt64Big)),
            equals(maxInt64),
          );
        });
        test('uses BigInt for number too large for signed 64-bit integer', () {
          var builder = TomlValueBuilder();
          expect(
            builder.visitInteger(TomlInteger.dec(maxInt64Big + BigInt.one)),
            equals(maxInt64Big + BigInt.one),
          );
        });
      });
    });
  });
}
