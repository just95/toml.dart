library toml.test.ast.visitor.value_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlValueTestVisitor extends TomlValueVisitor<String> {
  @override
  String visitArray(_) => 'visitArray';

  @override
  String visitBoolean(_) => 'visitBoolean';

  @override
  String visitDateTime(_) => 'visitDateTime';

  @override
  String visitFloat(_) => 'visitFloat';

  @override
  String visitInlineTable(_) => 'visitInlineTable';

  @override
  String visitInteger(_) => 'visitInteger';

  @override
  String visitString(_) => 'visitString';
}

void main() {
  group('TomlValueVisitor', () {
    final visitor = TomlValueTestVisitor();
    test('visitArray', () {
      expect(
        visitor.visitValue(TomlArray([])),
        equals('visitArray'),
      );
    });
    test('visitBoolean', () {
      expect(
        visitor.visitValue(TomlBoolean(true)),
        equals('visitBoolean'),
      );
    });
    test('visitDateTime', () {
      expect(
        visitor.visitValue(TomlLocalDate(TomlFullDate(1969, 7, 20))),
        equals('visitDateTime'),
      );
    });
    test('visitFloat', () {
      expect(
        visitor.visitValue(TomlFloat(13.37)),
        equals('visitFloat'),
      );
    });
    test('visitInteger', () {
      expect(
        visitor.visitValue(TomlInteger.dec(BigInt.from(42))),
        equals('visitInteger'),
      );
    });
    test('visitString', () {
      expect(
        visitor.visitValue(TomlLiteralString('test')),
        equals('visitString'),
      );
    });
    test('visitInlineTable', () {
      expect(
        visitor.visitValue(TomlInlineTable([])),
        equals('visitInlineTable'),
      );
    });
  });
}
