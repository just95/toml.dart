library toml.test.decoder.value_builder_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';
import 'package:toml/src/decoder/value_builder.dart';

void main() {
  group('TomlValueBuilder', () {
    // TODO convert to accessor builder test
    /*group('visitArray', () {
      test('maps empty array to empty list', () {
        var builder = TomlValueBuilder();
        var result = builder.visitArray(TomlArray([]));
        expect(result, isEmpty);
      });
      test('maps non-empty array to list of same length', () {
        var builder = TomlValueBuilder();
        var result = builder.visitArray(TomlArray([
          TomlInteger.dec(BigInt.zero),
          TomlInteger.dec(BigInt.one),
          TomlInteger.dec(BigInt.two),
        ]));
        expect(result, equals([0, 1, 2]));
      });
    });*/
    group('visitBoolean', () {
      test('maps true to true', () {
        var builder = TomlValueBuilder();
        var result = builder.visitBoolean(TomlBoolean(true));
        expect(result, isTrue);
      });
      test('maps false to false', () {
        var builder = TomlValueBuilder();
        var result = builder.visitBoolean(TomlBoolean(false));
        expect(result, isFalse);
      });
    });
    group('visitDateTime', () {
      test('keeps AST node for offset date-times', () {
        var builder = TomlValueBuilder();
        var input = TomlOffsetDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
          TomlTimeZoneOffset.utc(),
        );
        var result = builder.visitDateTime(input);
        expect(result, equals(input));
      });
      test('keeps AST node for local date-times', () {
        var builder = TomlValueBuilder();
        var input = TomlLocalDateTime(
          TomlFullDate(1989, 11, 9),
          TomlPartialTime(17, 53, 0),
        );
        var result = builder.visitDateTime(input);
        expect(result, equals(input));
      });
      test('keeps AST node for local dates', () {
        var builder = TomlValueBuilder();
        var input = TomlLocalDate(TomlFullDate(1989, 11, 9));
        var result = builder.visitDateTime(input);
        expect(result, equals(input));
      });
      test('keeps AST node for local times', () {
        var builder = TomlValueBuilder();
        var input = TomlLocalTime(TomlPartialTime(17, 53, 0));
        var result = builder.visitDateTime(input);
        expect(result, equals(input));
      });
    });
    group('visitFloat', () {
      test('maps float to double', () {
        var builder = TomlValueBuilder();
        var result = builder.visitFloat(TomlFloat(13.37));
        expect(result, equals(13.37));
      });
      test('maps nan to double.nan', () {
        var builder = TomlValueBuilder();
        var result = builder.visitFloat(TomlFloat(double.nan));
        expect(result, isNaN);
      });
      test('maps positive infinity to double.infinity', () {
        var builder = TomlValueBuilder();
        var result = builder.visitFloat(TomlFloat(double.infinity));
        expect(result, equals(double.infinity));
      });
      test('maps positive infinity to double.infinity', () {
        var builder = TomlValueBuilder();
        var result = builder.visitFloat(TomlFloat(double.negativeInfinity));
        expect(result, equals(double.negativeInfinity));
      });
    });
    // TODO convert to accessor builder test.
    /*group('visitInlineTable', () {
      test('maps empty inline table to empty map', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInlineTable(TomlInlineTable([]));
        expect(result, equals({}));
      });
      test('maps non-empty inline table to non-empty map', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInlineTable(TomlInlineTable([
          TomlKeyValuePair(
            TomlKey([TomlUnquotedKey('key')]),
            TomlLiteralString('value'),
          )
        ]));
        expect(result, equals({'key': 'value'}));
      });
    });*/
    group('visitInteger', () {
      test('maps small binary integers to int', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInteger(TomlInteger.bin(BigInt.from(42)));
        expect(result, equals(42));
      });
      test('maps small octal integers to int', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInteger(TomlInteger.oct(BigInt.from(42)));
        expect(result, equals(42));
      });
      test('maps small decimal integers to int', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInteger(TomlInteger.dec(BigInt.from(42)));
        expect(result, equals(42));
      });
      test('maps small hexadecimal integers to int', () {
        var builder = TomlValueBuilder();
        var result = builder.visitInteger(TomlInteger.hex(BigInt.from(42)));
        expect(result, equals(42));
      });
      test('maps large integers to BigInt', () {
        var builder = TomlValueBuilder();
        var number = BigInt.two.pow(64) + BigInt.one;
        var result = builder.visitInteger(TomlInteger.dec(number));
        expect(result, equals(number));
      });
    });
    group('visitString', () {
      test('maps basic string to string', () {
        var builder = TomlValueBuilder();
        var result = builder.visitString(TomlBasicString('test'));
        expect(result, equals('test'));
      });
      test('maps literal string to string', () {
        var builder = TomlValueBuilder();
        var result = builder.visitString(TomlLiteralString('test'));
        expect(result, equals('test'));
      });
      test('maps multiline basic string to string', () {
        var builder = TomlValueBuilder();
        var result = builder.visitString(TomlMultilineBasicString('test'));
        expect(result, equals('test'));
      });
      test('maps multiline literal string to string', () {
        var builder = TomlValueBuilder();
        var result = builder.visitString(TomlMultilineLiteralString('test'));
        expect(result, equals('test'));
      });
    });
  });
}
