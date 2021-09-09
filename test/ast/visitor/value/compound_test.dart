library toml.test.ast.visitor.value.compound_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlValueTestVisitor with TomlCompoundValueVisitorMixin<String> {
  @override
  String visitArray(_) => 'visitArray';

  @override
  String visitInlineTable(_) => 'visitInlineTable';
}

void main() {
  group('TomlCompoundValueVisitor', () {
    final visitor = TomlValueTestVisitor();
    test('visitArray', () {
      expect(
        visitor.visitCompoundValue(TomlArray([])),
        equals('visitArray'),
      );
    });
    test('visitInlineTable', () {
      expect(
        visitor.visitCompoundValue(TomlInlineTable([])),
        equals('visitInlineTable'),
      );
    });
  });
}
