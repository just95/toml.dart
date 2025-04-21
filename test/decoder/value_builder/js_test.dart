@TestOn('js')
library;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

/// The smallest integer that can losslessly be represented by a JavaScript
/// number (`-(2^53 - 1)`).
final int minSafeInt = -9007199254740991;

/// [minSafeInt] as a [BigInt].
final BigInt minSafeBigInt = -maxSafeBigInt;

/// The greatest integer that can losslessly be represented by a JavaScript
/// number (`2^53 - 1`).
final int maxSafeInt = 9007199254740991;

/// [maxSafeInt] as a [BigInt].
final BigInt maxSafeBigInt = BigInt.two.pow(53) - BigInt.one;

void main() {
  group('JS', () {
    group('TomlValueBuilder', () {
      group('visitInteger', () {
        test('uses int for smallest safe JavaScript integer', () {
          var builder = TomlValueBuilder(TomlKey.topLevel);
          expect(
            builder.visitInteger(TomlInteger.dec(minSafeBigInt)),
            equals(minSafeInt),
          );
        });
        test('uses BigInt for number smaller than safe JavaScript integer', () {
          var builder = TomlValueBuilder(TomlKey.topLevel);
          expect(
            builder.visitInteger(TomlInteger.dec(minSafeBigInt - BigInt.two)),
            equals(minSafeBigInt - BigInt.two),
          );
        });
        test(
          'uses int for safe JavaScript integer smaller than min. safe integer',
          () {
            var builder = TomlValueBuilder(TomlKey.topLevel);
            expect(
              builder.visitInteger(
                TomlInteger.dec(BigInt.two * (minSafeBigInt - BigInt.one)),
              ),
              equals(-18014398509481984), // -2^54
            );
          },
        );
        test('uses int for greatest safe JavaScript integer', () {
          var builder = TomlValueBuilder(TomlKey.topLevel);
          expect(
            builder.visitInteger(TomlInteger.dec(maxSafeBigInt)),
            equals(maxSafeInt),
          );
        });
        test('uses BigInt for number greater than safe JavaScript integer', () {
          var builder = TomlValueBuilder(TomlKey.topLevel);
          expect(
            builder.visitInteger(TomlInteger.dec(maxSafeBigInt + BigInt.two)),
            equals(maxSafeBigInt + BigInt.two),
          );
        });
        test(
          'uses int for safe JavaScript integer greater than max. safe integer',
          () {
            var builder = TomlValueBuilder(TomlKey.topLevel);
            expect(
              builder.visitInteger(
                TomlInteger.dec(BigInt.two * (maxSafeBigInt + BigInt.one)),
              ),
              equals(18014398509481984), // 2^54
            );
          },
        );
      });
    });
  });
}
