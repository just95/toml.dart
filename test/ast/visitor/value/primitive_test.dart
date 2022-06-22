library toml.test.ast.visitor.value.primitive_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// accepted the visitor.
class TomlValueTestVisitor with TomlPrimitiveValueVisitorMixin<String> {
  @override
  String visitBoolean(_) => 'visitBoolean';

  @override
  String visitDateTime(_) => 'visitDateTime';

  @override
  String visitFloat(_) => 'visitFloat';

  @override
  String visitInteger(_) => 'visitInteger';

  @override
  String visitString(_) => 'visitString';
}

void main() {
  group('TomlValueVisitor', () {
    final visitor = TomlValueTestVisitor();
    test('visitBoolean', () {
      expect(
        visitor.visitPrimitiveValue(TomlBoolean(true)),
        equals('visitBoolean'),
      );
    });
    test('visitDateTime', () {
      expect(
        visitor.visitPrimitiveValue(TomlLocalDate(TomlFullDate(1969, 7, 20))),
        equals('visitDateTime'),
      );
    });
    test('visitFloat', () {
      expect(
        visitor.visitPrimitiveValue(TomlFloat(13.37)),
        equals('visitFloat'),
      );
    });
    test('visitInteger', () {
      expect(
        visitor.visitPrimitiveValue(TomlInteger.dec(BigInt.from(42))),
        equals('visitInteger'),
      );
    });
    test('visitString', () {
      expect(
        visitor.visitPrimitiveValue(TomlLiteralString('test')),
        equals('visitString'),
      );
    });
  });
}
