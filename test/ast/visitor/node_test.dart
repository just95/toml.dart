library toml.test.ast.visitor.node_test;

import 'package:test/test.dart';
import 'package:toml/src/ast.dart';

/// A visitor that returns the name of its method that visited the node that
/// acceted the visitor.
class TomlTestVisitor with TomlVisitorMixin<String> {
  @override
  String visitDocument(_) => 'visitDocument';

  @override
  String visitExpression(_) => 'visitExpression';

  @override
  String visitKey(_) => 'visitKey';

  @override
  String visitSimpleKey(_) => 'visitSimpleKey';

  @override
  String visitValue(_) => 'visitValue';
}

void main() {
  group('TomlVisitor', () {
    final visitor = TomlTestVisitor();
    test('visitDocument', () {
      expect(
        visitor.visit(TomlDocument([])),
        equals('visitDocument'),
      );
    });
    test('visitExpression', () {
      expect(
        visitor.visit(TomlKeyValuePair(
          TomlKey([TomlUnquotedKey('key')]),
          TomlLiteralString('value'),
        )),
        equals('visitExpression'),
      );
    });
    test('visitKey', () {
      expect(
        visitor.visit(TomlKey.topLevel),
        equals('visitKey'),
      );
    });
    test('visitSimpleKey', () {
      expect(
        visitor.visit(TomlUnquotedKey('key')),
        equals('visitSimpleKey'),
      );
    });
    test('visitValue', () {
      expect(
        visitor.visit(TomlLiteralString('value')),
        equals('visitValue'),
      );
    });
  });
}
