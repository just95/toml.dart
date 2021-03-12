library toml.test.ast.value.integer_test;

import 'package:test/test.dart';
import 'package:toml/toml.dart';

void main() {
  group('TomlInteger', () {
    group('constructor', () {
      test('cannot construct negative binary integer', () {
        expect(
          () => TomlInteger.bin(BigInt.from(-42)),
          throwsA(isA<ArgumentError>()),
        );
      });
      test('cannot construct negative octal integer', () {
        expect(
          () => TomlInteger.oct(BigInt.from(-42)),
          throwsA(isA<ArgumentError>()),
        );
      });
      test('can construct negative decimal integer', () {
        expect(() => TomlInteger.dec(BigInt.from(-42)), returnsNormally);
      });
      test('cannot construct negative hexadecimal integer', () {
        expect(
          () => TomlInteger.hex(BigInt.from(-42)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
    group('hashCode', () {
      test('the same binary integers have the same hash code', () {
        expect(
          TomlInteger.bin(BigInt.from(42)).hashCode,
          equals(TomlInteger.bin(BigInt.from(42)).hashCode),
        );
      });
      test('different binary integers have different hash codes', () {
        expect(
          TomlInteger.bin(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.bin(BigInt.from(1337)).hashCode)),
        );
      });
      test('the same octal integers have the same hash code', () {
        expect(
          TomlInteger.oct(BigInt.from(42)).hashCode,
          equals(TomlInteger.oct(BigInt.from(42)).hashCode),
        );
      });
      test('different octal integers have different hash codes', () {
        expect(
          TomlInteger.oct(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.oct(BigInt.from(1337)).hashCode)),
        );
      });
      test('the same decimal integers have the same hash code', () {
        expect(
          TomlInteger.dec(BigInt.from(42)).hashCode,
          equals(TomlInteger.dec(BigInt.from(42)).hashCode),
        );
      });
      test('different decimal integers have different hash codes', () {
        expect(
          TomlInteger.dec(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.dec(BigInt.from(1337)).hashCode)),
        );
      });
      test('the same hexadecimal integers have the same hash code', () {
        expect(
          TomlInteger.hex(BigInt.from(42)).hashCode,
          equals(TomlInteger.hex(BigInt.from(42)).hashCode),
        );
      });
      test('different hexadecimal integers have different hash codes', () {
        expect(
          TomlInteger.hex(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.hex(BigInt.from(1337)).hashCode)),
        );
      });
      test('binary and octal integers have different hash codes', () {
        expect(
          TomlInteger.bin(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.oct(BigInt.from(42)).hashCode)),
        );
      });
      test('binary and decimal integers have different hash codes', () {
        expect(
          TomlInteger.bin(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.dec(BigInt.from(42)).hashCode)),
        );
      });
      test('binary and hexadecimal integers have different hash codes', () {
        expect(
          TomlInteger.bin(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.hex(BigInt.from(42)).hashCode)),
        );
      });
      test('octal and decimal integers have different hash codes', () {
        expect(
          TomlInteger.oct(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.dec(BigInt.from(42)).hashCode)),
        );
      });
      test('octal and hexadecimal integers have different hash codes', () {
        expect(
          TomlInteger.oct(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.hex(BigInt.from(42)).hashCode)),
        );
      });
      test('decimal and hexadecimal integers have different hash codes', () {
        expect(
          TomlInteger.dec(BigInt.from(42)).hashCode,
          isNot(equals(TomlInteger.hex(BigInt.from(42)).hashCode)),
        );
      });
    });
  });
}
