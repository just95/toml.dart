library toml.test.ast.visitor.value_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlValueTestVisitor with TomlValueVisitorMixin<String> {
  @override
  String visitCompoundValue(_) => 'visitCompoundValue';

  @override
  String visitPrimitiveValue(_) => 'visitPrimitiveValue';
}

void main() {
  group('TomlValueVisitor', () {
    final visitor = TomlValueTestVisitor();
    test('visitCompoundValue', () {
      expect(
        visitor.visitValue(TomlArray([])),
        equals('visitCompoundValue'),
      );
    });
    test('visitPrimitiveValue', () {
      expect(
        visitor.visitValue(TomlBoolean(true)),
        equals('visitPrimitiveValue'),
      );
    });
  });
}
